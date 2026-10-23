import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/notes/domain/notes.dart';
import 'package:simple_bible/notes/presentation/notes_controller.dart';
import 'package:uuid/v4.dart';

class NoteEditor extends ConsumerStatefulWidget {
  final Notes? notes;
  final Quotation? initialText;
  const NoteEditor({super.key, this.notes, this.initialText});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => NoteEditorState();
}

class NoteEditorState extends ConsumerState<NoteEditor> {
  late final RichTextController _controller;
  final UndoHistoryController _undoController = UndoHistoryController();
  String _title = 'New Note';
  String _body = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _undoController.addListener(_handleUndoStack);

    _controller = RichTextController(
      targetMatches: [
        // Matches everything up to the first newline (or the whole text if no newline)
        MatchTargetItem.pattern(
          r'^[^\n]*',
          style: TextStyle(fontWeight: FontWeight.bold),
        )
      ],
      onMatch: (matches) {},
    );

    _controller.addListener(_handleTextChange);
    if (widget.notes != null) {
      _controller.text = "${widget.notes!.title}\n${widget.notes!.content}";
    } else if (widget.initialText != null) {
      _controller.text = "Scripture Notes: ${widget.initialText!.quotation}\n${widget.initialText!.text}";
    }
  }

  void _handleTextChange() {
    final text =  _controller.text;

    // Split text into first line (title) and the rest (body)
    final lines = text.split('\n');
    final title = lines.isNotEmpty ? lines.first.trim() : 'New Note';
    final body = lines.length > 1 ? lines.sublist(1).join('\n').trim() : '';

    setState(() {
      _title = title.isEmpty ? 'New Note' : title;
      _body = body;
    });
  }

  void _handleUndoStack() {
    // if (_undoController.value.canUndo) {}
    // if (_undoController.value.canRedo) {}
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _undoController.removeListener(_handleUndoStack);
    _undoController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          _title,
          style: theme.textTheme.titleSmall,
        ),
        actions: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    _undoController.undo();
                  },
                  icon: Icon(
                    Icons.undo,
                    size: 18,
                  )),
              IconButton(
                  onPressed: () {
                    _undoController.redo();
                  },
                  icon: Icon(
                    Icons.redo,
                    size: 18,
                  )),
            ],
          ),
          // IconButton(
          //     onPressed: () {},
          //     icon: Icon(
          //       Icons.share,
          //       size: 18,
          //     )          ),
          TextButton(
            onPressed: _isSaving ? null : editingComplete,
            child: Text(_isSaving ? 'Saving...' : 'Done'),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: .7.h),
        child: TextField(
          undoController: _undoController,
          controller: _controller,
          maxLines: null, // allows multiple lines
          style: theme.textTheme.bodySmall,
          decoration: InputDecoration(
            hintText: 'What would you like to note?',
            border: InputBorder.none,
          ),
          // style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Future<void> editingComplete() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    Notes note = Notes(
      id: UuidV4().generate(),
      createdAt: DateTime.now().toIso8601String(),
      lastModified: DateTime.now().toIso8601String(),
      title: _title,
      content: _body,
      // reference: []
    );
    if (widget.notes != null) {
      note = note.copywith(
        id: widget.notes!.id,
        uid: widget.notes!.uid,
        createdAt: widget.notes!.createdAt,
      );
    }

    try {
      await ref.read(notesControllerProvider.notifier).save(note);
      if (mounted) Navigator.pop(context);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'notes',
          context: ErrorDescription('while saving a note'),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Unable to save note. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
