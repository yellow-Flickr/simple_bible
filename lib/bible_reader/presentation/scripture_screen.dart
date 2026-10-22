// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

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

class ScriptureScreenState extends ConsumerState<ScriptureScreen> {
  final ScrollController _scrollController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();
  bool canPop = false;
  int highlightedIndex = -1;

  void _scrollToVerse(int index) {
    itemScrollController.scrollTo(
      index: index,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recordVisit());
    ref.read(scriptureScreenProvider.notifier).scheduleFloatingActions();
  }

  Future<void> _recordVisit() async {
    if (!mounted) return;

    final quotation = widget.quotation;
    if (quotation != null) {
      final visitRecording =
          ref.read(scriptureScreenProvider.notifier).openQuotation(quotation);
      setState(() => highlightedIndex = quotation.fromVerse);
      _scrollToVerse(quotation.fromVerse);

      await visitRecording;
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => highlightedIndex = -1);
      return;
    }

    await ref
        .read(scriptureScreenProvider.notifier)
        .recordLocation(ref.read(scriptureScreenProvider));
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final controller = ref.watch(scriptureScreenProvider);
    ref.listen(scriptureScreenProvider, (previous, next) {
      ref.read(scriptureScreenProvider.notifier).recordLocation(next);
    });

    final scripture = ref
        .read(scriptureScreenProvider.notifier)
        .getVersionByID(controller.versionId)
        .books[controller.bookId]
        .chapters[controller.chapter];

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          //? Update History Notifier here
          setState(() {
            canPop = true;
          });
          Navigator.pop(context);
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

          body: Visibility(
            visible: ref.watch(cardSwitcherProvider),
            // maintainState: true,
            replacement: CardView(
              scripture: scripture,
              scrollController: itemScrollController,
              highlightedIndex: highlightedIndex,
              versionId: controller.versionId,
            ),
            child: ContinousView(
              scrollController: _scrollController,
              scripture: scripture,
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
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final Chapter scripture;

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
        ],
      ),
    );
  }
}

class CardView extends ConsumerStatefulWidget {
  const CardView({
    super.key,
    required this.scripture,
    this.highlightedIndex = -1,
    required ItemScrollController scrollController,
    required this.versionId,
  }) : _scrollController = scrollController;

  final Chapter scripture;
  final int highlightedIndex;
  final ItemScrollController _scrollController;
  final int versionId;

  @override
  ConsumerState<CardView> createState() => _CardViewState();
}

class _CardViewState extends ConsumerState<CardView> {
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final Set<int> _selectedIndexes = {};

  bool get _isSelecting => _selectedIndexes.isNotEmpty;

  @override
  void didUpdateWidget(covariant CardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scripture.id != widget.scripture.id ||
        oldWidget.versionId != widget.versionId) {
      _selectedIndexes.clear();
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
            itemCount: widget.scripture.verses.length,
            itemScrollController: widget._scrollController,
            itemPositionsListener: _itemPositionsListener,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final verse = widget.scripture.verses[index];
              final isSelected = _selectedIndexes.contains(index);
              final isFavorite = favoriteKeys.contains((
                widget.versionId,
                verse.bookId,
                verse.chapter,
                verse.verse,
              ));
              final accent = theme.primaryColorDark;
              final backgroundColor = isSelected
                  ? accent.withValues(alpha: .2)
                  : widget.highlightedIndex == index
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
                  onLongPress: () => _selectVerse(index),
                  onTap: _isSelecting ? () => _toggleSelection(index) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (_isSelecting)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color:
                                      isSelected ? accent : theme.disabledColor,
                                  size: 20,
                                ),
                              ),
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
                            IconButton(
                              tooltip: isFavorite
                                  ? 'Remove from favorites'
                                  : 'Add to favorites',
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints.tightFor(
                                width: 36,
                                height: 36,
                              ),
                              onPressed: () => _toggleFavorites([index]),
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 19,
                                color: isFavorite
                                    ? theme.colorScheme.error
                                    : theme.iconTheme.color,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Add a note',
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints.tightFor(
                                width: 36,
                                height: 36,
                              ),
                              onPressed: () => _openNote([index]),
                              icon: const Icon(
                                Icons.note_add_outlined,
                                size: 19,
                              ),
                            ),
                          ],
                        ),
                        SelectableText(
                          utf8.decode(JsonUtf8Encoder().convert(verse.text)),
                          onTap: _isSelecting
                              ? () => _toggleSelection(index)
                              : null,
                          onSelectionChanged: (selection, cause) {
                            if (cause == SelectionChangedCause.longPress) {
                              _selectVerse(index);
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
    final verses = indexes.map((index) => widget.scripture.verses[index]);
    final noteText = verses
        .map((verse) =>
            '${verse.bookName} ${verse.chapter}:${verse.verse}\n${verse.text}')
        .join('\n\n');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditor(
          initialText: Quotation(text: 'Scripture notes\n\n$noteText'),
        ),
      ),
    );
  }
}
