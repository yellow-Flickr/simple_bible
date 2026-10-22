import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_bible/history/application/history_service.dart';
import 'package:simple_bible/history/domain/history.dart';

final historyServiceProvider = Provider<HistoryService>(
  (ref) => throw UnimplementedError('HistoryService must be provided.'),
);

class HistoryController extends AsyncNotifier<List<History>> {
  late HistoryService _service;

  @override
  Future<List<History>> build() {
    _service = ref.watch(historyServiceProvider);
    return Future.sync(_service.loadHistory);
  }

  Future<void> recordVisit({
    required int versionId,
    required int bookId,
    required int chapter,
    int? fromVerse,
  }) async {
    await future;
    await _service.recordVisit(
      versionId: versionId,
      bookId: bookId,
      chapter: chapter,
      fromVerse: fromVerse,
    );
    state = AsyncData(_service.loadHistory());
  }
}

final historyControllerProvider =
    AsyncNotifierProvider<HistoryController, List<History>>(
  HistoryController.new,
);
