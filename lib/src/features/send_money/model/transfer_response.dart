import 'package:decimal/decimal.dart';

class TransferResponse {
  final String receiverUsername;
  final String status;
  final String type;
  final Decimal amount;
  final String message;
  final String reference;

  TransferResponse({
    required this.receiverUsername,
    required this.status,
    required this.type,
    required this.amount,
    required this.message,
    required this.reference,
  });

  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      receiverUsername: json["receiverUsername"],
      status: json["status"],
      type: json["type"],
      amount: Decimal.parse(json["amount"].toString()),
      message: json["message"],
      reference: json["reference"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiverUsername': receiverUsername,
      'status': status,
      'type': type,
      'amount': amount.toString(),
      'message': message,
      'reference': reference,
    };
  }
}
