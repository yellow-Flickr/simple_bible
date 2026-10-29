import 'package:objectbox/objectbox.dart';

/// Records that a reflection appeared on Home on [date]. Only days on which
/// the app was opened are recorded, which is what makes up the history.
@Entity()
class ReflectionLog {
  ReflectionLog({
    this.uid,
    required this.date,
    required this.reflectionId,
    required this.shownAt,
  });

  @Id()
  int? uid;

  /// Local calendar day, `yyyy-MM-dd`.
  @Unique(onConflict: ConflictStrategy.replace)
  String date;

  String reflectionId;

  /// Milliseconds since epoch.
  int shownAt;
}

abstract interface class ReflectionLogRepository {
  List<ReflectionLog> getAll();

  Future<void> save(ReflectionLog log);
}
