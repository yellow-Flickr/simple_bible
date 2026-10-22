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
    int? fromVerse,
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
}
