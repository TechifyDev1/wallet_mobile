class ApiEndpoints {
  // Using the host machine's Local IP address for physical device testing

  static const String baseUrl = 'https://wallet-system-nbok.onrender.com/api';
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String createPin = '$baseUrl/auth/set-pin';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String getMe = '$baseUrl/user/me';
  static const String changeEmail = '$baseUrl/user/email/change';
  static const String changePhone = '$baseUrl/user/phone/change';
  static String checkIdemp({required String key}) => '$baseUrl/check$key';
  static const String fundWallet = '$baseUrl/fund';
  static const String getRecentContacts = '$baseUrl/user/me/recent-contact';
  static String searchUsers(String query) =>
      '$baseUrl/user/search?query=${Uri.encodeComponent(query)}';
  static const String sendMoney = '$baseUrl/transfer';
  static const String recentTransactions = '$baseUrl/transactions';
}
