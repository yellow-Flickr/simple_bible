import 'package:simple_bible/objectbox.g.dart';
import 'package:simple_bible/search/domain/recent_search.dart';

class LocalRecentSearchRepository implements RecentSearchRepository {
  LocalRecentSearchRepository(Store store) : _box = store.box<RecentSearch>();

  final Box<RecentSearch> _box;

  @override
  List<RecentSearch> getAll() => _box.getAll();

  @override
  void save(RecentSearch search) => _box.put(search);

  @override
  void removeMany(List<int> uids) => _box.removeMany(uids);
}
