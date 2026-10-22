import 'package:objectbox/objectbox.dart';
import 'package:simple_bible/favorites/domain/favorite.dart';
import 'package:simple_bible/favorites/domain/favorites_repository.dart';

class LocalFavoritesRepository implements FavoritesRepository {
  LocalFavoritesRepository(Store store) : _box = store.box<Favorite>();

  final Box<Favorite> _box;

  @override
  List<Favorite> getAll() => _box.getAll();

  @override
  void save(Favorite favorite) {
    _box.put(favorite);
  }

  @override
  void delete(Favorite favorite) {
    final id = favorite.uid;
    if (id != null) _box.remove(id);
  }
}
