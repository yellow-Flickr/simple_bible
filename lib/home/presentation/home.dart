import 'package:flutter/material.dart';
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
import 'package:simple_bible/shared/configs/extensions.dart';
import 'package:simple_bible/favorites/presentation/favorites_view.dart';
import 'package:simple_bible/history/domain/history.dart';
import 'package:simple_bible/history/presentation/history_screen.dart';
import 'package:simple_bible/notes/presentation/note_list.dart';

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
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Icon(Icons.settings_outlined),
          ),
        ],
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        // shrinkWrap: true,
        children: [
          Container(
            height: 28.h,
            padding: EdgeInsets.only(
              top: 2.h,
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                // clipBehavior: Clip.hardEdge,
                child: ColoredBox(
                  color: theme.primaryColor,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Verse of the Day',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 10)),
                                  Text('Sat, 07 Sep 2019',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12))
                                ],
                              ),
                              Text('John 1:01 [KJV]',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12))
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  'In the beginning was the word, and the word was with God, and the word was God.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 15)),
                              // Text('John 1:1 [KJV]',
                              //     style: TextStyle(
                              //         fontWeight: FontWeight.w500,
                              //         fontSize: 10))
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 2.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 1.h),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: theme.primaryColorLight)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 15,
                              ),
                              Icon(
                                Icons.share,
                                size: 15,
                              ),
                              Icon(
                                Icons.more_horiz_rounded,
                                size: 15,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )),
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
              height: 10.h,
              decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColorLight)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Flexible(
                    child: Text(
                      'God\'s plan for us is filled with hope.\nReflect on HIS assurances and provisions.',
                      // textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
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

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScriptureScreen(
                              quotation: quote,
                            ),
                          ));
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
                    'Bible Reader',
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
                          builder: (context) => NoteList(),
                        )),
                    child: Container(
                      width: 20.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.primaryColorLight)),
                      child: Lottie.asset(
                        LottieAssets.notes,
                        fit: BoxFit.contain,
                        // height: kToolbarHeight,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: .5.h,
                  ),
                  Text(
                    'Notes',
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Explore',
                  // textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              SizedBox(
                height: 1.h,
              ),
              SizedBox(
                height: 10.h,
                child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 2.w,
                      crossAxisSpacing: 1.h,
                      crossAxisCount: 2,
                      mainAxisExtent: 40.w),
                  scrollDirection: Axis.horizontal,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: .5.h, horizontal: 3.w),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.primaryColorDark,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        'Love',
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: .5.h, horizontal: 3.w),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.primaryColorLight,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        'Anger',
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: .5.h, horizontal: 3.w),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.primaryColorLight,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        'Fear',
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: .5.h, horizontal: 3.w),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.primaryColorDark,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        'Desperation',
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: .5.h, horizontal: 3.w),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.primaryColorDark,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        'Hope',
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: .5.h, horizontal: 3.w),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.primaryColorLight,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        'Family',
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
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
              height: 15.h,
              decoration: BoxDecoration(
                  border: Border.all(color: theme.primaryColorLight)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Favourite Verses',
                      // textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.w300, fontSize: 13)),
                  SizedBox(
                    height: 1.h,
                  ),
                  Flexible(
                    child: favorite == null
                        ? const Center(child: Text('No favorite verses yet'))
                        : _buildFavoriteText(favorite, scriptureService),
                  ),
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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ScriptureScreen(quotation: entry.fromHistory()),
            ),
          ),
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
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScriptureScreen(
                    quotation: favorite.toReaderQuotation(),
                  ),
                ),
              ),
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
