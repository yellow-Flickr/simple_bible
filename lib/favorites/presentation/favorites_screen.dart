// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert' show utf8, JsonUtf8Encoder;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_screen_controller.dart';
import 'package:simple_bible/configs/objectbox.dart';
import 'package:simple_bible/objectbox.g.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({
    super.key,
    /* required this.kjv */
  });

  @override
  ConsumerState<FavoritesScreen> createState() => FavoritesScreenState();
}

class FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  // Define the function that scroll to an item
  // void scrollToIndex(int index) {
  //   _controller.jumpTo(
  //     height *
  //         index
  //             .toDouble(), /*  duration: const Duration(milliseconds: 600), curve: Curves.easeIn */
  //   );
  // }

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

    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
           'Favorite Scriptures',
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
        
      body: ListView.builder(
          itemCount: scripture.verses.length,
          padding: EdgeInsets.all(16.0),
        
          // itemPositionsListener: itemPositionsListener,
          // itemScrollController: itemScrollController,
          itemBuilder: ((context, index) => Card(
                // color: theme.cardColor,
                // semanticContainer: false,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                          '${scripture.verses[index].bookName} ${scripture.verses[index].chapter}:${scripture.verses[index].verse}',
                          style: theme.textTheme.labelMedium
                          // TextStyle(
                          //     color: primaryColor, fontWeight: FontWeight.bold)
                          ),
                      SelectableText(
                          utf8.decode(JsonUtf8Encoder()
                              .convert(scripture.verses[index].text)),
                          // softWrap: true,
                          style: theme.textTheme.bodySmall)
                    ],
                  ),
                ),
              ))),
        

    );
  }

}
