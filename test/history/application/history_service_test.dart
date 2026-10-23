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
      expect(repository.saved.last.fromVerse, 0);
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

    test('updates the latest same-chapter visit at reader exit', () async {
      final earlier = _history(
        dateTime: '2024-01-01T00:00:00.000',
        fromVerse: 1,
      );
      final latest = _history(
        dateTime: '2024-01-02T00:00:00.000',
        fromVerse: 2,
      );
      latest.versionId = 101;
      earlier.uid = 1;
      latest.uid = 2;
      final repository = _FakeHistoryRepository([earlier, latest]);
      final service = HistoryService(repository);
      final previousDateTime = DateTime.parse(latest.dateTime);

      await service.recordExitLocation(
        versionId: 100,
        bookId: 0,
        chapter: 0,
        fromVerse: 7,
      );

      expect(repository.events, hasLength(2));
      expect(earlier.fromVerse, 1);
      expect(latest.fromVerse, 7);
      expect(latest.versionId, 100);
      expect(
        DateTime.parse(latest.dateTime).isAfter(previousDateTime),
        isTrue,
      );
      expect(repository.saved, [latest]);
    });

    test('creates a new visit when the latest location differs', () async {
      final previousVisit = _history(
        dateTime: '2024-01-02T00:00:00.000',
        fromVerse: 2,
      )..uid = 1;
      final repository = _FakeHistoryRepository([previousVisit]);
      final service = HistoryService(repository);

      await service.recordExitLocation(
        versionId: 100,
        bookId: 1,
        chapter: 2,
        fromVerse: 4,
      );

      expect(repository.saved, hasLength(1));
      expect(repository.events, hasLength(2));
      expect(repository.saved.single.bookId, 1);
      expect(repository.saved.single.chapter, 2);
      expect(repository.saved.single.fromVerse, 4);
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

History _history({required String dateTime, int fromVerse = 1}) {
  return History(
    versionId: 100,
    bookId: 0,
    chapter: 0,
    fromVerse: fromVerse,
    dateTime: dateTime,
  );
}

class _FakeHistoryRepository implements HistoryRepository {
  _FakeHistoryRepository([List<History>? initialEvents])
      : events = initialEvents ?? [] {
    _nextUid = events
            .map((event) => event.uid ?? 0)
            .fold(0, (maximum, uid) => uid > maximum ? uid : maximum) +
        1;
  }

  final List<History> events;
  final List<History> saved = [];
  bool failOnSave = false;
  late int _nextUid;

  @override
  List<History> getAll() => [...events];

  @override
  Future<void> save(History history) async {
    if (failOnSave) throw StateError('Storage unavailable');
    history.uid ??= _nextUid++;
    final existingIndex =
        events.indexWhere((event) => event.uid == history.uid);
    if (existingIndex == -1) {
      events.add(history);
    } else {
      events[existingIndex] = history;
    }
    saved.add(history);
  }
}
