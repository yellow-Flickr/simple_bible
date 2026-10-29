import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_screen.dart';
import 'package:simple_bible/reflections/domain/reflection.dart';
import 'package:simple_bible/reflections/presentation/reflections_controller.dart';
import 'package:simple_bible/shared/configs/constants.dart';
import 'package:simple_bible/topics/domain/topic.dart';
import 'package:simple_bible/topics/presentation/topic_screen.dart';
import 'package:simple_bible/topics/presentation/topics_controller.dart';

class ReflectionScreen extends ConsumerWidget {
  const ReflectionScreen({
    super.key,
    required this.reflection,
    required this.date,
  });

  final Reflection reflection;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final verse = ref.watch(reflectionVerseProvider(reflection)).valueOrNull;
    final topic = (ref.watch(topicsProvider).valueOrNull ?? const <Topic>[])
        .where((t) => t.slug == reflection.topicSlug)
        .firstOrNull;
    final reference = verse == null
        ? null
        : '${verse.quotation.quotation} (${verse.translationId})';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reflection',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              serverformat2.format(date),
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
            ),
          ],
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Copy',
            icon: const Icon(Icons.copy),
            onPressed: () => _copy(context, reference, verse?.quotation.text),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 4.h),
        children: [
          Text(
            reflection.title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          if (topic != null) ...[
            SizedBox(height: 1.h),
            Align(
              alignment: Alignment.centerLeft,
              child: TopicChip(topic: topic),
            ),
          ],
          if (verse != null) ...[
            SizedBox(height: 2.h),
            Material(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => openScripture(
                  context,
                  quotation: verse.quotation.toReaderQuotation(),
                ),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        verse.quotation.text,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        reference!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: theme.primaryColorDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: 2.5.h),
          Text(
            reflection.reflection,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          SizedBox(height: 2.5.h),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(10),
              border: Border(
                left: BorderSide(color: theme.primaryColorDark, width: 4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Reflect', theme),
                SizedBox(height: .5.h),
                Text(
                  reflection.question,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.5.h),
          _label("Today's step", theme),
          SizedBox(height: .5.h),
          Text(
            reflection.action,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
          ),
          SizedBox(height: 2.5.h),
          _label('Prayer', theme),
          SizedBox(height: .5.h),
          Text(
            reflection.prayer,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, ThemeData theme) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 1.2,
          color: theme.primaryColorDark,
        ),
      );

  Future<void> _copy(
    BuildContext context,
    String? reference,
    String? verseText,
  ) async {
    final text = [
      reflection.title,
      if (verseText != null) '$verseText\n— $reference',
      reflection.reflection,
      reflection.question,
      reflection.action,
      reflection.prayer,
    ].join('\n\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reflection copied')),
    );
  }
}
