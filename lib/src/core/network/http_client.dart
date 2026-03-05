import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
        urlString.contains('auth/set-pin');

    if (!isAuthEndpoint) {
      final token = await Storage.read('token');
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
        debugPrint('HTTP: Added token to request: $urlString');
      } else {
        debugPrint(
          'HTTP Warning: No token found for authenticated endpoint: $urlString',
        );
      }
    } else {
      debugPrint('HTTP: Skipping token for auth endpoint: $urlString');
    }

    final response = await _inner.send(request);

    if ((response.statusCode == 401 || response.statusCode == 403) &&
        !isAuthEndpoint) {
      debugPrint(
        'HTTP: ${response.statusCode}! Clearing token and notifying logout.',
      );
      await Storage.delete('token');

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
