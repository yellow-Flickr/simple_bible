import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_bible/user_space/data/user_space_repository_provider.dart';
import 'package:simple_bible/user_space/domain/user_space.dart';

class UserSpaceService extends Notifier<UserSpace> {
  @override
  UserSpace build() {
    final repository = ref.read(userSpaceRepositoryProvider);
    final userSpace = repository.getUserSpace();
    if (userSpace == null) {
      final guest = UserSpace.guest();
      // Save the guest user (fire and forget)
      // ignore: unawaited_futures
      repository.saveUserSpace(guest);
      return guest;
    }
    return userSpace;
  }
}

final userSpaceProvider =
    NotifierProvider<UserSpaceService, UserSpace>(() => UserSpaceService());