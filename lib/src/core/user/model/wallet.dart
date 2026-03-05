import 'package:decimal/decimal.dart';

class Wallet {
  final String walletNumber;
  final Decimal availableBalance;
  final String currency;
  final String status;

  Wallet({
    required this.walletNumber,
    required this.availableBalance,
    required this.currency,
    required this.status,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      walletNumber: json['walletNumber'] as String,
      availableBalance: Decimal.parse(json['availableBalance'].toString()),
      currency: json['currency'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletNumber': walletNumber,
      'availableBalance': availableBalance.toString(),
      'currency': currency,
      'status': status,
    };
  }
}
