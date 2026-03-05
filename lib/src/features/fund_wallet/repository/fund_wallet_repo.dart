import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:wallet/src/core/network/api_endpoints.dart';

import '../../../core/network/http_client.dart';
import '../model/fund_wallet_response.dart';

class FundWalletRepo {
  final HttpClient _http;
  FundWalletRepo(this._http);

  Future<FundWalletResponse> fund({
    required Decimal amount,
    required String idempotencyKey,
  }) async {
    final response = await _http.post(
      Uri.parse(ApiEndpoints.fundWallet),
      body: jsonEncode({
        "amount": amount.toString(),
        "idempotencyKey": idempotencyKey,
      }),
    );

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      return FundWalletResponse.fromJson(parsed);
    }

    throw Exception(jsonDecode(response.body)["detail"] ?? "Unexpected error");
  }
}
