import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_bible/configs/objectbox.dart';
import 'package:simple_bible/user_space/domain/user_space.dart';

class UserSpaceService extends Notifier<UserSpace> {
  @override
  UserSpace build() {
    return initializeUserSpace();
  }

  UserSpace initializeUserSpace() {
    if (ref.read(objectBoxProvider).objStore.box<UserSpace>().isEmpty()) {
      final user = UserSpace.guest();
      ref.read(objectBoxProvider).objStore.box<UserSpace>().putAsync(user);
      return user;
    }
    return ref.read(objectBoxProvider).objStore.box<UserSpace>().getAll().first;
  }
}

final userSpaceProvider =
    NotifierProvider<UserSpaceService, UserSpace>(() => UserSpaceService());
