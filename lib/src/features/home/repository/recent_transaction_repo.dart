import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/http_client.dart';
import '../model/paginated_response.dart';
import '../model/recent_transaction_response.dart';

class RecentTransactionRepo {
  final HttpClient _http;
  RecentTransactionRepo(this._http);
  Future<PaginatedResponse<RecentTransactionResponse>> getRecentTx({
    int page = 0,
    int size = 15,
  }) async {
    try {
      final response = await _http.get(
        Uri.parse(ApiEndpoints.recentTransactions).replace(
          queryParameters: {'page': page.toString(), 'size': size.toString()},
        ),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> parsedRes = jsonDecode(response.body);
        debugPrint(response.body);

        final List<dynamic> content = parsedRes['content'] ?? [];
        final transactions = content
            .map<RecentTransactionResponse>(
              (res) => RecentTransactionResponse.fromJson(res),
            )
            .toList();

        return PaginatedResponse(
          content: transactions,
          isLast: parsedRes['last'] ?? true,
          totalElements: parsedRes['totalElements'] ?? transactions.length,
        );
      }
      throw Exception(
        jsonDecode(response.body)["detail"] ?? "An error occurred",
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
