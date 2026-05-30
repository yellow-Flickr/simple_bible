import 'package:objectbox/objectbox.dart';
import 'package:simple_bible/user_space/domain/user_space.dart';

class UserSpaceRepository {
  final Box<UserSpace> _box;

  UserSpaceRepository(Store store) : _box = store.box<UserSpace>();

  // Read
  UserSpace? getUserSpace() {
    return _box.getAll().firstOrNull;
  }

  // Write
  Future<void> saveUserSpace(UserSpace userSpace) async {
    await _box.putAsync(userSpace);
  }
}