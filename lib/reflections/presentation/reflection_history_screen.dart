import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/reflections/domain/reflection.dart';
import 'package:simple_bible/reflections/presentation/reflection_screen.dart';
import 'package:simple_bible/reflections/presentation/reflections_controller.dart';
import 'package:simple_bible/shared/configs/constants.dart';
import 'package:simple_bible/topics/domain/topic.dart';
import 'package:simple_bible/topics/presentation/topics_controller.dart';

class ReflectionHistoryScreen extends ConsumerStatefulWidget {
  const ReflectionHistoryScreen({super.key});

  @override
  ConsumerState<ReflectionHistoryScreen> createState() =>
      _ReflectionHistoryScreenState();
}

class _ReflectionHistoryScreenState
    extends ConsumerState<ReflectionHistoryScreen> {
  String? _topicFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(reflectionHistoryProvider);
    final topicsBySlug = {
      for (final t in ref.watch(topicsProvider).valueOrNull ?? const <Topic>[])
        t.slug: t,
    };
    String topicName(String slug) => topicsBySlug[slug]?.name ?? slug;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reflections',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: kToolbarHeight - 2.h,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return const Center(
              child: Text('Reflections you see each day will appear here.'),
            );
          }

          final slugs = {for (final e in history) e.reflection.topicSlug}
              .toList()
            ..sort((a, b) => topicName(a).compareTo(topicName(b)));
          final filter = slugs.contains(_topicFilter) ? _topicFilter : null;
          final entries = filter == null
              ? history
              : history.where((e) => e.reflection.topicSlug == filter).toList();

          return Column(
            children: [
              if (slugs.length > 1)
                SizedBox(
                  height: 6.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    children: [
                      _filterChip('All', filter == null, () {
                        setState(() => _topicFilter = null);
                      }),
                      for (final slug in slugs)
                        _filterChip(topicName(slug), filter == slug, () {
                          setState(() => _topicFilter = slug);
                        }),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(3.w, 1.h, 3.w, 3.h),
                  itemCount: entries.length,
                  separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
                  itemBuilder: (context, index) => _HistoryRow(
                    entry: entries[index],
                    topicName: topicName(entries[index].reflection.topicSlug),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load reflections.'),
              TextButton(
                onPressed: () => ref.invalidate(reflectionHistoryProvider),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(right: 2.w),
      child: Center(
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
          showCheckmark: false,
          selectedColor: theme.primaryColorDark,
          labelStyle: TextStyle(
            fontSize: 12,
            color: selected ? Colors.black : null,
          ),
          shape: StadiumBorder(side: BorderSide(color: theme.dividerColor)),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.topicName});

  final ReflectionEntry entry;
  final String topicName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReflectionScreen(
              reflection: entry.reflection,
              date: entry.date,
            ),
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dayLabel(entry.date),
                      style:
                          TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
                    ),
                    SizedBox(height: .3.h),
                    Text(
                      entry.reflection.title,
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    SizedBox(height: .3.h),
                    Text(
                      topicName,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: theme.primaryColorDark,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.primaryColorLight),
            ],
          ),
        ),
      ),
    );
  }

  static String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    // Rounded so a daylight-saving change doesn't shift the day count.
    final daysAgo = (today.difference(day).inHours / 24).round();
    if (daysAgo == 0) return 'Today';
    if (daysAgo == 1) return 'Yesterday';
    return serverformat2.format(date);
  }
}
