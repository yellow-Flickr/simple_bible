// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';
import 'dart:convert' show utf8, JsonUtf8Encoder;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_screen_controller.dart';
import 'package:simple_bible/favorites/presentation/favorites_controller.dart';
import 'package:simple_bible/notes/presentation/note_editor.dart';

class ScriptureScreen extends ConsumerStatefulWidget {
  final Quotation? quotation;
  const ScriptureScreen({
    this.quotation,
    super.key,
    /* required this.kjv */
  });

  @override
  ConsumerState<ScriptureScreen> createState() => ScriptureScreenState();
}

class ScriptureScreenState extends ConsumerState<ScriptureScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();
  late final AnimationController _chapterTransitionController;
  late Animation<Offset> _chapterTransitionAnimation;
  bool canPop = false;
  bool _isRecordingExit = false;
  bool _isNavigatingChapter = false;
  int highlightedIndex = -1;
  int _visibleVerseIndex = 0;
  int _chapterVerseCount = 0;

  @override
  void initState() {
    super.initState();
    _chapterTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _chapterTransitionAnimation =
        const AlwaysStoppedAnimation<Offset>(Offset.zero);
    _scrollController.addListener(_updateContinuousViewVerse);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeQuotation());
    ref.read(scriptureScreenProvider.notifier).scheduleFloatingActions();
  }

  void _scrollToVerse(int index) {
    final reference = ref.read(scriptureScreenProvider);
    final version = ref
        .read(scriptureScreenProvider.notifier)
        .getVersionByID(reference.versionId);
    final previousChapter = adjacentChapterPosition(
      version,
      bookIndex: reference.bookId,
      chapterIndex: reference.chapter,
      direction: -1,
    );
    itemScrollController.scrollTo(
      index: index + (previousChapter == null ? 0 : 1),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _navigateChapter(int direction) async {
    if (_isNavigatingChapter) return;

    final reference = ref.read(scriptureScreenProvider);
    final version = ref
        .read(scriptureScreenProvider.notifier)
        .getVersionByID(reference.versionId);
    final destination = adjacentChapterPosition(
      version,
      bookIndex: reference.bookId,
      chapterIndex: reference.chapter,
      direction: direction,
    );
    if (destination == null) return;

    final outgoingOffset = Offset(0, direction > 0 ? -1 : 1);
    setState(() {
      _isNavigatingChapter = true;
      _chapterTransitionAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: outgoingOffset,
      ).animate(
        CurvedAnimation(
          parent: _chapterTransitionController,
          curve: Curves.easeInOutCubic,
        ),
      );
    });

    try {
      await _chapterTransitionController.forward(from: 0);
      if (!mounted) return;

      ref.read(scriptureScreenProvider.notifier).changeBookAndChapter(
            bookId: destination.bookIndex,
            chapter: destination.chapterIndex,
          );
      setState(() {
        _chapterTransitionAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: -outgoingOffset,
        ).animate(
          CurvedAnimation(
            parent: _chapterTransitionController,
            curve: Curves.easeInOutCubic,
          ),
        );
      });
      _visibleVerseIndex = 0;
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;

      final updatedReference = ref.read(scriptureScreenProvider);
      final updatedVersion = ref
          .read(scriptureScreenProvider.notifier)
          .getVersionByID(updatedReference.versionId);
      final previousChapter = adjacentChapterPosition(
        updatedVersion,
        bookIndex: updatedReference.bookId,
        chapterIndex: updatedReference.chapter,
        direction: -1,
      );
      if (ref.read(cardSwitcherProvider)) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      } else {
        if (itemScrollController.isAttached) {
          itemScrollController.jumpTo(index: previousChapter == null ? 0 : 1);
        }
      }

      await _chapterTransitionController.reverse();
    } finally {
      if (mounted) {
        setState(() => _isNavigatingChapter = false);
      }
    }
  }

  void _updateVisibleVerse(int index) {
    if (index == _visibleVerseIndex) return;
    _visibleVerseIndex = index;
  }

  void _updateContinuousViewVerse() {
    if (!_scrollController.hasClients || _chapterVerseCount == 0) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) {
      _updateVisibleVerse(0);
      return;
    }

    final scrollProgress = position.pixels / position.maxScrollExtent;
    final index = (scrollProgress * (_chapterVerseCount - 1))
        .floor()
        .clamp(0, _chapterVerseCount - 1)
        .toInt();
    _updateVisibleVerse(index);
  }

  Future<void> _popAfterRecording() async {
    if (_isRecordingExit) return;
    _isRecordingExit = true;
    final reference = ref.read(scriptureScreenProvider);
    await ref.read(scriptureScreenProvider.notifier).recordExitLocation(
          reference.copyWith(fromVerse: _visibleVerseIndex),
        );
    if (!mounted) return;
    setState(() => canPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chapterTransitionController.dispose();
    super.dispose();
  }

  Future<void> _initializeQuotation() async {
    if (!mounted) return;

    final quotation = widget.quotation;
    if (quotation != null) {
      ref.read(scriptureScreenProvider.notifier).openQuotation(quotation);
      setState(() => highlightedIndex = quotation.fromVerse);
      _scrollToVerse(quotation.fromVerse);

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => highlightedIndex = -1);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final controller = ref.watch(scriptureScreenProvider);
    final version = ref
        .read(scriptureScreenProvider.notifier)
        .getVersionByID(controller.versionId);
    final selectedBook = version.books[controller.bookId];
    final scripture = selectedBook.chapters[controller.chapter];
    final hasPreviousChapter = adjacentChapterPosition(
          version,
          bookIndex: controller.bookId,
          chapterIndex: controller.chapter,
          direction: -1,
        ) !=
        null;
    final hasNextChapter = adjacentChapterPosition(
          version,
          bookIndex: controller.bookId,
          chapterIndex: controller.chapter,
          direction: 1,
        ) !=
        null;
    _chapterVerseCount = scripture.verses.length;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          unawaited(_popAfterRecording());
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () =>
            ref.read(scriptureScreenProvider.notifier).toggleFloatingActions(),
        child: Scaffold(
          // backgroundColor: Colors.black,
          appBar: AppBar(
            leading: DrawerButton(),
            automaticallyImplyLeading: false,
            title: Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: scripture.verses.first.bookName,
                  ),
                  TextSpan(text: ' ${scripture.verses.first.chapter}'),
                  TextSpan(
                      text: ' - ${scripture.verses.first.translationId}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        // color: theme.primaryColor
                      )),
                ]),
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            toolbarHeight: kToolbarHeight - 2.h,
            elevation: 0,
            scrolledUnderElevation: 0,
            // bottom: PreferredSize(
            //     preferredSize: Size.fromHeight(kToolbarHeight),
            //     child: Container(
            //       color: theme.primaryColorLight,
            //       padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
            //       child: Row(
            //         children: [
            //           Text.rich(
            //               TextSpan(children: [
            //                 TextSpan(text: scripture.verses.first.bookName),
            //                 TextSpan(
            //                     text: ' ${scripture.verses.first.chapter}'),
            //                 TextSpan(
            //                     text:
            //                         ' ${scripture.verses.first.translationId}',
            //                     style: theme.textTheme.bodySmall?.copyWith(
            //                         fontStyle: FontStyle.italic,
            //                         color: theme.primaryColor)),
            //               ]),
            //               style: theme.textTheme.bodySmall?.copyWith(
            //                   color: theme.primaryColor,
            //                   fontWeight: FontWeight.bold))
            //         ],
            //       ),
            //     )),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 3.w),
                child: Icon(Icons.search),
              ),
              GestureDetector(
                onTap: () => _versions(context),
                child: Padding(
                  padding: EdgeInsets.only(right: 4.w),
                  child: Icon(Icons.translate),
                ),
              ),
            ],
          ),

          body: SlideTransition(
            position: _chapterTransitionAnimation,
            child: IgnorePointer(
              ignoring: _isNavigatingChapter,
              child: Visibility(
                visible: ref.watch(cardSwitcherProvider),
                replacement: CardView(
                  scripture: scripture,
                  onVisibleVerseChanged: _updateVisibleVerse,
                  scrollController: itemScrollController,
                  highlightedIndex: highlightedIndex,
                  versionId: controller.versionId,
                  hasPreviousChapter: hasPreviousChapter,
                  hasNextChapter: hasNextChapter,
                  onPreviousChapter: () => _navigateChapter(-1),
                  onNextChapter: () => _navigateChapter(1),
                ),
                child: ContinousView(
                  scrollController: _scrollController,
                  scripture: scripture,
                  hasPreviousChapter: hasPreviousChapter,
                  hasNextChapter: hasNextChapter,
                  onPreviousChapter: () => _navigateChapter(-1),
                  onNextChapter: () => _navigateChapter(1),
                ),
              ),
            ),
          ),

          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniEndFloat,
          floatingActionButton: AnimatedSwitcher(
            duration: Durations.medium1,
            child: ref.watch(showFAB)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _books(context),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5)),
                          padding: EdgeInsets.symmetric(
                              vertical: .5.w, horizontal: .8.w),
                          child: Icon(
                            Icons.menu_book,
                            size: 20,
                            color: theme.scaffoldBackgroundColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 1.4.h,
                      ),
                      GestureDetector(
                        onTap: () => _chapters(context),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5)),
                          padding: EdgeInsets.symmetric(
                              vertical: .5.w, horizontal: .8.w),
                          child: Icon(
                            Icons.article,
                            size: 20,
                            color: theme.scaffoldBackgroundColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 1.4.h,
                      ),
                      GestureDetector(
                        onTap: () => _verses(context),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5)),
                          padding: EdgeInsets.symmetric(
                              vertical: .5.w, horizontal: .8.w),
                          child: Icon(
                            Icons.subject,
                            size: 20,
                            color: theme.scaffoldBackgroundColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 1.4.h,
                      ),
                      GestureDetector(
                        onTap: () => _themeSettings(context),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5)),
                          padding: EdgeInsets.symmetric(
                              vertical: .5.w, horizontal: .8.w),
                          child: Icon(
                            Icons.app_registration_sharp,
                            size: 20,
                            color: theme.scaffoldBackgroundColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                    ],
                  )
                : null,
          ),
        ),
      ),
    );
  }

  void _versions(context) {
    final theme = Theme.of(context);

    final scriptures = ref.read(scriptureScreenProvider.notifier).getVersions();
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0)),
        ),
        context: context,
        builder: (BuildContext bc) {
          return ListView.builder(
              itemCount: scriptures.length,
              shrinkWrap: true,
              itemBuilder: ((context, index) {
                return ListTile(
                  onTap: () {
                    ref
                        .read(scriptureScreenProvider.notifier)
                        .changeVersion(versionId: scriptures[index].id);

                    Navigator.pop(context);
                  },
                  title: Text(
                    scriptures[index].versionName,
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: theme.primaryColorLight),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                  ),
                );
              }));
        });
  }

  void _books(
    context,
    /* Versions scripture */
  ) {
    final theme = Theme.of(context);
    // final scripture = ref.watch(versionProvider);
    final controller = ref.watch(scriptureScreenProvider);
    final scripture = ref
        .read(scriptureScreenProvider.notifier)
        .getVersionByID(controller.versionId);
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0)),
        ),
        context: context,
        builder: (BuildContext bc) {
          return ListView.builder(
              itemCount: scripture.books.length,
              shrinkWrap: true,
              itemBuilder: ((context, index) {
                return ListTile(
                  onTap: () {
                    ref
                        .read(scriptureScreenProvider.notifier)
                        .changeBook(bookID: index);
                    // itemScrollController.jumpTo(
                    //     index: controller.chapterIds[index]);
                    // quotation.state = Quotation(bookId: );
                    // controller.currentChapter =
                    Navigator.pop(context);
                  },
                  title: Text(
                    scripture.books[index].name,
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: theme.primaryColorLight),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                  ),
                );
              }));
        });
  }

  void _chapters(
    BuildContext context,
    /* Versions scripture */
  ) {
    final theme = Theme.of(context);
    // final scripture = ref.watch(versionProvider);
    final controller = ref.watch(scriptureScreenProvider);
    final scripture = ref
        .read(scriptureScreenProvider.notifier)
        .getVersionByID(controller.versionId);

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0)),
        ),
        context: context,
        builder: (BuildContext bc) {
          return BottomSheet(
            builder: (context) => Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 3.w, right: 3.w, top: 1.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${scripture.books[controller.bookId].name} Chapters',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Divider(),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                      padding: const EdgeInsets.only(left: 40, top: 30),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5),
                      itemCount:
                          scripture.books[controller.bookId].chapters.length,
                      itemBuilder: ((context, index) {
                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(scriptureScreenProvider.notifier)
                                .changeChapter(chapter: index);

                            // itemScrollController.jumpTo(
                            //     index: scripture.books[controller.bookId].chapters
                            //         .indexWhere(
                            //             (element) => element.chapter == index + 1));

                            Navigator.pop(context);
                          },
                          child: Text((index + 1).toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: controller.chapter == index
                                      ? Colors.red
                                      : null)),
                        );
                      })),
                ),
              ],
            ),
            onClosing: () {},
          );
        });
  }

  void _themeSettings(
    BuildContext context,
    /* Versions scripture */
  ) async {
    final theme = Theme.of(context);
    // final scripture = ref.watch(versionProvider);
    // final controller = ref.watch(scriptureScreenProvider);
    // final scripture = getVersionByID(controller.versionId);

    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0)),
        ),
        context: context,
        isScrollControlled: false,
        enableDrag: false,
        showDragHandle: false,
        builder: (BuildContext bc) {
          return Consumer(
            builder: (context, ref, child) => BottomSheet(
              enableDrag: false,
              showDragHandle: false,
              builder: (context) => Column(
                // physics: NeverScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 3.w, right: 3.w, top: 1.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Themes & Settings',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        Divider(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 2.h,
                          ),
                          Container(
                            padding: EdgeInsetsDirectional.symmetric(
                                horizontal: 3.w, vertical: .5.h),
                            // decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(5),
                            //   color: Colors.grey.shade400,
                            // ),
                            child: Column(
                              children: [
                                ListTile(
                                  visualDensity: VisualDensity.compact,
                                  leading: Icon(
                                    Icons.font_download_rounded,
                                    size: 18,
                                  ),
                                  trailing: SizedBox(
                                    width: 18.w,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text('Default'),
                                        Icon(
                                          Icons.arrow_right,
                                        )
                                      ],
                                    ),
                                  ),
                                  minLeadingWidth: 10,
                                  horizontalTitleGap: 14,
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    'Font',
                                    style:
                                        theme.textTheme.displaySmall?.copyWith(
                                      fontSize:
                                          14, /* fontWeight: FontWeight.w500 */
                                    ),
                                  ),
                                ),
                                Divider(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Font Size',
                                      style: theme.textTheme.displaySmall
                                          ?.copyWith(fontSize: 14),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.height_rounded,
                                          size: 14,
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Slider(
                                            min: 8,
                                            max: 16,
                                            divisions: 20,
                                            value: ref.watch(fontSizeProvider),
                                            onChanged: (value) {
                                              ref
                                                  .read(
                                                      fontSizeProvider.notifier)
                                                  .update((curr) => value);

                                              // log(ref
                                              //     .watch(wordSpacingProvider)
                                              //     .toString());
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Divider(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Word Spacing',
                                      style: theme.textTheme.displaySmall
                                          ?.copyWith(fontSize: 14),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.height_rounded,
                                          size: 14,
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Slider(
                                            min: 0,
                                            max: 20,
                                            divisions: 20,
                                            value:
                                                ref.watch(wordSpacingProvider),
                                            onChanged: (value) {
                                              ref
                                                  .read(wordSpacingProvider
                                                      .notifier)
                                                  .update((curr) => value);

                                              // log(ref
                                              //     .watch(wordSpacingProvider)
                                              //     .toString());
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                Divider(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Line Spacing',
                                      style: theme.textTheme.displaySmall
                                          ?.copyWith(fontSize: 14),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.height_rounded,
                                          size: 14,
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Slider(
                                            min: 1.2,
                                            max: 3,
                                            divisions: 18,
                                            value:
                                                ref.watch(lineHeightProvider),
                                            onChanged: (value) {
                                              ref
                                                  .read(lineHeightProvider
                                                      .notifier)
                                                  .update((curr) => value);

                                              // log(ref
                                              //     .watch(wordSpacingProvider)
                                              //     .toString());
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              onClosing: () {},
            ),
          );
        });
  }

  void _verses(BuildContext context) {
    final theme = Theme.of(context);

    final controller = ref.watch(scriptureScreenProvider);
    final scripture = ref
        .read(scriptureScreenProvider.notifier)
        .getVersionByID(controller.versionId);
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0)),
        ),
        context: context,
        builder: (bc) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) => Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 3.w, right: 3.w, top: 1.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Verses',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Divider(),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                      padding: const EdgeInsets.only(left: 40, top: 30),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5),
                      itemCount: scripture.books[controller.bookId]
                          .chapters[controller.chapter].verses.length,
                      itemBuilder: ((context, index) {
                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(scriptureScreenProvider.notifier)
                                .changeVerse(verse: index);

                            // itemScrollController.jumpTo(
                            //     index: scripture.books[controller.bookId]
                            //         .chapters[controller.chapter].verses[index].id);

                            _scrollToVerse(index);
                            Navigator.pop(context);
                          },
                          child: Text((index + 1).toString(),
                              style: theme.textTheme.bodySmall
                              /* style: const TextStyle(
                              color: Color.fromARGB(255, 196, 211, 255)), */
                              ),
                        );
                      })),
                ),
              ],
            ),
          );
        });
  }
}

