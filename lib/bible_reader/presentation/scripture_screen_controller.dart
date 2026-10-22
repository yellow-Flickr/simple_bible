import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart'
    show scriptureServiceProvider;
import 'package:simple_bible/history/presentation/history_controller.dart';

class ScriptureScreenNotifier extends AutoDisposeNotifier<Quotation> {
  @override
  Quotation build() {
    ref.onDispose(() => _fabTimer?.cancel());
    return Quotation(text: '');
  }

  Timer? _fabTimer;
  (int, int, int)? _lastRecordedLocation;

  void changeBook({required int bookID}) {
    state = state.copyWith(bookId: bookID);
  }

  void changeChapter({required int chapter}) {
    state = state.copyWith(chapter: chapter);
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

  Future<void> openQuotation(Quotation quotation) async {
    _lastRecordedLocation = _locationKey(quotation);
    gotoQuotation(quote: quotation);
    await _persistVisit(quotation, fromVerse: quotation.fromVerse);
  }

  Future<void> recordLocation(Quotation reference) async {
    final key = _locationKey(reference);
    if (_lastRecordedLocation == key) return;
    _lastRecordedLocation = key;
    await _persistVisit(reference);
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

  (int, int, int) _locationKey(Quotation reference) =>
      (reference.versionId, reference.bookId, reference.chapter);

  Future<void> _persistVisit(Quotation reference, {int? fromVerse}) async {
    try {
      await ref.read(historyServiceProvider).recordVisit(
            versionId: reference.versionId,
            bookId: reference.bookId,
            chapter: reference.chapter,
            fromVerse: fromVerse,
          );
      ref.invalidate(historyControllerProvider);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'history',
          context: ErrorDescription('while recording a scripture visit'),
        ),
      );
    }
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
