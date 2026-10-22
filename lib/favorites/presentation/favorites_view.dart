// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/favorites/presentation/favorites_controller.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart'
    show scriptureServiceProvider;
import 'package:simple_bible/user_space/application/user_space_service.dart';

class FavoritesView extends ConsumerWidget {
  const FavoritesView({
    super.key,
    /* required this.kjv */
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);
    final userSpace = ref.watch(userSpaceProvider);
    final favorites = ref.watch(favoritesControllerProvider);
    final scripture = ref
        .read(scriptureServiceProvider)
        .getVersion(userSpace.preferredTranslation);

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
                        '${scripture.books[favorites[index].bookId].name} '
                        '${favorites[index].chapter}:${favorites[index].fromVerse}',
                        style: theme.textTheme.labelMedium,
                      ),
                      SelectableText(
                        favorites[index].text,
                        style: theme.textTheme.bodySmall,
                      )
                    ],
                  ),
                ),
              ))),
    );
  }
}
