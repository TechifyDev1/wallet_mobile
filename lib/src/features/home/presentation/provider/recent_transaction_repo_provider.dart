import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/src/features/home/repository/recent_transaction_repo.dart';

import '../../../../core/network/http_client.dart';

final recentTransactionRepoProvider = Provider<RecentTransactionRepo>((ref) {
  final http = HttpClient();
  return RecentTransactionRepo(http);
});
