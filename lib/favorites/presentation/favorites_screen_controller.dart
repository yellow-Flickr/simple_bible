import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';

class FavoriteScreenNotifier extends AutoDisposeNotifier<Quotation> {
  @override
  build() {
    return initialize();
  }

  List<int> chapterIds = [];
  int currentChapter = 1;
  int currentBook = 0;

  Quotation initialize() => Quotation();

  void changeBook({required int bookID}) {
    state = state.copyWith(bookId: bookID);
  }

  void changeChapter({required int chapter}) {
    state = state.copyWith(chapter: chapter);
  }

  void changeVerse({required int verse}) {
    state = state.copyWith(verse: verse);
  }

  void changeVersion({required int versionId}) {
    state = state.copyWith(versionId: versionId);
  }
}

final favoriteScreenProvider =
    NotifierProvider.autoDispose<FavoriteScreenNotifier, Quotation>(
        FavoriteScreenNotifier.new);

