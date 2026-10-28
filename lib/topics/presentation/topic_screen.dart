import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart'
    show scriptureServiceProvider;
import 'package:simple_bible/bible_reader/presentation/scripture_screen.dart';
import 'package:simple_bible/favorites/presentation/favorites_controller.dart';
import 'package:simple_bible/notes/presentation/note_editor.dart';
import 'package:simple_bible/topics/domain/topic.dart';
import 'package:simple_bible/topics/presentation/topics_controller.dart';
import 'package:simple_bible/user_space/application/user_space_service.dart';

class TopicScreen extends ConsumerWidget {
  const TopicScreen({super.key, required this.topic});

  final Topic topic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final versesAsync = ref.watch(topicVersesProvider(topic.slug));
    final allTopics = ref.watch(topicsProvider).valueOrNull ?? const <Topic>[];
    final related = [
      for (final slug in topic.relatedSlugs)
        ...allTopics.where((t) => t.slug == slug),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          topic.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: kToolbarHeight - 2.h,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: _VersionButton(
              label: versesAsync.valueOrNull?.firstOrNull?.translationId,
            ),
          ),
        ],
      ),
      body: versesAsync.when(
        data: (verses) => ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          itemCount: verses.length + 1,
          separatorBuilder: (context, index) => SizedBox(height: 2.h),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _Header(
                count: verses.length,
                related: related,
              );
            }
            return _TopicVerseCard(topicVerse: verses[index - 1]);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load this topic.'),
              TextButton(
                onPressed: () =>
                    ref.invalidate(topicVersesProvider(topic.slug)),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VersionButton extends ConsumerWidget {
  const _VersionButton({required this.label});

  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return TextButton.icon(
      onPressed: () => _showVersions(context, ref),
      icon: Icon(Icons.translate, size: 16, color: theme.primaryColorDark),
      label: Text(
        label ?? '',
        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showVersions(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final versions = ref.read(scriptureServiceProvider).getVersions();
    final selectedId = ref.read(preferredVersionIdProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        itemCount: versions.length,
        itemBuilder: (context, index) {
          final version = versions[index];
          final selected = version.id == selectedId;
          return ListTile(
            onTap: () {
              ref
                  .read(userSpaceProvider.notifier)
                  .setPreferredTranslation(version.id);
              Navigator.pop(context);
            },
            title: Text(
              version.versionName,
              style: theme.textTheme.bodyMedium!
                  .copyWith(color: theme.primaryColorLight),
            ),
            trailing: selected
                ? Icon(Icons.check, color: theme.primaryColorDark)
                : null,
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.related});

  final int count;
  final List<Topic> related;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$count verses',
          style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13),
        ),
        if (related.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Text(
            'Related topics',
            style: theme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w300),
          ),
          SizedBox(height: .5.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: [
              for (final topic in related) TopicChip(topic: topic),
            ],
          ),
        ],
      ],
    );
  }
}

class _TopicVerseCard extends ConsumerWidget {
  const _TopicVerseCard({required this.topicVerse});

  final TopicVerse topicVerse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final quotation = topicVerse.quotation;
    final reference = '${quotation.quotation} (${topicVerse.translationId})';

    final favoriteKeys = ref
        .watch(favoritesControllerProvider)
        .map((f) => (f.versionId, f.bookId, f.chapter, f.fromVerse))
        .toSet();
    final isFavorite = topicVerse.verses.every((verse) => favoriteKeys
        .contains((quotation.versionId, verse.bookId, verse.chapter, verse.verse)));

    void openReader() => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ScriptureScreen(quotation: quotation.toReaderQuotation()),
          ),
        );

    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: .08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quotation.text,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          SizedBox(height: 1.5.h),
          InkWell(
            onTap: openReader,
            child: Text(
              reference,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: theme.primaryColorDark,
              ),
            ),
          ),
          if (topicVerse.otherTopics.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: [
                for (final topic in topicVerse.otherTopics)
                  TopicChip(topic: topic),
              ],
            ),
          ],
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: 'Add note',
                icon: const Icon(Icons.edit_note),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteEditor(initialText: quotation),
                  ),
                ),
              ),
              IconButton(
                tooltip: isFavorite ? 'Remove favourite' : 'Add favourite',
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? theme.primaryColorDark : null,
                ),
                onPressed: () => ref
                    .read(favoritesControllerProvider.notifier)
                    .toggleFavorites(
                      verses: topicVerse.verses,
                      versionId: quotation.versionId,
                    ),
              ),
              IconButton(
                tooltip: 'Copy',
                icon: const Icon(Icons.copy),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: '${quotation.text}\n— $reference'),
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied $reference')),
                  );
                },
              ),
              IconButton(
                tooltip: 'Open in reader',
                icon: const Icon(Icons.menu_book_outlined),
                onPressed: openReader,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A rounded topic label that opens [topic].
class TopicChip extends StatelessWidget {
  const TopicChip({super.key, required this.topic});

  final Topic topic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.primaryColor,
      shape: StadiumBorder(side: BorderSide(color: theme.dividerColor)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TopicScreen(topic: topic)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: .6.h),
          child: Text(
            topic.name,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