class ContinousView extends ConsumerWidget {
  const ContinousView({
    super.key,
    required ScrollController scrollController,
    required this.scripture,
    required this.hasPreviousChapter,
    required this.hasNextChapter,
    required this.onPreviousChapter,
    required this.onNextChapter,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final Chapter scripture;
  final bool hasPreviousChapter;
  final bool hasNextChapter;
  final VoidCallback onPreviousChapter;
  final VoidCallback onNextChapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);

    final fontSize = ref.watch(fontSizeProvider);

    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasPreviousChapter)
            _ChapterEdgePrompt(
              isNextChapter: false,
              onTap: onPreviousChapter,
            ),
          // Render all verses as one continuous text
          SelectableText.rich(
            TextSpan(
              style: theme.textTheme.bodySmall,
              children: List.generate(
                  scripture.verses.length,
                  (index) => TextSpan(
                        children: [
                          TextSpan(text: ' '),
                          WidgetSpan(
                            child: Transform.translate(
                              offset: const Offset(-1.0, -6.0),
                              child: Text(
                                (index + 1).toString(),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontSize: fontSize,
                                ),
                              ),
                            ),
                          ),
                          TextSpan(
                              text: scripture.verses[index].text,
                              // softWrap: true,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(height: 2, fontSize: fontSize + 4))
                        ],
                      )),
            ),
          ),
          if (hasNextChapter)
            _ChapterEdgePrompt(
              isNextChapter: true,
              onTap: onNextChapter,
            ),
        ],
      ),
    );
  }
}

