import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:wallet/src/features/send_money/model/transfer_request.dart';
import 'package:wallet/src/features/send_money/model/transfer_response.dart';

import '../../../core/network/http_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../model/recent_contact_response.dart';

class SendMoneyRepository {
  final HttpClient _http;

  SendMoneyRepository(this._http);

  /// Safely extracts an error message from a response body.
  /// Returns a fallback string if the body is empty or not valid JSON.
  String _errorMessage(String body) {
    if (body.trim().isEmpty) return 'An error occurred';
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['detail']?.toString() ?? 'An error occurred';
      }
      return 'An error occurred';
    } catch (_) {
      return 'An error occurred';
    }
  }

  Future<List<RecentContactResponse>> getRecentContact() async {
    try {
      final response = await _http.get(
        Uri.parse(ApiEndpoints.getRecentContacts),
      );
      if (response.statusCode == 200) {
        final parsedRes = jsonDecode(response.body) as List<dynamic>;
        debugPrint("Recent Contacts: ${response.body}");
        return parsedRes
            .map((res) => RecentContactResponse.fromJson(res))
            .toList()
            .cast<RecentContactResponse>();
      }
      throw Exception(_errorMessage(response.body));
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<List<RecentContactResponse>> searchUsers(String query) async {
    try {
      final response = await _http.get(
        Uri.parse(ApiEndpoints.searchUsers(query)),
      );
      if (response.statusCode == 200) {
        final parsedRes = jsonDecode(response.body) as List<dynamic>;
        return parsedRes
            .map((res) => RecentContactResponse.fromJson(res))
            .toList()
            .cast<RecentContactResponse>();
      }
      throw Exception(_errorMessage(response.body));
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<TransferResponse> send({required TransferRequest request}) async {
    try {
      final response = await _http.post(
        Uri.parse(ApiEndpoints.sendMoney),
        body: jsonEncode(request.toJson()),
      );
      if (response.statusCode == 200) {
        debugPrint("Transfer Response: ${response.body}");
        final parsedRes = jsonDecode(response.body);
        final finalRes = TransferResponse.fromJson(parsedRes);
        return finalRes;
      }
      throw Exception(_errorMessage(response.body));
    } catch (e) {
      debugPrint("Error transferring money: ${e.toString()}");
      rethrow;
    }
  }
}
