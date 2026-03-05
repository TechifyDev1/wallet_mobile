import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/http_client.dart';
import '../../repository/send_money_repository.dart';

final sendMoneyRepositoryProvider = Provider<SendMoneyRepository>((ref) {
  final http = HttpClient();
  return SendMoneyRepository(http);
});
