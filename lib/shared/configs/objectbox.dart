import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:simple_bible/objectbox.g.dart';

class ObjectBox {
  /// The Store of this app.
  late final Store objStore;

  ObjectBox._create(this.objStore) {
    // Add any additional setup code, e.g. build queries.
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore(directory: p.join(docsDir.path, "obj_bx-simple_bible"));
    return ObjectBox._create(store);
  }
}


final objectBoxProvider =
    Provider<ObjectBox>((ref) => throw UnimplementedError());