import 'package:decimal/decimal.dart';

class RecentContactResponse {
  final String userName;
  final DateTime lastTransactionDate;
  final Decimal amount;
  final String? profilePicUrl;

  RecentContactResponse({
    required this.userName,
    required this.lastTransactionDate,
    required this.amount,
    this.profilePicUrl,
  });

  factory RecentContactResponse.fromJson(Map<String, dynamic> json) {
    return RecentContactResponse(
      userName: json["userName"],
      lastTransactionDate: DateTime.parse(
        json["lastTransactionDate"] as String,
      ),
      amount: Decimal.parse(json["amount"].toString()),
      profilePicUrl: json["profilePicUrl"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userName": userName,
      "lastTransactionDate": lastTransactionDate.toIso8601String(),
      "amount": amount.toString(),
      "profilePicUrl": profilePicUrl,
    };
  }
}
