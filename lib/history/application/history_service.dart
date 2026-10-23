import 'package:simple_bible/history/domain/history.dart';
import 'package:simple_bible/history/domain/history_repository.dart';

class HistoryService {
  const HistoryService(this._repository);

  final HistoryRepository _repository;

  List<History> loadHistory() {
    final history = [..._repository.getAll()];
    history.sort(
      (a, b) =>
          DateTime.parse(b.dateTime).compareTo(DateTime.parse(a.dateTime)),
    );
    return history;
  }

  Future<void> recordVisit({
    required int versionId,
    required int bookId,
    required int chapter,
    int fromVerse = 0,
  }) {
    return _repository.save(
      History(
        versionId: versionId,
        bookId: bookId,
        chapter: chapter,
        fromVerse: fromVerse,
        dateTime: DateTime.now().toIso8601String(),
      ),
    );
  }

  Future<void> recordExitLocation({
    required int versionId,
    required int bookId,
    required int chapter,
    required int fromVerse,
  }) async {
    final history = loadHistory();
    if (history.isNotEmpty) {
      final latestVisit = history.first;
      if (latestVisit.bookId == bookId && latestVisit.chapter == chapter) {
        latestVisit
          ..versionId = versionId
          ..fromVerse = fromVerse
          ..dateTime = DateTime.now().toIso8601String();
        await _repository.save(latestVisit);
        return;
      }
    }

    await recordVisit(
      versionId: versionId,
      bookId: bookId,
      chapter: chapter,
      fromVerse: fromVerse,
    );
  }
}
