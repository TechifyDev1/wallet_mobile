import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/src/features/send_money/model/transfer_request.dart';
import 'package:wallet/src/features/send_money/model/transfer_response.dart';

import '../../model/recent_contact_response.dart';
import 'send_money_repository_provider.dart';

final sendMoneyProvider =
    AsyncNotifierProvider<SendMoneyNotifier, List<RecentContactResponse>>(() {
      return SendMoneyNotifier();
    });

class SendMoneyNotifier extends AsyncNotifier<List<RecentContactResponse>> {
  @override
  FutureOr<List<RecentContactResponse>> build() {
    final repo = ref.watch(sendMoneyRepositoryProvider);
    return repo.getRecentContact();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(sendMoneyRepositoryProvider).getRecentContact(),
    );
  }

  Future<TransferResponse> sendMoney(TransferRequest request) async {
    try {
      final repo = ref.read(sendMoneyRepositoryProvider);
      final response = await repo.send(request: request);
      ref.invalidateSelf();
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