class _ChapterEdgePrompt extends StatelessWidget {
  const _ChapterEdgePrompt({
    required this.isNextChapter,
    required this.onTap,
  });

  final bool isNextChapter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final directionIcon =
        isNextChapter ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up;
    final chapterDirection = isNextChapter ? 'next' : 'previous';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(directionIcon),
                const SizedBox(width: 8),
                Text('Scroll to $chapterDirection chapter'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardView extends ConsumerStatefulWidget {
  const CardView({
    super.key,
    required this.scripture,
    required this.onVisibleVerseChanged,
    this.highlightedIndex = -1,
    required ItemScrollController scrollController,
    required this.versionId,
    required this.hasPreviousChapter,
    required this.hasNextChapter,
    required this.onPreviousChapter,
    required this.onNextChapter,
  }) : _scrollController = scrollController;

  final Chapter scripture;
  final ValueChanged<int> onVisibleVerseChanged;
  final int highlightedIndex;
  final ItemScrollController _scrollController;
  final int versionId;
  final bool hasPreviousChapter;
  final bool hasNextChapter;
  final VoidCallback onPreviousChapter;
  final VoidCallback onNextChapter;

  @override
  ConsumerState<CardView> createState() => _CardViewState();
}

class _CardViewState extends ConsumerState<CardView> {
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final Set<int> _selectedIndexes = {};
  int? _expandedVerseIndex;

  bool get _isSelecting => _selectedIndexes.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_onItemPositionsChanged);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions
        .removeListener(_onItemPositionsChanged);
    super.dispose();
  }

