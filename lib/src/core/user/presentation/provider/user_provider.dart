import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:wallet/src/core/user/model/user_summery.dart';
import '../../../utils/storage.dart';
import 'user_repository_provider.dart';

class UserNotifier extends AsyncNotifier<UserSummery> {
  @override
  FutureOr<UserSummery> build() {
    final repo = ref.watch(userRepositoryProvider);
    return repo.getMe();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(userRepositoryProvider).getMe(),
    );
  }

  Future<void> changeEmail({
    required String newEmail,
    required String password,
  }) async {
    await ref
        .read(userRepositoryProvider)
        .changeEmail(newEmail: newEmail, password: password);
    await refresh();
  }

  Future<void> changePhone({
    required String newPhoneNumber,
    required String password,
  }) async {
    await ref
        .read(userRepositoryProvider)
        .changePhone(newPhoneNumber: newPhoneNumber, password: password);
    await refresh();
  }

  Future<void> logout() async {
    try {
      await Storage.delete('token');
      await Storage.delete('refreshToken');
      await Storage.delete('isFirstTime');
    } catch (e) {
      // Error clearing storage
    }
    state = AsyncValue.error('Logged out', StackTrace.current);
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, UserSummery>(() {
  return UserNotifier();
});
