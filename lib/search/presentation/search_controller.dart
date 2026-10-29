import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_bible/search/application/search_service.dart';
import 'package:simple_bible/search/data/local_recent_search_repository.dart';
import 'package:simple_bible/search/data/verse_source.dart';
import 'package:simple_bible/shared/configs/objectbox.dart';

final searchServiceProvider = Provider<SearchService>((ref) {
  final store = ref.watch(objectBoxProvider).objStore;
  return SearchService(
    LocalVerseSource(store),
    LocalRecentSearchRepository(store),
  );
});
