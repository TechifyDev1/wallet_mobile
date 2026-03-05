import 'package:wallet/src/core/user/model/security.dart';
import 'package:wallet/src/core/user/model/user.dart';
import 'package:wallet/src/core/user/model/wallet.dart';

class UserSummery {
  final User user;
  final Wallet wallet;
  final Security security;

  UserSummery({
    required this.user,
    required this.wallet,
    required this.security,
  });

  factory UserSummery.fromJson(Map<String, dynamic> json) {
    return UserSummery(
      user: User.fromJson(json["user"]),
      wallet: Wallet.fromJson(json["wallet"]),
      security: Security.fromJson(json["security"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user": user.toJson(),
      "wallet": wallet.toJson(),
      "security": security.toJson(),
    };
  }
}
