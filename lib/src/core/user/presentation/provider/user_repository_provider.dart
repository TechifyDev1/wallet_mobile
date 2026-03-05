import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../network/http_client.dart';
import '../../repository/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final http = HttpClient();
  return UserRepository(http);
});
