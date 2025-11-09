// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert' show utf8, JsonUtf8Encoder;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/configs/objectbox.dart';
import 'package:simple_bible/favorites/domain/favorite.dart';
import 'package:simple_bible/objectbox.g.dart';
import 'package:simple_bible/user_space/application/user_space_service.dart';

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
    final favorites =
        ref.read(objectBoxProvider).objStore.box<Favorite>().getAll();

    final scripture = getVersionByID(userSpace.preferredTranslation);

    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Favorite Scriptures',
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
          itemCount: favorites.length,
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
                          '${scripture.books[favorites[index].bookId].chapters[favorites[index].verse].verses[index].bookName} ${scripture.books[favorites[index].bookId].chapters[favorites[index].verse].verses[index].chapter}:${scripture.books[favorites[index].bookId].chapters[favorites[index].verse].verses[index].verse}',
                          style: theme.textTheme.labelMedium
                          // TextStyle(
                          //     color: primaryColor, fontWeight: FontWeight.bold)
                          ),
                      SelectableText(
                          utf8.decode(JsonUtf8Encoder().convert(scripture
                              .books[favorites[index].bookId]
                              .chapters[favorites[index].verse]
                              .verses[index]
                              .text)),
                          // softWrap: true,
                          style: theme.textTheme.bodySmall)
                    ],
                  ),
                ),
              ))),
    );
  }
}
