import 'package:objectbox/objectbox.dart';

/// The raw JSON of the last catalogue fetched, so the store opens offline.
@Entity()
class CachedCatalogue {
  CachedCatalogue({this.uid, required this.json, required this.fetchedAt});

  @Id()
  int? uid;
  String json;
  int fetchedAt;
}
