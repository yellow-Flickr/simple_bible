import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/topics/domain/topic.dart';
import 'package:simple_bible/topics/presentation/topic_screen.dart';
import 'package:simple_bible/topics/presentation/topics_controller.dart';

class TopicCatalogScreen extends ConsumerStatefulWidget {
  const TopicCatalogScreen({super.key});

  @override
  ConsumerState<TopicCatalogScreen> createState() => _TopicCatalogScreenState();
}

class _TopicCatalogScreenState extends ConsumerState<TopicCatalogScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topicsAsync = ref.watch(topicsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Topics',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: kToolbarHeight - 2.h,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(3.w, 1.h, 3.w, 1.h),
            child: TextField(
              onChanged: (value) => setState(() => _query = value.trim()),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search topics',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.cardColor,
                contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: theme.primaryColorDark),
                ),
              ),
            ),
          ),
          Expanded(
            child: topicsAsync.when(
              data: (topics) {
                final query = _query.toLowerCase();
                final filtered = query.isEmpty
                    ? topics
                    : topics
                        .where((t) => t.name.toLowerCase().contains(query))
                        .toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text('No matching topics'));
                }
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(3.w, 1.h, 3.w, 3.h),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
                  itemBuilder: (context, index) =>
                      _TopicRow(topic: filtered[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Unable to load topics.'),
                    TextButton(
                      onPressed: () => ref.invalidate(topicsProvider),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topic});

  final Topic topic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      elevation: 1,
      shadowColor: theme.shadowColor.withValues(alpha: .3),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TopicScreen(topic: topic)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  topic.name,
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                ),
              ),
              Text(
                '${topic.references.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.primaryColorDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 2.w),
              Icon(Icons.chevron_right, color: theme.primaryColorLight),
            ],
          ),
        ),
      ),
    );
  }
}
