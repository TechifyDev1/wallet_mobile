import 'package:decimal/decimal.dart';

class FundWalletResponse {
  final String message;
  final String reference;
  final Decimal amount;
  final Decimal? newBalance;
  final String status;

  FundWalletResponse({
    required this.message,
    required this.reference,
    required this.amount,
    this.newBalance,
    required this.status,
  });

  factory FundWalletResponse.fromJson(Map<String, dynamic> json) {
    return FundWalletResponse(
      message: json["message"],
      reference: json["reference"],
      amount: Decimal.parse(json["amount"].toString()),
      newBalance: Decimal.parse(json["newBalance"].toString()),
      status: json["status"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "reference": reference,
      "amount": amount.toString(),
      "newBalance": newBalance,
      "status": status,
    };
  }
}
