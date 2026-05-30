import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_bible/shared/configs/objectbox.dart';
import 'package:simple_bible/user_space/data/user_space_repository.dart';

final userSpaceRepositoryProvider = Provider<UserSpaceRepository>((ref) {
  final store = ref.read(objectBoxProvider).objStore;
  return UserSpaceRepository(store);
});