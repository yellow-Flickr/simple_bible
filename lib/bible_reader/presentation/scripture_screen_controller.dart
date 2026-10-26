import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart'
    show scriptureServiceProvider;
import 'package:simple_bible/history/presentation/history_controller.dart';

typedef ChapterPosition = ({int bookIndex, int chapterIndex});

ChapterPosition? adjacentChapterPosition(
  Versions version, {
  required int bookIndex,
  required int chapterIndex,
  required int direction,
}) {
  if (direction != -1 && direction != 1) {
    throw ArgumentError.value(direction, 'direction', 'Must be -1 or 1.');
  }
  if (bookIndex < 0 || bookIndex >= version.books.length) return null;

  final chapters = version.books[bookIndex].chapters;
  if (chapterIndex < 0 || chapterIndex >= chapters.length) return null;

  final adjacentChapterIndex = chapterIndex + direction;
  if (adjacentChapterIndex >= 0 && adjacentChapterIndex < chapters.length) {
    return (bookIndex: bookIndex, chapterIndex: adjacentChapterIndex);
  }

  var adjacentBookIndex = bookIndex + direction;
  while (adjacentBookIndex >= 0 &&
      adjacentBookIndex < version.books.length) {
    final adjacentBookChapters = version.books[adjacentBookIndex].chapters;
    if (adjacentBookChapters.isNotEmpty) {
      return (
        bookIndex: adjacentBookIndex,
        chapterIndex: direction == 1 ? 0 : adjacentBookChapters.length - 1,
      );
    }
    adjacentBookIndex += direction;
  }
  return null;
}

class ScriptureScreenNotifier extends AutoDisposeNotifier<Quotation> {
  @override
  Quotation build() {
    ref.onDispose(() => _fabTimer?.cancel());
    return Quotation.zero(text: '');
  }

  Timer? _fabTimer;
  void changeBook({required int bookID}) {
    state = state.copyWith(bookId: bookID);
  }

  void changeChapter({required int chapter}) {
    state = state.copyWith(chapter: chapter);
  }

  void changeBookAndChapter({
    required int bookId,
    required int chapter,
  }) {
    state = state.copyWith(bookId: bookId, chapter: chapter, fromVerse: 0);
  }

  void changeVerse({required int verse}) {
    state = state.copyWith(fromVerse: verse);
  }

  void changeVersion({required int versionId}) {
    state = state.copyWith(versionId: versionId);
  }

  void gotoQuotation({required Quotation quote}) {
    state = state.copyWith(
      bookId: quote.bookId,
      fromVerse: quote.fromVerse,
      chapter: quote.chapter,
      versionId: quote.versionId,
    );
  }

  Versions getVersionByID(int uid) {
    return ref.read(scriptureServiceProvider).getVersion(uid);
  }

  List<Versions> getVersions() {
    return ref.read(scriptureServiceProvider).getVersions();
  }

  void openQuotation(Quotation quotation) {
    gotoQuotation(quote: quotation);
  }

  Future<void> recordExitLocation(Quotation reference) async {
    try {
      await ref.read(historyServiceProvider).recordExitLocation(
            versionId: reference.versionId,
            bookId: reference.bookId,
            chapter: reference.chapter,
            fromVerse: reference.fromVerse,
          );
      ref.invalidate(historyControllerProvider);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'history',
          context: ErrorDescription('while recording the reader exit location'),
        ),
      );
    }
  }

  void scheduleFloatingActions() {
    _fabTimer?.cancel();
    _fabTimer = Timer(Durations.medium4, showFloatingActions);
  }

  void toggleFloatingActions() {
    final showActions = !ref.read(showFAB);
    ref.read(showFAB.notifier).state = showActions;
    _scheduleFloatingActionsHide();
  }

  void showFloatingActions() {
    ref.read(showFAB.notifier).state = true;
    _scheduleFloatingActionsHide();
  }

  void _scheduleFloatingActionsHide() {
    _fabTimer?.cancel();
    _fabTimer = Timer(const Duration(seconds: 5), () {
      ref.read(showFAB.notifier).state = false;
    });
  }
}

final scriptureScreenProvider =
    NotifierProvider.autoDispose<ScriptureScreenNotifier, Quotation>(
        ScriptureScreenNotifier.new);

final currentBookProvider =
    StateProvider<Verse>((ref) => throw UnimplementedError());
final showFAB = StateProvider.autoDispose<bool>((ref) => false);
final currentQuotationProvider =
    StateProvider<Quotation>((ref) => throw UnimplementedError());

//Reader Settings
final fontSizeProvider = StateProvider<double>((ref) => 8);
final lineHeightProvider = StateProvider<double>((ref) => 1.3);
final wordSpacingProvider = StateProvider<double>((ref) => 0);
final cardSwitcherProvider = StateProvider<bool>((ref) => false);
