class Security {
  final bool hasTransactionPin;
  final bool isKycVerified;
  final String kycLevel;
  final bool twoFactorEnabled;
  final String accountStatus;

  Security({
    required this.hasTransactionPin,
    required this.isKycVerified,
    required this.kycLevel,
    required this.twoFactorEnabled,
    required this.accountStatus,
  });

  factory Security.fromJson(Map<String, dynamic> json) {
    return Security(
      hasTransactionPin: json["hasTransactionPin"],
      isKycVerified: json["isKycVerified"],
      kycLevel: json["kycLevel"],
      twoFactorEnabled: json["twoFactorEnabled"],
      accountStatus: json["accountStatus"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "hasTransactionPin": hasTransactionPin,
      "isKycVerified": isKycVerified,
      "kycLevel": kycLevel,
      "accountStatus": accountStatus,
    };
  }
}
