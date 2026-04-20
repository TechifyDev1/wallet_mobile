import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:wallet/src/core/network/api_endpoints.dart';
import 'package:wallet/src/core/network/http_client.dart';
import 'package:wallet/src/core/utils/storage.dart';

class AuthRepository {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await HttpClient().post(
        Uri.parse(ApiEndpoints.login),
        body: jsonEncode({'email': email, 'password': password}),
      );

      debugPrint("Login Status Code: ${response.statusCode}");

      Map<String, dynamic> responseData = {};
      try {
        if (response.body.isNotEmpty) {
          responseData = jsonDecode(response.body);
        }
      } catch (e) {
        debugPrint("Failed to decode response: ${response.body}");
      }

      if (response.statusCode == 200) {
        final token = responseData["token"];
        final refreshTokenObj = responseData["refreshToken"];

        // Extract token string from refreshToken object
        final refreshTokenString =
            refreshTokenObj != null && refreshTokenObj is Map
            ? refreshTokenObj["token"]
            : refreshTokenObj;

        debugPrint('🎫 Login successful!');
        debugPrint(
          '📦 Token received: ${token != null ? '✓ Present (${token.substring(0, 20)}...)' : '✗ Missing'}',
        );
        debugPrint(
          '🔄 RefreshToken received: ${refreshTokenString != null ? '✓ Present (${refreshTokenString.toString().substring(0, 20)}...)' : '✗ Missing'}',
        );

        if (token != null && token.isNotEmpty && refreshTokenString != null) {
          await Storage.write("token", token);
          await Storage.write("refreshToken", refreshTokenString);
          debugPrint('💾 Tokens saved to secure storage');

          // Verify tokens were actually saved
          final savedToken = await Storage.read('token');
          final savedRefreshToken = await Storage.read('refreshToken');
          debugPrint(
            '✓ Token verification: ${savedToken != null ? 'Access Token saved ✅' : 'Access Token FAILED ❌'}',
          );
          debugPrint(
            '✓ RefreshToken verification: ${savedRefreshToken != null ? 'Refresh Token saved ✅' : 'Refresh Token FAILED ❌'}',
          );
        } else {
          debugPrint('❌ Missing token or refreshToken in response');
        }
        return responseData;
      } else {
        final errorMessage =
            responseData['detail'] ??
            responseData['message'] ??
            responseData['error'] ??
            'Server error (${response.statusCode})';
        throw errorMessage;
      }
    } catch (e) {
      debugPrint("Auth Error: $e");
      if (e is String) rethrow;
      throw 'Connection failed. Please check your internet.';
    }
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String phoneNumber,
    required String secretKey,
  }) async {
    try {
      final response = await HttpClient().post(
        Uri.parse(ApiEndpoints.register),
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'userName': username,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
          'secretKey': secretKey,
        }),
      );

      Map<String, dynamic> responseData = {};
      try {
        if (response.body.isNotEmpty) {
          responseData = jsonDecode(response.body);
        }
        Storage.write("isFirstTime", "true");
      } catch (e) {
        debugPrint("Failed to decode response: ${response.body}");
      }

      if (response.statusCode == 201) {
        return responseData;
      } else {
        final errorMessage =
            responseData['detail'] ??
            responseData['message'] ??
            responseData['error'] ??
            'Registration failed (${response.statusCode})';
        throw errorMessage;
      }
    } catch (e) {
      debugPrint("Auth Error: $e");
      if (e is String) rethrow;
      throw 'Connection failed. Please check your internet.';
    }
  }

  Future<Map<String, dynamic>> createPin({required String pin}) async {
    try {
      final response = await HttpClient().post(
        Uri.parse(ApiEndpoints.createPin),
        body: jsonEncode({'pin': pin}),
      );

      Map<String, dynamic> responseData = {};
      try {
        if (response.body.isNotEmpty) {
          responseData = jsonDecode(response.body);
        }
      } catch (e) {
        debugPrint("Failed to decode response: ${response.body}");
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        Storage.delete("isFirstTime");
        return responseData;
      } else {
        final errorMessage =
            responseData['detail'] ??
            responseData['message'] ??
            responseData['error'] ??
            'Failed to set PIN (${response.statusCode})';
        throw errorMessage;
      }
    } catch (e) {
      debugPrint(e.toString());
      debugPrint("Auth Error: $e");
      if (e is String) rethrow;
      throw 'Connection failed. Please check your internet.';
    }
  }

  Future<void> logout() async {
    try {
      debugPrint('🚪 Logout initiated - calling backend logout endpoint');
      final response = await HttpClient().post(Uri.parse(ApiEndpoints.logout));
      debugPrint('📊 Logout Response Status: ${response.statusCode}');
    } catch (e) {
      debugPrint('⚠️ Backend logout failed (continuing local logout): $e');
      // Continue with local logout even if backend call fails
    }

    debugPrint('💾 Clearing local tokens and storage');
    await Storage.delete("token");
    await Storage.delete("refreshToken");
    await Storage.delete("isFirstTime");
    debugPrint('✅ Local logout complete');
    HttpClient.onUnauthorized?.call();
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
    required String secretKey,
    required String newPassword,
  }) async {
    try {
      final response = await HttpClient().post(
        Uri.parse(ApiEndpoints.forgotPassword),
        body: jsonEncode({
          'email': email,
          'secretKey': secretKey,
          'newPassword': newPassword,
        }),
      );

      debugPrint("Forgot Password Status Code: ${response.statusCode}");

      Map<String, dynamic> responseData = {};
      try {
        if (response.body.isNotEmpty) {
          responseData = jsonDecode(response.body);
        }
      } catch (e) {
        debugPrint("Failed to decode response: ${response.body}");
      }

      if (response.statusCode == 200) {
        return responseData;
      } else {
        final errorMessage =
            responseData['detail'] ??
            responseData['message'] ??
            responseData['error'] ??
            'Password reset failed (${response.statusCode})';
        throw errorMessage;
      }
    } catch (e) {
      debugPrint("Forgot Password Error: $e");
      if (e is String) rethrow;
      throw 'Connection failed. Please check your internet.';
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String existingPassword,
    required String newPassword,
  }) async {
    try {
      final response = await HttpClient().post(
        Uri.parse(ApiEndpoints.resetPassword),
        body: jsonEncode({
          'currentPassword': existingPassword,
          'newPassword': newPassword,
        }),
      );

      debugPrint("Reset Password Status Code: ${response.statusCode}");

      Map<String, dynamic> responseData = {};
      try {
        if (response.body.isNotEmpty) {
          responseData = jsonDecode(response.body);
        }
      } catch (e) {
        debugPrint("Failed to decode response: ${response.body}");
      }

      if (response.statusCode == 200) {
        return responseData;
      } else {
        final errorMessage =
            responseData['detail'] ??
            responseData['message'] ??
            responseData['error'] ??
            'Password reset failed (${response.statusCode})';
        throw errorMessage;
      }
    } catch (e) {
      debugPrint("Reset Password Error: $e");
      if (e is String) rethrow;
      throw 'Connection failed. Please check your internet.';
    }
  }
}