  void _onItemPositionsChanged() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final verseOffset = widget.hasPreviousChapter ? 1 : 0;
    final versePositions = positions.where(
      (position) =>
          position.index >= verseOffset &&
          position.index <
              verseOffset + widget.scripture.verses.length,
    );
    if (versePositions.isEmpty) return;

    final topPosition = versePositions.reduce((closest, position) {
      return position.itemLeadingEdge.abs() < closest.itemLeadingEdge.abs()
          ? position
          : closest;
    });
    widget.onVisibleVerseChanged(topPosition.index - verseOffset);
  }

  @override
  void didUpdateWidget(covariant CardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scripture.id != widget.scripture.id ||
        oldWidget.versionId != widget.versionId) {
      _selectedIndexes.clear();
      _expandedVerseIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final fontSize = ref.watch(fontSizeProvider);
    final lineSpacing = ref.watch(lineHeightProvider);
    final wordSpacing = ref.watch(wordSpacingProvider);
    final favoriteKeys = ref
        .watch(favoritesControllerProvider)
        .map((favorite) => (
              favorite.versionId,
              favorite.bookId,
              favorite.chapter,
              favorite.fromVerse,
            ))
        .toSet();

    final allSelectedAreFavorites = _selectedIndexes.isNotEmpty &&
        _selectedIndexes.every((index) {
          final verse = widget.scripture.verses[index];
          return favoriteKeys.contains((
            widget.versionId,
            verse.bookId,
            verse.chapter,
            verse.verse,
          ));
        });

    return Column(
      children: [
        if (_isSelecting)
          Material(
            color: theme.primaryColorDark.withValues(alpha: .14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Clear selection',
                    onPressed: _clearSelection,
                    icon: const Icon(Icons.close),
                  ),
                  Expanded(
                    child: Text(
                      '${_selectedIndexes.length} selected',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: allSelectedAreFavorites
                        ? 'Remove selected verses from favorites'
                        : 'Favorite selected verses',
                    onPressed: () => _toggleFavorites(
                      _selectedIndexes.toList(),
                    ),
                    icon: Icon(
                      allSelectedAreFavorites
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: allSelectedAreFavorites
                          ? theme.colorScheme.error
                          : null,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add a note to selected verses',
                    onPressed: () => _openNote(_selectedIndexes.toList()),
                    icon: const Icon(Icons.note_add_outlined),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: ScrollablePositionedList.separated(
            itemCount: widget.scripture.verses.length +
                (widget.hasPreviousChapter ? 1 : 0) +
                (widget.hasNextChapter ? 1 : 0),
            itemScrollController: widget._scrollController,
            itemPositionsListener: _itemPositionsListener,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              if (widget.hasPreviousChapter && index == 0) {
                return _ChapterEdgePrompt(
                  isNextChapter: false,
                  onTap: widget.onPreviousChapter,
                );
              }
              final verseIndex = index - (widget.hasPreviousChapter ? 1 : 0);
              if (verseIndex == widget.scripture.verses.length) {
                return _ChapterEdgePrompt(
                  isNextChapter: true,
                  onTap: widget.onNextChapter,
                );
              }

              final verse = widget.scripture.verses[verseIndex];
              final isSelected = _selectedIndexes.contains(verseIndex);
              final isFavorite = favoriteKeys.contains((
                widget.versionId,
                verse.bookId,
                verse.chapter,
                verse.verse,
              ));
              final accent = theme.primaryColorDark;
              final backgroundColor = isSelected
                  ? accent.withValues(alpha: .2)
                  : widget.highlightedIndex == verseIndex
                      ? theme.primaryColor.withValues(alpha: .4)
                      : isFavorite
                          ? accent.withValues(alpha: .07)
                          : Colors.transparent;

              return AnimatedContainer(
                key: ValueKey(verse.id),
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: accent.withValues(alpha: .8))
                      : isFavorite
                          ? Border.all(color: accent.withValues(alpha: .35))
                          : null,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onLongPress: () => _selectVerse(verseIndex),
                  onTap: _isSelecting
                      ? () => _toggleSelection(verseIndex)
                      : () => _toggleVerseActions(verseIndex),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // if (_isSelecting)
                            //   Padding(
                            //     padding: const EdgeInsets.only(right: 8),
                            //     child: Icon(
                            //       isSelected
                            //           ? Icons.check_circle
                            //           : Icons.radio_button_unchecked,
                            //       color:
                            //           isSelected ? accent : theme.disabledColor,
                            //       size: 20,
                            //     ),
                            //   ),
                            Expanded(
                              child: Text(
                                '${verse.bookName} ${verse.chapter}:${verse.verse}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  height: 2,
                                  fontSize:
                                      (theme.textTheme.labelMedium?.fontSize ??
                                              fontSize) *
                                          (fontSize / 8),
                                ),
                              ),
                            ),
                            if (isFavorite ||
                                _expandedVerseIndex == verseIndex)
                              IconButton(
                                tooltip: isFavorite
                                    ? 'Remove from favorites'
                                    : 'Add to favorites',
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints.tightFor(
                                  width: 36,
                                  height: 36,
                                ),
                                onPressed: () =>
                                    _toggleFavorites([verseIndex]),
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 15,
                                  color: isFavorite
                                      ? theme.colorScheme.error
                                      : theme.iconTheme.color,
                                ),
                              ),
                            if (_expandedVerseIndex == verseIndex)
                              IconButton(
                                tooltip: 'Add a note',
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints.tightFor(
                                  width: 36,
                                  height: 36,
                                ),
                                onPressed: () => _openNote([verseIndex]),
                                icon: const Icon(
                                  Icons.note_add_outlined,
                                  size: 15,
                                ),
                              ),
                          ],
                        ),
                        SelectableText(
                          verse.text,
                          onTap: _isSelecting
                              ? () => _toggleSelection(verseIndex)
                              : () {
                                  _toggleVerseActions(verseIndex);
                                  ref
                                      .read(scriptureScreenProvider.notifier)
                                      .toggleFloatingActions();
                                },
                          onSelectionChanged: (selection, cause) {
                            if (cause == SelectionChangedCause.longPress) {
                              _selectVerse(verseIndex);
                            }
                          },
                          style: theme.textTheme.bodySmall?.copyWith(
                            wordSpacing: wordSpacing,
                            height: lineSpacing,
                            fontSize: fontSize + 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => Divider(
              thickness: .5,
              color: theme.dividerColor,
            ),
          ),
        ),
      ],
    );
  }

  void _selectVerse(int index) {
    if (_selectedIndexes.contains(index)) return;
    setState(() {
      _selectedIndexes.add(index);
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (!_selectedIndexes.add(index)) {
        _selectedIndexes.remove(index);
      }
    });
  }

  void _toggleVerseActions(int index) {
    setState(() {
      _expandedVerseIndex = _expandedVerseIndex == index ? null : index;
    });
  }

  void _clearSelection() {
    setState(_selectedIndexes.clear);
  }

  void _toggleFavorites(List<int> indexes) {
    ref.read(favoritesControllerProvider.notifier).toggleFavorites(
          verses:
              indexes.map((index) => widget.scripture.verses[index]).toList(),
          versionId: widget.versionId,
        );
  }

  void _openNote(List<int> indexes) {
    final selection = Quotation.fromVerses(
      indexes.map((index) => widget.scripture.verses[index]),
      versionId: widget.versionId,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditor(initialText: selection),
      ),
    );
  }
}
