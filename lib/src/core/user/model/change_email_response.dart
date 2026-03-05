class ChangeEmailResponse {
  final String userId;
  final String oldEmail;
  final String newEmail;
  final String updatedAt;
  final String message;

  ChangeEmailResponse({
    required this.userId,
    required this.oldEmail,
    required this.newEmail,
    required this.updatedAt,
    required this.message,
  });

  factory ChangeEmailResponse.fromJson(Map<String, dynamic> json) {
    return ChangeEmailResponse(
      userId: json['userId'] as String,
      oldEmail: json['oldEmail'] as String,
      newEmail: json['newEmail'] as String,
      updatedAt: json['updatedAt'] as String,
      message: json['message'] as String,
    );
  }
}
