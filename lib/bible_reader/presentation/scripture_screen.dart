// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_screen_controller.dart';
import 'package:simple_bible/configs/objectbox.dart';
import 'package:simple_bible/objectbox.g.dart';

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
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  // Define the function that scroll to an item
  // void scrollToIndex(int index) {
  //   _controller.jumpTo(
  //     height *
  //         index
  //             .toDouble(), /*  duration: const Duration(milliseconds: 600), curve: Curves.easeIn */
  //   );
  // }
  bool canPop = false;

  Timer? _hideTimer;

  void _showFABs() {
    ref.watch(showFAB);

    ref.read(showFAB.notifier).update((old) => !old);

    // Cancel any existing timer
    _hideTimer?.cancel();

    // Auto-hide after 5 seconds
    // if (fabShowing) {
    _hideTimer = Timer(Duration(seconds: 5), () {
      ref.read(showFAB.notifier).update((old) => false);
    });
    // }
  }

  // void _hideFABs() {
  //   if (_showFAB) {
  //     setState(() {
  //       _showFAB = false;
  //     });
  //     _hideTimer?.cancel();
  //   }
  // }

  void _scrollToVerse(int index) {
    // Calculate the offset for the verse index (this is a simple calculation assuming each verse has similar height)
    double offset =
        index * 50.0; // Adjust this based on the height of each verse's widget
    _scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // final affordbox = objectBox.objStore.box<Affordability>();
    // itemPositionsListener.itemPositions.addListener(() {
    //   Provider.of<LocalState>(context, listen: false).book =
    //       Provider.of<LocalState>(context, listen: false)
    //           .version
    //           .books![itemPositionsListener.itemPositions.value.last.index];

    //   Provider.of<LocalState>(context, listen: false).chapter =
    //       Provider.of<LocalState>(context, listen: false)
    //           .version
    //           .books![itemPositionsListener.itemPositions.value.last.index]
    //           .chapter!;

    //   // log(itemPositionsListener.itemPositions.value.last.index.toString());
    // });

    Future.delayed(Durations.medium4, () {
      _showFABs();
    });

    // WidgetsBinding.instance.addPostFrameCallback((callback) {
    //   _showFABs();
    // });
    super.initState();
  }

// @override
//   void deactivate() {
//     // TODO: implement deactivate
//     ref.read(selection.notifier).update((val) => val + 10);

//     super.deactivate();
//   }

  Versions getVersionByID(int uid) {
    // final scripture = ref.watch(versionProvider);

    final query = ref
        .watch(objectBoxProvider)
        .objStore
        .box<Versions>()
        .query(Versions_.id.equals(uid))
        .build();
    final user = query.findFirst();
    query.close();
    return user!;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final controller = ref.watch(scriptureScreenProvider);
    final fontSize = ref.watch(fontSizeProvider);
    // final scripture = ref
    //     .watch(objectBoxProvider)
    //     .objStore
    //     .box<Versions>().
    //     .books[controller.bookId]
    //     .chapters[controller.chapter];

    final scripture = getVersionByID(controller.versionId)
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
        onTap: () => _showFABs(),
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

          body: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Render all verses as one continuous text
                Text.rich(
                  TextSpan(
                    style: theme.textTheme.bodySmall,
                    children: List.generate(
                        scripture.verses.length,
                        (index) => TextSpan(children: [
                              TextSpan(text: ' '),
                              WidgetSpan(
                                child: Transform.translate(
                                  offset: const Offset(-1.0, -6.0),
                                  child: Text(
                                    (index + 1).toString(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: fontSize, color: Colors.red),
                                  ),
                                ),
                              ),
                              TextSpan(
                                  text: scripture.verses[index].text,
                                  // softWrap: true,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      height: 2, fontSize: fontSize + 4))
                            ])),
                  ),
                ),
              ],
            ),
          ),

          // ScrollablePositionedList.builder(
          //     itemCount: scripture.verses.length,
          //     itemPositionsListener: itemPositionsListener,
          //     itemScrollController: itemScrollController,
          //     itemBuilder: ((context, index) => Card(
          //           color: theme.cardColor,
          //           semanticContainer: false,
          //           child: Container(
          //             padding: const EdgeInsets.all(10),
          //             margin: const EdgeInsets.all(10),
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Text(
          //                     '${scripture.verses[index].bookName} ${scripture.verses[index].chapter}:${scripture.verses[index].verse}',
          //                     style: theme.textTheme.bodyMedium
          //                     // TextStyle(
          //                     //     color: primaryColor, fontWeight: FontWeight.bold)
          //                     ),
          //                 Text(
          //                     utf8.decode(JsonUtf8Encoder()
          //                         .convert(scripture.verses[index].text)),
          //                     softWrap: true,
          //                     style: theme.textTheme.bodySmall)
          //               ],
          //             ),
          //           ),
          //         ))),

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

    final scriptures =
        ref.watch(objectBoxProvider).objStore.box<Versions>().getAll();
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
    final scripture = getVersionByID(controller.versionId);
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
    final scripture = getVersionByID(controller.versionId);

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
  ) {
    final theme = Theme.of(context);
    // final scripture = ref.watch(versionProvider);
    // final controller = ref.watch(scriptureScreenProvider);
    // final scripture = getVersionByID(controller.versionId);

    showModalBottomSheet(
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
          return BottomSheet(
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
                          style: theme.textTheme.titleLarge
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 1.h, horizontal: 3.w),
                                height: 5.h,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.grey.shade400),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (ref.watch(fontSizeProvider) <= 8) {
                                          return;
                                        }
                                        ref
                                            .read(fontSizeProvider.notifier)
                                            .update((cb) => cb - 1);
                                      },
                                      child: Text(
                                        'A',
                                        style: theme.textTheme.labelSmall,
                                      ),
                                    ),
                                    VerticalDivider(),
                                    GestureDetector(
                                        onTap: () {
                                          if (ref.watch(fontSizeProvider) >=
                                              16) {
                                            return;
                                          }
                                          ref
                                              .read(fontSizeProvider.notifier)
                                              .update((cb) => cb + 1);
                                        },
                                        child: Text('A'))
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 3.w,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h, horizontal: 3.w),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Icon(Icons.article),
                            ),
                            SizedBox(
                              width: 3.w,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.h, horizontal: 3.w),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Icon(Icons.light_mode),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.brightness_7,
                              size: 14,
                            ),
                            Expanded(
                              flex: 5,
                              child: Slider(
                                value: .5,
                                onChanged: (value) {},
                              ),
                            ),
                            Icon(
                              Icons.brightness_7_outlined,
                              size: 14,
                            )
                          ],
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Container(
                          padding: EdgeInsetsDirectional.symmetric(
                              horizontal: 3.w, vertical: .5.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey.shade400,
                          ),
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
                                  style: theme.textTheme.displaySmall?.copyWith(
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
                                    'Line Height',
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
                                          value: .5,
                                          onChanged: (value) {},
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
                                    'Line Height',
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
                                          value: .5,
                                          onChanged: (value) {},
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
                                    'Line Height',
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
                                          value: .5,
                                          onChanged: (value) {},
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
          );
        });
  }

  void _verses(BuildContext context) {
    final theme = Theme.of(context);

    final controller = ref.watch(scriptureScreenProvider);
    final scripture = getVersionByID(controller.versionId);
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
