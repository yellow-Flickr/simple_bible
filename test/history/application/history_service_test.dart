import 'package:flutter_test/flutter_test.dart';
import 'package:simple_bible/history/application/history_service.dart';
import 'package:simple_bible/history/domain/history.dart';
import 'package:simple_bible/history/domain/history_repository.dart';

void main() {
  group('HistoryService', () {
    test('records each visit with its scripture reference and timestamp',
        () async {
      final repository = _FakeHistoryRepository();
      final service = HistoryService(repository);

      await service.recordVisit(
        versionId: 100,
        bookId: 1,
        chapter: 2,
        fromVerse: 3,
      );
      await service.recordVisit(
        versionId: 100,
        bookId: 1,
        chapter: 2,
      );

      expect(repository.saved, hasLength(2));
      expect(repository.saved.first.versionId, 100);
      expect(repository.saved.first.bookId, 1);
      expect(repository.saved.first.chapter, 2);
      expect(repository.saved.first.fromVerse, 3);
      expect(repository.saved.last.fromVerse, isNull);
      expect(DateTime.tryParse(repository.saved.first.dateTime), isNotNull);
    });

    test('loads events newest first without mutating repository results', () {
      final newest = _history(dateTime: '2024-01-02T00:00:00.000');
      final oldest = _history(dateTime: '2024-01-01T00:00:00.000');
      final repository = _FakeHistoryRepository([oldest, newest]);
      final service = HistoryService(repository);

      final loaded = service.loadHistory();

      expect(loaded, [newest, oldest]);
      expect(repository.events, [oldest, newest]);
    });

    test('propagates persistence failures', () async {
      final repository = _FakeHistoryRepository()..failOnSave = true;
      final service = HistoryService(repository);

      await expectLater(
        service.recordVisit(versionId: 100, bookId: 0, chapter: 0),
        throwsA(isA<StateError>()),
      );
      expect(repository.events, isEmpty);
    });
  });
}

History _history({required String dateTime}) {
  return History(
    versionId: 100,
    bookId: 0,
    chapter: 0,
    dateTime: dateTime,
  );
}

class _FakeHistoryRepository implements HistoryRepository {
  _FakeHistoryRepository([List<History>? initialEvents])
      : events = initialEvents ?? [];

  final List<History> events;
  final List<History> saved = [];
  bool failOnSave = false;

  @override
  List<History> getAll() => [...events];

  @override
  Future<void> save(History history) async {
    if (failOnSave) throw StateError('Storage unavailable');
    events.add(history);
    saved.add(history);
  }
}
