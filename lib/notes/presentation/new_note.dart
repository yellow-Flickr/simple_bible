import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NewNote extends ConsumerStatefulWidget {
  const NewNote({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => NewNoteState();
}

class NewNoteState extends ConsumerState<NewNote> {
  final TextEditingController _controller = TextEditingController();
  String _title = 'New Note';
  String _body = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    final text = _controller.text;

    // Split text into first line (title) and the rest (body)
    final lines = text.split('\n');
    final title = lines.isNotEmpty ? lines.first.trim() : 'New Note';

    final body = lines.length > 1 ? lines.sublist(1).join('\n').trim() : '';

    setState(() {
      _title = title.isEmpty ? 'New Note':title;
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
          IconButton(onPressed: () {}, icon: Icon(Icons.undo,size: 18,)),
          IconButton(onPressed: () {}, icon: Icon(Icons.redo,size: 18,)),
          IconButton(onPressed: () {}, icon: Icon(Icons.share,size: 18,)),
          TextButton(
            onPressed: () {},
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
            hintText: 'Start typing your note...',
            border: InputBorder.none,
          ),
          // style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
