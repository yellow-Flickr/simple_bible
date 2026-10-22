import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart'
    show scriptureServiceProvider;
import 'package:simple_bible/bible_reader/presentation/scripture_screen.dart';
import 'package:simple_bible/history/presentation/history_controller.dart';
import 'package:simple_bible/shared/configs/constants.dart';
import 'package:simple_bible/shared/configs/extensions.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(historyControllerProvider);
    final scriptureService = ref.read(scriptureServiceProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          'Reading History',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: kToolbarHeight - 2.h,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 3.w),
            child: const Icon(Icons.search),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return const Center(child: Text('No reading history yet'));
          }

          return ListView.separated(
            itemCount: history.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final entry = history[index];
              final version = scriptureService.getVersion(entry.versionId);
              final book = version.books[entry.bookId];
              final chapter = book.chapters[entry.chapter];
              final timestamp = DateTime.parse(entry.dateTime);
              final verseLabel =
                  entry.fromVerse == null ? '' : ':${entry.fromVerse! + 1}';

              return ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScriptureScreen(
                      quotation: Quotation(
                        versionId: entry.versionId,
                        bookId: entry.bookId,
                        chapter: entry.chapter,
                        fromVerse: entry.fromVerse ?? 0,
                      ),
                    ),
                  ),
                ),
                leading: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    border: BoxBorder.all(color: theme.primaryColorDark),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    book.name.initials,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text('${book.name} ${chapter.chapter}$verseLabel'),
                subtitle: Text(
                  '${version.versionName} · ${serverformat.format(timestamp)}',
                ),
              );
            },
            separatorBuilder: (context, index) {
              if (index + 1 >= history.length) return const SizedBox.shrink();

              final current = DateTime.parse(history[index].dateTime);
              final next = DateTime.parse(history[index + 1].dateTime);
              if (current.year == next.year &&
                  current.month == next.month &&
                  current.day == next.day) {
                return const SizedBox.shrink();
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Divider(
                      thickness: .5,
                      color: theme.dividerColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    color: theme.scaffoldBackgroundColor,
                    child: Text(
                      serverformat2.format(next),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load reading history.'),
              TextButton(
                onPressed: () => ref.invalidate(historyControllerProvider),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
