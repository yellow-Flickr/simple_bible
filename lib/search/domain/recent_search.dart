import 'package:objectbox/objectbox.dart';

@Entity()
class RecentSearch {
  RecentSearch({this.uid, required this.query, required this.usedAt});

  @Id()
  int? uid;

  String query;

  /// Milliseconds since epoch.
  int usedAt;
}

abstract interface class RecentSearchRepository {
  List<RecentSearch> getAll();

  void save(RecentSearch search);

  void removeMany(List<int> uids);
}
