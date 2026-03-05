import 'package:decimal/decimal.dart';

class TransferRequest {
  final Decimal amount;
  final String receiverUsername;
  final String idempotencyKey;
  final String comment;
  final String transactionPin;

  TransferRequest({
    required this.amount,
    required this.receiverUsername,
    required this.idempotencyKey,
    required this.comment,
    required this.transactionPin,
  });

  factory TransferRequest.fromJson(Map<String, dynamic> json) {
    return TransferRequest(
      amount: Decimal.parse(json["amount"].toString()),
      receiverUsername: json["receiverUsername"],
      idempotencyKey: json["idempotencyKey"],
      comment: json["comment"],
      transactionPin: json["transactionPin"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "amount": amount.toString(),
      "receiverUsername": receiverUsername,
      "idempotencyKey": idempotencyKey,
      "comment": comment,
      "transactionPin": transactionPin,
    };
  }
}
