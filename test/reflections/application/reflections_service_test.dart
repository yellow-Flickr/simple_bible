import 'package:flutter_test/flutter_test.dart';
import 'package:simple_bible/reflections/application/reflections_service.dart';
import 'package:simple_bible/reflections/data/reflections_asset_source.dart';
import 'package:simple_bible/reflections/domain/reflection.dart';
import 'package:simple_bible/reflections/domain/reflection_log.dart';
import 'package:simple_bible/topics/domain/topic.dart';

void main() {
  final library = [_reflection('a'), _reflection('b'), _reflection('c')];

  late _FakeLogs logs;
  late ReflectionsService service;

  setUp(() {
    logs = _FakeLogs();
    service = ReflectionsService(_FakeSource(library), logs);
  });

  Future<String?> showOn(DateTime day) async =>
      (await service.todayReflection(day))?.id;

  test('shows the first unseen reflection and logs it', () async {
    expect(await showOn(DateTime(2026, 10, 1, 8)), 'a');
    expect(logs.items.single.date, '2026-10-01');
  });

  test('keeps the same reflection all day without logging twice', () async {
    await showOn(DateTime(2026, 10, 1, 8));
    expect(await showOn(DateTime(2026, 10, 1, 22)), 'a');
    expect(logs.items, hasLength(1));
  });

  test('a skipped day logs nothing, so nothing is lost', () async {
    await showOn(DateTime(2026, 10, 1));
    // Oct 2 and 3: app not opened.
    expect(await showOn(DateTime(2026, 10, 4)), 'b');
    expect(logs.items.map((l) => l.date), ['2026-10-01', '2026-10-04']);
  });

  test('repeats the least recently shown once all have been seen', () async {
    await showOn(DateTime(2026, 10, 1)); // a
    await showOn(DateTime(2026, 10, 2)); // b
    await showOn(DateTime(2026, 10, 3)); // c
    expect(await showOn(DateTime(2026, 10, 4)), 'a');
    expect(await showOn(DateTime(2026, 10, 5)), 'b');
  });

  test('replaces a logged reflection that is no longer in the library',
      () async {
    logs.items.add(ReflectionLog(
      date: '2026-10-01',
      reflectionId: 'removed',
      shownAt: DateTime(2026, 10, 1).millisecondsSinceEpoch,
    ));
    expect(await showOn(DateTime(2026, 10, 1, 9)), 'a');
    expect(logs.items.where((l) => l.date == '2026-10-01').single.reflectionId,
        'a');
  });

  test('history is newest first and skips removed reflections', () async {
    await showOn(DateTime(2026, 10, 1));
    await showOn(DateTime(2026, 10, 3));
    logs.items.add(ReflectionLog(
      date: '2026-10-02',
      reflectionId: 'removed',
      shownAt: DateTime(2026, 10, 2).millisecondsSinceEpoch,
    ));

    final history = await service.history();

    expect(history.map((e) => e.reflection.id), ['b', 'a']);
    expect(history.first.date, DateTime(2026, 10, 3));
  });

  test('nextFor previews without logging and handles an empty library', () {
    expect(nextFor(library, const [])?.id, 'a');
    expect(nextFor(const [], const []), isNull);
    expect(logs.items, isEmpty);
  });

  test('returns null when the library is empty', () async {
    final empty = ReflectionsService(_FakeSource(const []), logs);
    expect(await empty.todayReflection(DateTime(2026, 10, 1)), isNull);
    expect(logs.items, isEmpty);
  });
}

Reflection _reflection(String id) => Reflection(
      id: id,
      topicSlug: 'faith',
      title: 'Title $id',
      reference: const TopicReference(
          bookNumber: 58, chapter: 11, fromVerse: 1, toVerse: 1),
      reflection: 'Reflection',
      question: 'Question',
      action: 'Action',
      prayer: 'Prayer',
    );

class _FakeSource extends ReflectionsAssetSource {
  const _FakeSource(this.reflections);

  final List<Reflection> reflections;

  @override
  Future<List<Reflection>> loadReflections() async => reflections;
}

/// Mirrors ObjectBox: `date` is unique and a clash replaces the old entry.
class _FakeLogs implements ReflectionLogRepository {
  final items = <ReflectionLog>[];

  @override
  List<ReflectionLog> getAll() => [...items];

  @override
  Future<void> save(ReflectionLog log) async {
    items
      ..removeWhere((l) => l.date == log.date)
      ..add(log);
  }
}
