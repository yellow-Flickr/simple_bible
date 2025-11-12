import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/configs/objectbox.dart' show objectBoxProvider;
import 'package:simple_bible/notes/domain/notes.dart';
import 'package:uuid/v4.dart';

class NoteEditor extends ConsumerStatefulWidget {
  final Notes? notes;
  const NoteEditor({super.key, this.notes});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => NoteEditorState();
}

class NoteEditorState extends ConsumerState<NoteEditor> {
  final TextEditingController _controller = TextEditingController();
  String _title = 'New Note';
  String _body = '';

  @override
  void initState() {
    super.initState();

// _controller = RichTextController(
//       patternMatchMap: {
//         // Matches everything up to the first newline (or the whole text if no newline)
//         RegExp(r'^[^\n]*'): const TextStyle(
//           fontWeight: FontWeight.bold,
//           color: Colors.blue,
//         ),
//       },
//       onMatch: (matches) => print(matches),
//     );
  


    _controller.addListener(_handleTextChange);
    if (widget.notes != null) {
      _controller.text = "${widget.notes!.title}\n${widget.notes!.content}";
      // _title = widget.notes!.title;
      // _body
    }
  }

  void _handleTextChange() {
    final text = _controller.text;

    // Split text into first line (title) and the rest (body)
    final lines = text.split('\n');
    final title = lines.isNotEmpty ? lines.first.trim() : 'New Note';
    final body = lines.length > 1 ? lines.sublist(1).join('\n').trim() : '';

    setState(() {
      _title = title.isEmpty ? 'New Note' : title;
      _body = body;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(_title),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.undo,
                size: 18,
              )),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.redo,
                size: 18,
              )),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.share,
                size: 18,
              )),
          TextButton(
            onPressed: () => editingComplete(),
            child: Text('Done'),
            // icon: Icon(Icons.done),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: .7.h),
        child: TextField(
          controller: _controller,

          maxLines: null, // allows multiple lines
          decoration: InputDecoration(
            hintText: 'What would you like to note?',
            border: InputBorder.none,
          ),
          // style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void editingComplete() {
    Notes note = Notes(
        id: UuidV4().generate(),
        createdAt: DateTime.now().toIso8601String(),
        lastModified: DateTime.now().toIso8601String(),
        title: _title,
        content: _body,
        reference: []);
    if (widget.notes != null) {
      note = note.copywith(
        id: widget.notes!.id,
        uid: widget.notes!.uid,
        createdAt: widget.notes!.createdAt,
      );
    }
    ref.read(objectBoxProvider).objStore.box<Notes>().putAsync(note);
  }
}
