// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/notes/presentation/note_editor.dart';
import 'package:simple_bible/notes/presentation/notes_controller.dart';

class NoteList extends ConsumerWidget {
  const NoteList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);
    final notesAsync = ref.watch(notesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Notes',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        toolbarHeight: kToolbarHeight - 2.h,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 3.w),
            child: Icon(Icons.view_list),
          ),
        ],
      ),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(child: Text('No notes yet'));
          }

          return ListView.separated(
            itemCount: notes.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) => NoteCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEditor(notes: notes[index]),
                ),
              ),
              title: notes[index].title,
              subtitle: notes[index].content,
              date: DateTime.parse(notes[index].lastModified),
            ),
            separatorBuilder: (context, index) => const Divider(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load notes.'),
              TextButton(
                onPressed: () => ref.invalidate(notesControllerProvider),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NoteEditor()),
        ),
        child: const Icon(Icons.note_alt),
      ),
    );
  }
}

// note_card.dart

class NoteCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final DateTime date;
  final VoidCallback? onTap;

  const NoteCard({
    super.key,
    required this.title,
    required this.date,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateText = DateFormat('M/d/yy').format(date);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: .6.h),
            Text(
              dateText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            SizedBox(height: .6.h),
            Text(
              subtitle?.isNotEmpty == true ? subtitle! : "No additional text",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
