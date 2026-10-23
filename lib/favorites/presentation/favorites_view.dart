// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart'
    show scriptureServiceProvider;
import 'package:simple_bible/bible_reader/presentation/scripture_screen.dart';
import 'package:simple_bible/favorites/presentation/favorites_controller.dart';

class FavoritesView extends ConsumerWidget {
  const FavoritesView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favorites = ref.watch(favoritesControllerProvider);
    final scriptureService = ref.read(scriptureServiceProvider);

    if (favorites.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(
            'Favorite Scriptures',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          toolbarHeight: kToolbarHeight - 2.h,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: const Center(
          child: Text('No favorite verses yet'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          'Favorite Scriptures',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: kToolbarHeight - 2.h,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView.separated(
        itemCount: favorites.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final favorite = favorites[index];
          final version = scriptureService.getVersion(favorite.versionId);
          final bookIndex = favorite.bookId - 1;
          final book = bookIndex >= 0 && bookIndex < version.books.length
              ? version.books[bookIndex]
              : null;
          final bookName = book?.name ?? 'Unknown';
          final timestamp = DateTime.fromMillisecondsSinceEpoch(favorite.date);

          return ListTile(
            onTap: book == null
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScriptureScreen(
                          quotation: favorite.copyWith(
                            bookId: bookIndex,
                            chapter: favorite.chapter - 1,
                            fromVerse: favorite.fromVerse - 1,
                          ),
                        ),
                      ),
                    ),
            leading: Container(
              width: 10.w,
              height: 10.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.primaryColorDark),
              ),
              child: Text(
                bookName.substring(
                    0, bookName.length > 2 ? 2 : bookName.length),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              '$bookName ${favorite.chapter}:${favorite.fromVerse}',
              style: theme.textTheme.titleSmall,
            ),
            subtitle: Text(
              favorite.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              DateFormat('MMM d').format(timestamp),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(height: 1),
      ),
    );
  }
}
