import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:wallet/src/core/network/api_endpoints.dart';
import 'package:wallet/src/core/network/http_client.dart';
import 'package:wallet/src/core/user/model/user_summery.dart';
import '../model/change_email_response.dart';
import '../model/change_phone_response.dart';

class UserRepository {
  final HttpClient _http;

  UserRepository(this._http);

  Future<UserSummery> getMe() async {
    try {
      debugPrint('🔵 UserRepository.getMe() called');
      debugPrint('📍 Endpoint: ${ApiEndpoints.getMe}');
      final response = await _http.get(Uri.parse(ApiEndpoints.getMe));
      debugPrint('📊 getMe() Response Status: ${response.statusCode}');
      debugPrint('📝 getMe() Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final parsedRes = jsonDecode(response.body);
        final finalRes = UserSummery.fromJson(parsedRes);
        debugPrint('✅ Successfully parsed user data');
        return finalRes;
      }
      debugPrint('❌ getMe() failed with status ${response.statusCode}');
      throw Exception(
        jsonDecode(response.body)["detail"] ?? "An error occurred",
      );
    } catch (e) {
      debugPrint('❌ getMe() Exception: $e');
      rethrow;
    }
  }

  Future<ChangeEmailResponse> changeEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final response = await _http.post(
        Uri.parse(ApiEndpoints.changeEmail),
        body: jsonEncode({'newEmail': newEmail, 'password': password}),
      );
      if (response.statusCode == 200) {
        return ChangeEmailResponse.fromJson(jsonDecode(response.body));
      }
      throw Exception(
        jsonDecode(response.body)["detail"] ?? "An error occurred",
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ChangePhoneResponse> changePhone({
    required String newPhoneNumber,
    required String password,
  }) async {
    try {
      final response = await _http.post(
        Uri.parse(ApiEndpoints.changePhone),
        body: jsonEncode({
          'newPhoneNumber': newPhoneNumber,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        return ChangePhoneResponse.fromJson(jsonDecode(response.body));
      }
      throw Exception(
        jsonDecode(response.body)["detail"] ?? "An error occurred",
      );
    } catch (e) {
      rethrow;
    }
  }
}
