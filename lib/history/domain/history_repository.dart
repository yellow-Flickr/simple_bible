import 'package:simple_bible/history/domain/history.dart';

abstract interface class HistoryRepository {
  List<History> getAll();

  Future<void> save(History history);
}
