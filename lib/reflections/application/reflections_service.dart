import 'package:intl/intl.dart' show DateFormat;
import 'package:simple_bible/reflections/data/reflections_asset_source.dart';
import 'package:simple_bible/reflections/domain/reflection.dart';
import 'package:simple_bible/reflections/domain/reflection_log.dart';

final _dayFormat = DateFormat('yyyy-MM-dd');

class ReflectionsService {
  ReflectionsService(this._source, this._logs);

  final ReflectionsAssetSource _source;
  final ReflectionLogRepository _logs;
  Future<List<Reflection>>? _reflections;

  /// Loads the library once; later calls reuse it. A failed load is not
  /// cached, so callers can retry.
  Future<List<Reflection>> loadReflections() {
    return _reflections ??= _source.loadReflections().catchError((Object e) {
      _reflections = null;
      throw e;
    });
  }

  /// Today's reflection, logging it the first time it is requested today.
  /// Returns null only when the library is empty.
  Future<Reflection?> todayReflection(DateTime now) async {
    final reflections = await loadReflections();
    final byId = {for (final r in reflections) r.id: r};
    final logs = _logs.getAll();
    final today = _dayFormat.format(now);

    final todayLog = logs.where((log) => log.date == today).firstOrNull;
    if (todayLog != null && byId[todayLog.reflectionId] != null) {
      return byId[todayLog.reflectionId];
    }

    final next = nextFor(reflections, logs);
    if (next == null) return null;
    await _logs.save(ReflectionLog(
      uid: todayLog?.uid,
      date: today,
      reflectionId: next.id,
      shownAt: now.millisecondsSinceEpoch,
    ));
    return next;
  }

  /// Reflections shown so far, newest first. Entries whose reflection is no
  /// longer in the library are skipped.
  Future<List<ReflectionEntry>> history() async {
    final byId = {for (final r in await loadReflections()) r.id: r};
    final logs = [..._logs.getAll()]..sort((a, b) => b.date.compareTo(a.date));
    return [
      for (final log in logs)
        if (byId[log.reflectionId] case final reflection?)
          (date: _dayFormat.parse(log.date), reflection: reflection),
    ];
  }
}

/// The next reflection to show: the first one never shown, in library order,
/// or once all have been shown, the one shown longest ago. Doesn't log
/// anything, so it can also be used to preview tomorrow's reflection.
Reflection? nextFor(List<Reflection> reflections, List<ReflectionLog> logs) {
  if (reflections.isEmpty) return null;

  final lastShown = <String, int>{};
  for (final log in logs) {
    final previous = lastShown[log.reflectionId];
    if (previous == null || log.shownAt > previous) {
      lastShown[log.reflectionId] = log.shownAt;
    }
  }

  final unseen = reflections.where((r) => !lastShown.containsKey(r.id));
  if (unseen.isNotEmpty) return unseen.first;

  return reflections.reduce(
    (oldest, r) => lastShown[r.id]! < lastShown[oldest.id]! ? r : oldest,
  );
}
