class ChangePhoneResponse {
  final String userId;
  final String oldPhoneNumber;
  final String newPhoneNumber;
  final String updatedAt;
  final String message;

  ChangePhoneResponse({
    required this.userId,
    required this.oldPhoneNumber,
    required this.newPhoneNumber,
    required this.updatedAt,
    required this.message,
  });

  factory ChangePhoneResponse.fromJson(Map<String, dynamic> json) {
    return ChangePhoneResponse(
      userId: json['userId'] as String,
      oldPhoneNumber: json['oldPhoneNumber'] as String,
      newPhoneNumber: json['newPhoneNumber'] as String,
      updatedAt: json['updatedAt'] as String,
      message: json['message'] as String,
    );
  }
}
