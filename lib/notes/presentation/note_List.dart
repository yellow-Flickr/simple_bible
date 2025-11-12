// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/configs/objectbox.dart';
import 'package:simple_bible/notes/domain/notes.dart';
import 'package:simple_bible/notes/presentation/note_editor.dart';
import 'package:simple_bible/objectbox.g.dart';

class NoteList extends ConsumerStatefulWidget {
  const NoteList({
    super.key,
    /* required this.kjv */
  });

  @override
  ConsumerState<NoteList> createState() => NoteListState();
}

class NoteListState extends ConsumerState<NoteList> {
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
    final notes = List.from(notesSamples
      ..sort((a, b) => DateTime.parse(a.lastModified)
          .compareTo(DateTime.parse(b.lastModified)))
      ..reversed);
    // ref.read(objectBoxProvider).objStore.box<Notes>().getAll()
    //   ..sort((a, b) => DateTime.parse(a.lastModified)
    //       .compareTo(DateTime.parse(b.lastModified)))
    //   ..reversed;

    return Scaffold(
      // backgroundColor: Colors.black,
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

      body: ListView.separated(
        itemCount: notes.length,
        padding: EdgeInsets.all(16.0),
        itemBuilder: ((context, index) => NoteCard(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEditor(
                    notes: notes[index],
                  ),
                )),
            title: notes[index].title,
            subtitle: notes[index].content,
            date: (DateTime.parse(notes[index].lastModified)))),
        separatorBuilder: (BuildContext context, int index) => Divider(),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        onPressed: () {},
        child: IconButton.filledTonal(
            iconSize: 30,
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEditor(),
                )),
            icon: Icon(Icons.note_alt)),
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
