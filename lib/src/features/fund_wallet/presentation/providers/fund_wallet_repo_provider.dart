import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/http_client.dart';
import '../../repository/fund_wallet_repo.dart';

final fundWalletRepoProvider = Provider<FundWalletRepo>((ref) {
  final http = HttpClient();
  return FundWalletRepo(http);
});
