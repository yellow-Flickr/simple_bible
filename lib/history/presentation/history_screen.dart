// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/configs/constants.dart';
import 'package:simple_bible/configs/extensions.dart';
import 'package:simple_bible/configs/objectbox.dart';
import 'package:simple_bible/history/domain/history.dart';
import 'package:simple_bible/objectbox.g.dart';
import 'package:simple_bible/user_space/application/user_space_service.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({
    super.key,
    /* required this.kjv */
  });

  @override
  ConsumerState<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends ConsumerState<HistoryScreen> {
  // Define the function that scroll to an item
  // void scrollToIndex(int index) {
  //   _controller.jumpTo(
  //     height *
  //         index
  //             .toDouble(), /*  duration: const Duration(milliseconds: 600), curve: Curves.easeIn */
  //   );
  // }

  Versions getVersionByID(int uid) {
    final query = ref
        .read(objectBoxProvider)
        .objStore
        .box<Versions>()
        .query(Versions_.id.equals(uid))
        .build();
    final version = query.findFirst();
    query.close();
    return version!;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final userSpace = ref.watch(userSpaceProvider);
    final history = historySamples;
    // ref.read(objectBoxProvider).objStore.box<History>().getAll();

    final scripture = getVersionByID(userSpace.preferredTranslation);

    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Reading History',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        toolbarHeight: kToolbarHeight - 2.h,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 3.w),
            child: Icon(Icons.search),
          ),
        ],
      ),

      body: ListView.separated(
        itemCount: history.length,
        padding: EdgeInsets.all(16.0),

        // itemPositionsListener: itemPositionsListener,
        // itemScrollController: itemScrollController,
        itemBuilder: ((context, index) => ListTile(
                  leading: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                        border: BoxBorder.all(
                            color: theme.primaryColorDark, width: 1),
                        borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: Text(
                        scripture
                            .books[history[index].bookId]
                            .chapters[history[index].verse]
                            .verses[index]
                            .bookName
                            .initials,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  title: Text(
                      '${scripture.books[history[index].bookId].chapters[history[index].verse].verses[index].bookName} ${scripture.books[history[index].bookId].chapters[history[index].verse].verses[index].chapter}'),
                  subtitle: Text(serverformat
                      .format(DateTime.parse(history[index].dateTime))),
                )

            // Card(
            //       // color: theme.cardColor,
            //       // semanticContainer: false,
            //       child: Container(
            //         padding: const EdgeInsets.all(10),
            //         margin: const EdgeInsets.all(10),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             SelectableText(
            //                 '${scripture.books[history[index].bookId].chapters[history[index].verse].verses[index].bookName} ${scripture.books[history[index].bookId].chapters[history[index].verse].verses[index].chapter}:${scripture.books[history[index].bookId].chapters[history[index].verse].verses[index].verse}',
            //                 style: theme.textTheme.labelMedium
            //                 // TextStyle(
            //                 //     color: primaryColor, fontWeight: FontWeight.bold)
            //                 ),
            //             SelectableText(
            //                 utf8.decode(JsonUtf8Encoder().convert(scripture
            //                     .books[history[index].bookId]
            //                     .chapters[history[index].verse]
            //                     .verses[index]
            //                     .text)),
            //                 // softWrap: true,
            //                 style: theme.textTheme.bodySmall)
            //           ],
            //         ),
            //       ),
            //     )

            ),
        separatorBuilder: (BuildContext context, int index) =>
            ((DateTime.parse(history[index].dateTime.toString()).day !=
                        DateTime.parse(history[index + 1].dateTime.toString())
                            .day) &&
                    index < history.length)
                ? Stack(alignment: Alignment.center, children: [
                    Center(
                      child: Divider(
                        thickness: .5,
                        color: theme.dividerColor,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      color: theme.scaffoldBackgroundColor,
                      // height: 2.h,
                      // width: 15.w,
                      // color: theme.dividerColor,

                      child: Text(
                        serverformat2.format(
                            DateTime.parse(history[index + 1].dateTime)),
                        style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w400, fontSize: 8),
                      ),
                    ),
                  ])
                : SizedBox.shrink(),
      ),
    );
  }
}
