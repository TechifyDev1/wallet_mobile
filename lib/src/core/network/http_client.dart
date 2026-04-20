import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wallet/src/core/network/api_endpoints.dart';
import '../utils/storage.dart';

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([
    this.message = 'Session expired. Please log in again.',
  ]);
  @override
  String toString() => message;
}

class HttpClient extends http.BaseClient {
  // Use a single static client to reuse connections
  static final http.Client _staticClient = http.Client();

  // Instance-level client just in case someone wants to provide their own,
  // but by default we use the static one.
  final http.Client _inner;

  HttpClient([http.Client? client]) : _inner = client ?? _staticClient;

  /// Static callback that can be set globally to handle 401/403 errors (e.g., redirect to login)
  static void Function()? onUnauthorized;
  Future<void> _injectToken(http.BaseRequest request, bool isAuth) async {
    if (!isAuth) {
      final token = await Storage.read('token');
      debugPrint(
        '🔑 Token read from storage: ${token != null ? '✓ Present (${token.substring(0, 20)}...)' : '✗ Missing'}',
      );
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
        debugPrint('✅ Token injected into Authorization header');
      } else {
        debugPrint('⚠️ Token is null or empty, not injecting');
      }
    }
  }

  Future<bool> _handleTokenRefresh() async {
    final refreshToken = await Storage.read('refreshToken');
    if (refreshToken == null) return false;

    try {
      final response = await _inner.post(
        Uri.parse(ApiEndpoints.refresh),
        headers: {'Content-Type': 'application/json', 'X-Client-Type': 'app'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await Storage.write('token', data['token']);
        // Optional: Update refresh token if your backend rotates it
        if (data['refreshToken'] != null) {
          await Storage.write('refreshToken', data['refreshToken']);
        }
        return true;
      }
    } catch (e) {
      debugPrint('HTTP Error during refresh: $e');
    }
    return false;
  }

  Future<http.BaseRequest> _copyRequest(http.BaseRequest original) async {
    final token = await Storage.read('token');
    final newRequest = http.Request(original.method, original.url);

    newRequest.headers.addAll(original.headers);
    if (token != null) {
      newRequest.headers['Authorization'] = 'Bearer $token';
    }

    if (original is http.Request) {
      newRequest.bodyBytes = original.bodyBytes;
    } else if (original is http.MultipartRequest) {
      // Note: Multipart retry is complex, usually requires re-opening files
      debugPrint('Warning: Retry logic for MultipartRequest is limited.');
    }

    return newRequest;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Add default headers
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'application/json';
    request.headers['X-Client-Type'] = 'app';

    final urlString = request.url.toString();
    final isAuthEndpoint =
        urlString.contains('auth/login') ||
        urlString.contains('auth/register') ||
        urlString.contains('auth/logout') ||
        urlString.contains('auth/refresh');

    await _injectToken(request, isAuthEndpoint);

    final response = await _inner.send(request);

    if ((response.statusCode == 401 || response.statusCode == 403) &&
        !isAuthEndpoint) {
      debugPrint(
        'Received ${response.statusCode} for ${request.url}. Attempting token refresh.',
      );
      final refreshed = await _handleTokenRefresh();
      if (refreshed) {
        debugPrint('Token refreshed successfully. Retrying original request.');
        final newRequest = await _copyRequest(request);
        return _inner.send(newRequest);
      } else {
        debugPrint('Token refresh failed. Clearing tokens and notifying app.');
        await Storage.delete('token');
        await Storage.delete('refreshToken');
      }

      // Drain the stream to close the connection properly
      await response.stream.drain();

      // Notify globally if callback set
      if (onUnauthorized != null) {
        onUnauthorized!();
      }

      throw UnauthorizedException();
    }

    return response;
  }
}
