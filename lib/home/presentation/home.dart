import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/bible_reader/application/scripture_service.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart'
    show scriptureServiceProvider;
import 'package:simple_bible/bible_reader/presentation/scripture_screen.dart';
import 'package:simple_bible/favorites/domain/favorite.dart';
import 'package:simple_bible/favorites/presentation/favorites_controller.dart';
import 'package:simple_bible/history/presentation/history_controller.dart';
import 'package:simple_bible/shared/configs/assets.dart';
import 'package:simple_bible/shared/shell/app_tab_controller.dart';
import 'package:simple_bible/shared/configs/constants.dart';
import 'package:simple_bible/shared/configs/extensions.dart';
import 'package:simple_bible/favorites/presentation/favorites_view.dart';
import 'package:simple_bible/history/domain/history.dart';
import 'package:simple_bible/history/presentation/history_screen.dart';
import 'package:simple_bible/topics/presentation/topic_screen.dart';
import 'package:simple_bible/topics/presentation/topics_controller.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  int _favoriteIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(historyControllerProvider);
    final history = historyAsync.valueOrNull;
    final favorites = [...ref.watch(favoritesControllerProvider)]
      ..sort((a, b) => b.date.compareTo(a.date));
    final favorite =
        favorites.isEmpty ? null : favorites[_favoriteIndex % favorites.length];
    final scriptureService = ref.read(scriptureServiceProvider);
    final resume = _latestResolvableEntry(history, scriptureService);
    return Scaffold(
      appBar: AppBar(
        // leadingWidth: 30.w,
        centerTitle: false,
        title: Padding(
          // height: 5.h,
          padding: EdgeInsets.only(left: 1.5.w, top: 1.h),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.end,
            // textBaseline: TextBaseline.ideographic,
            children: [
              Lottie.asset(
                DateTime.now().greeting().$2,
                // LottieAssets.night,
                fit: BoxFit.contain,
                height: kToolbarHeight,
              ),
              SizedBox(
                width: 1.w,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    flex: 2,
                    child: Text(
                      DateTime.now().greeting().$1,
                      style:
                          TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
                    ),
                  ),
                  // Spacer(),
                  Flexible(
                      flex: 3,
                      child: Text(
                        'Welcome!',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1),
                      )),
                ],
              )
            ],
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 3.w),
            child: Icon(Icons.search),
          ),
        ],
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        // shrinkWrap: true,
        children: [
          _buildVerseOfTheDay(theme),
          Padding(
            padding: EdgeInsets.only(
              top: 2.h,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: .5.h,
                horizontal: 2.w,
              ),
              decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColorLight)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reflections Today',
                          // textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w300, fontSize: 13)),
                      Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: theme.primaryColorLight),
                              // color: theme.primaryColorLight,
                              shape: BoxShape.circle),
                          child: Icon(
                            Icons.arrow_outward_sharp,
                            color: theme.primaryColorLight,
                            size: 15,
                          ))
                    ],
                  ),
                  SizedBox(
                    height: .5.h,
                  ),
                  Text(
                    'God\'s plan for us is filled with hope.\nReflect on HIS assurances and provisions.',
                    // textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 3.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      final quote = resume?.entry.fromHistory();

                      openScripture(context, quotation: quote);
                    },
                    child: Container(
                      width: 20.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.primaryColorLight)),
                      child: Lottie.asset(
                        LottieAssets.reader,
                        fit: BoxFit.contain,
                        // height: kToolbarHeight,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: .5.h,
                  ),
                  Text(
                    'Scriptures',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () =>
                        ref.read(appTabProvider.notifier).state = AppTab.topics,
                    child: Container(
                      width: 20.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.primaryColorLight)),
                      child: Icon(
                        Icons.auto_stories,
                        size: 9.w,
                        color: theme.primaryColorDark,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: .5.h,
                  ),
                  Text(
                    'Reflections',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryScreen(),
                        )),
                    child: Container(
                      width: 20.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.primaryColorLight)),
                      child: Lottie.asset(
                        LottieAssets.history,
                        fit: BoxFit.contain,
                        // height: kToolbarHeight,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: .5.h,
                  ),
                  Text(
                    'History',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FavoritesView(),
                        )),
                    child: Container(
                      width: 20.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.primaryColorLight)),
                      child: Lottie.asset(
                        LottieAssets.favourite,
                        fit: BoxFit.contain,
                        // height: kToolbarHeight,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: .5.h,
                  ),
                  Text(
                    'Favourites',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                  )
                ],
              ),
            ],
          ),
          SizedBox(
            height: 3.h,
          ),
          _buildExplore(theme),
          SizedBox(
            height: 3.h,
          ),
          if (resume != null)
            _buildResumeCard(context, resume.entry, resume.reference),
          if (historyAsync.hasError)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Row(
                children: [
                  const Expanded(
                      child: Text('Unable to load reading history.')),
                  TextButton(
                    onPressed: () => ref.invalidate(historyControllerProvider),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.only(
              top: 2.h,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: .5.h,
                horizontal: 2.w,
              ),
              decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColorLight)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Favourite Verses',
                      // textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.w300, fontSize: 13)),
                  SizedBox(
                    height: 1.h,
                  ),
                  favorite == null
                      ? const Center(child: Text('No favorite verses yet'))
                      : _buildFavoriteText(favorite, scriptureService),
                  SizedBox(
                    height: 1.h,
                  ),
                  if (favorite != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _favoriteNavigationButton(
                          theme,
                          Icons.arrow_back,
                          () => setState(() {
                            _favoriteIndex =
                                (_favoriteIndex - 1 + favorites.length) %
                                    favorites.length;
                          }),
                        ),
                        _favoriteNavigationButton(
                          theme,
                          Icons.arrow_forward,
                          () => setState(() {
                            _favoriteIndex =
                                (_favoriteIndex + 1) % favorites.length;
                          }),
                        ),
                      ],
                    )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
        ],
      ),
    );
  }

  Widget _buildVerseOfTheDay(ThemeData theme) {
    final daily = ref.watch(dailyVerseProvider).valueOrNull;
    final quotation = daily?.quotation;
    final reference =
        daily == null ? '' : '${quotation!.quotation} [${daily.translationId}]';
    final favoriteKeys = ref
        .watch(favoritesControllerProvider)
        .map((f) => (f.versionId, f.bookId, f.chapter, f.fromVerse))
        .toSet();
    final isFavorite = daily != null &&
        daily.verses.every((verse) => favoriteKeys.contains(
            (quotation!.versionId, verse.bookId, verse.chapter, verse.verse)));

    void openReader() =>
        openScripture(context, quotation: quotation!.toReaderQuotation());

    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: theme.primaryColor,
          child: InkWell(
            onTap: daily == null ? null : openReader,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              // Same height as before for short verses; longer ones grow it.
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Verse of the Day',
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 10)),
                        Text(serverformat2.format(DateTime.now()),
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 12)),
                      ],
                    ),
                    Text(reference,
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 12)),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
                      child: Center(
                        child: Text(
                          quotation?.text ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w300, fontSize: 15),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      decoration: BoxDecoration(
                          border: Border.all(color: theme.primaryColorLight)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _verseOfTheDayAction(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            isFavorite ? 'Remove favourite' : 'Add favourite',
                            daily == null
                                ? null
                                : () => ref
                                    .read(favoritesControllerProvider.notifier)
                                    .toggleFavorites(
                                      verses: daily.verses,
                                      versionId: quotation!.versionId,
                                    ),
                            color: isFavorite ? theme.primaryColorDark : null,
                          ),
                          _verseOfTheDayAction(
                            Icons.copy,
                            'Copy',
                            daily == null
                                ? null
                                : () async {
                                    await Clipboard.setData(ClipboardData(
                                        text:
                                            '${quotation!.text}\n— $reference'));
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('Copied $reference')),
                                    );
                                  },
                          ),
                          _verseOfTheDayAction(
                            Icons.menu_book_outlined,
                            'Open in reader',
                            daily == null ? null : openReader,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _verseOfTheDayAction(
    IconData icon,
    String tooltip,
    VoidCallback? onPressed, {
    Color? color,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      iconSize: 15,
      icon: Icon(icon, color: color),
    );
  }

  Widget _buildExplore(ThemeData theme) {
    final sample = ref.watch(homeTopicSampleProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Explore',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            TextButton.icon(
              onPressed: () =>
                  ref.read(appTabProvider.notifier).state = AppTab.topics,
              iconAlignment: IconAlignment.end,
              icon: Icon(Icons.arrow_forward,
                  size: 14, color: theme.primaryColorDark),
              label: Text(
                'More',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: theme.primaryColorDark,
                ),
              ),
            ),
          ],
        ),
        if (!sample.hasError)
          SizedBox(
            height: 10.h,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 2.w,
                  crossAxisSpacing: 1.h,
                  crossAxisCount: 2,
                  mainAxisExtent: 40.w),
              scrollDirection: Axis.horizontal,
              itemCount: sample.valueOrNull?.length ?? 6,
              itemBuilder: (context, index) {
                final topic = sample.valueOrNull?[index];
                // Alternate gold and muted borders, column by column.
                final borderColor = (index ~/ 2).isEven == index.isEven
                    ? theme.primaryColorDark
                    : theme.primaryColorLight;
                return InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: topic == null
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TopicScreen(topic: topic),
                            ),
                          ),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: .5.h, horizontal: 3.w),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        border: Border.all(color: borderColor, width: 1.5),
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      topic?.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontWeight: FontWeight.w300, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  /// The most recent history entry that still points at an existing passage,
  /// so a stale entry neither crashes the resume card nor hides older ones.
  ({History entry, ResolvedReference reference})? _latestResolvableEntry(
    List<History>? history,
    ScriptureService scriptureService,
  ) {
    for (final entry in history ?? const <History>[]) {
      final reference = scriptureService.resolve(entry.fromHistory()!);
      if (reference != null) return (entry: entry, reference: reference);
    }
    return null;
  }

  Widget _buildResumeCard(
    BuildContext context,
    History entry,
    ResolvedReference reference,
  ) {
    final theme = Theme.of(context);
    final (:book, :chapter, version: _) = reference;

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Material(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () => openScripture(context, quotation: entry.fromHistory()),
          child: Container(
            height: 6.h,
            padding: EdgeInsets.symmetric(vertical: .5.h, horizontal: 3.w),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Resume Reading: ${book.name} ${chapter.chapter}:${entry.fromVerse + 1}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: theme.primaryColorLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: theme.scaffoldBackgroundColor,
                    size: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteText(
    Favorite favorite,
    ScriptureService scriptureService,
  ) {
    final version = scriptureService.getVersion(favorite.versionId);
    final bookIndex = favorite.bookId - 1;
    final book = bookIndex >= 0 && bookIndex < version.books.length
        ? version.books[bookIndex]
        : null;
    final bookName = book?.name ?? 'Unknown';

    return InkWell(
      onTap: book == null
          ? null
          : () =>
              openScripture(context, quotation: favorite.toReaderQuotation()),
      child: Text(
        '$bookName ${favorite.chapter}:${favorite.fromVerse} - "${favorite.text}"',
        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _favoriteNavigationButton(
    ThemeData theme,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: theme.primaryColorLight),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: theme.primaryColorLight,
          size: 15,
        ),
      ),
    );
  }
}
