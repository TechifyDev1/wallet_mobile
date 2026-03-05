import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet/src/core/user/presentation/provider/user_provider.dart';

import '../../../../core/utils/storage.dart';
import '../../model/fund_wallet_response.dart';
import '../../repository/fund_wallet_repo.dart';
import 'fund_wallet_repo_provider.dart';

final fundWalletNotifierProvider =
    AsyncNotifierProvider<FundWalletNotifier, FundWalletResponse?>(
      FundWalletNotifier.new,
    );

class FundWalletNotifier extends AsyncNotifier<FundWalletResponse?> {
  late final FundWalletRepo _repo;

  String? _idempotencyKey;

  @override
  FutureOr<FundWalletResponse?> build() {
    _repo = ref.read(fundWalletRepoProvider);
    return null; // no initial data
  }

  Future<void> fundWallet(Decimal amount) async {
    state = const AsyncLoading();

    // generate only if not already existing
    _idempotencyKey ??= const Uuid().v4();

    try {
      // persist key before sending
      await Storage.write("idempotencyKey", _idempotencyKey!);

      final response = await _repo.fund(
        amount: amount,
        idempotencyKey: _idempotencyKey!,
      );

      // success :. clear key
      await Storage.delete("idempotencyKey");
      _idempotencyKey = null;

      state = AsyncData(response);
      ref.read(userProvider.notifier).refresh();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
