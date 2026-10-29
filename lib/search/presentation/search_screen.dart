import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart'
    show scriptureServiceProvider;
import 'package:simple_bible/bible_reader/presentation/scripture_screen.dart';
import 'package:simple_bible/bible_reader/presentation/version_picker.dart';
import 'package:simple_bible/notes/domain/notes.dart';
import 'package:simple_bible/notes/presentation/note_editor.dart';
import 'package:simple_bible/notes/presentation/notes_controller.dart';
import 'package:simple_bible/search/application/search_service.dart';
import 'package:simple_bible/search/domain/search_query.dart';
import 'package:simple_bible/search/presentation/search_controller.dart';
import 'package:simple_bible/topics/domain/topic.dart';
import 'package:simple_bible/topics/presentation/topic_screen.dart';
import 'package:simple_bible/topics/presentation/topics_controller.dart';
import 'package:simple_bible/user_space/application/user_space_service.dart';

/// Searches verses, references, topics and notes.
///
/// With [returnPassage], choosing a verse or reference pops this screen with
/// the passage (0-based reader indexes) instead of opening a new reader, so
/// the reader that opened search can move to it.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({
    super.key,
    this.versionId,
    this.bookId,
    this.returnPassage = false,
  });

  /// Version to search; defaults to the app-wide version.
  final int? versionId;

  /// Canonical book number (1-66) to start filtered to.
  final int? bookId;
  final bool returnPassage;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

typedef _Results = ({
  Quotation? reference,
  List<Topic> topics,
  List<Notes> notes,
  VerseResults verses,
});

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _input = TextEditingController();
  Timer? _debounce;
  late int _versionId;
  late SearchScope _scope;
  bool _wholeWords = false;
  bool _showAllNotes = false;
  bool _searching = false;
  _Results? _results;
  int _run = 0;

  @override
  void initState() {
    super.initState();
    _versionId = widget.versionId ?? ref.read(preferredVersionIdProvider);
    _scope = widget.bookId == null ? const WholeBible() : SingleBook(widget.bookId!);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _input.dispose();
    super.dispose();
  }

  Versions? get _version => ref
      .read(scriptureServiceProvider)
      .getVersions()
      .where((v) => v.id == _versionId)
      .firstOrNull;

  void _onChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _search);
  }

  Future<void> _search() async {
    final input = _input.text;
    final run = ++_run;
    final version = _version;
    if (input.trim().isEmpty || version == null) {
      setState(() => _results = null);
      return;
    }

    setState(() => _searching = true);
    // Let the spinner show; the first search in a version builds its index.
    await Future<void>.delayed(Duration.zero);
    if (!mounted || run != _run) return;

    final query = SearchQuery.parse(input, wholeWords: _wholeWords);
    final translationId = version.books.first.translationId;
    final results = (
      reference: RegExp(r'\d').hasMatch(input)
          ? Quotation.tryParse(input, version)
          : null,
      topics: matchTopics(ref.read(topicsProvider).valueOrNull ?? const [], input),
      notes: matchNotes(ref.read(notesControllerProvider).valueOrNull ?? const [], query),
      verses: ref
          .read(searchServiceProvider)
          .indexFor(translationId)
          .search(query, scope: _scope),
    );
    if (!mounted || run != _run) return;
    setState(() {
      _results = results;
      _searching = false;
      _showAllNotes = false;
    });
  }

  void _remember() => ref.read(searchServiceProvider).addRecent(_input.text);

  void _openPassage(Quotation readerQuotation) {
    _remember();
    if (widget.returnPassage) {
      Navigator.pop(context, readerQuotation);
    } else {
      openScripture(context, quotation: readerQuotation);
    }
  }

  void _useRecent(String text) {
    _input
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length);
    _search();
  }

  void _pickBook() {
    final books = _version?.books ?? const <Book>[];
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SizedBox(
        height: 70.h,
        child: ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final selected = _scope == SingleBook(index + 1);
            return ListTile(
              title: Text(books[index].name),
              trailing: selected
                  ? Icon(Icons.check, color: theme.primaryColorDark)
                  : null,
              onTap: () {
                Navigator.pop(context);
                setState(() => _scope = SingleBook(index + 1));
                _search();
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Keep topics and notes loaded so searches can include them.
    ref.watch(topicsProvider);
    ref.watch(notesControllerProvider);
    final version = _version;
    final translationId = version?.books.firstOrNull?.translationId;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: TextField(
          controller: _input,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: (_) {
            _remember();
            _search();
          },
          decoration: InputDecoration(
            hintText: 'Search verses, topics, notes',
            border: InputBorder.none,
            suffixIcon: ListenableBuilder(
              listenable: _input,
              builder: (context, _) => _input.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _input.clear();
                        _search();
                      },
                    ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: VersionButton(
              label: translationId,
              selectedId: _versionId,
              onSelected: (id) {
                setState(() => _versionId = id);
                _search();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _filters(theme, version),
          if (_searching) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: _results == null ? _recent(theme) : _resultList(theme, _results!),
          ),
        ],
      ),
    );
  }

  Widget _filters(ThemeData theme, Versions? version) {
    Widget chip(String label, bool selected, VoidCallback onTap) => Padding(
          padding: EdgeInsets.only(right: 2.w),
          child: ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => onTap(),
            showCheckmark: false,
            selectedColor: theme.primaryColorDark,
            backgroundColor: theme.cardColor,
            labelStyle: TextStyle(
              fontSize: 12,
              color: selected ? Colors.black : null,
            ),
            shape: StadiumBorder(side: BorderSide(color: theme.dividerColor)),
          ),
        );

    void setScope(SearchScope scope) {
      setState(() => _scope = scope);
      _search();
    }

    final book = _scope is SingleBook && version != null
        ? version.books[(_scope as SingleBook).bookId - 1].name
        : null;

    return SizedBox(
      height: 6.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        children: [
          chip('All', _scope is WholeBible, () => setScope(const WholeBible())),
          chip('Old Testament', _scope is OldTestament,
              () => setScope(const OldTestament())),
          chip('New Testament', _scope is NewTestament,
              () => setScope(const NewTestament())),
          chip(book == null ? 'Book ▾' : '$book ▾', book != null, _pickBook),
          chip('Whole words', _wholeWords, () {
            setState(() => _wholeWords = !_wholeWords);
            _search();
          }),
        ],
      ),
    );
  }

  Widget _recent(ThemeData theme) {
    final recent = ref.read(searchServiceProvider).recentSearches();
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      children: [
        if (recent.isNotEmpty) ...[
          Row(
            children: [
              Text('Recent',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ref.read(searchServiceProvider).clearRecent();
                  setState(() {});
                },
                child: Text('Clear',
                    style: TextStyle(color: theme.primaryColorDark)),
              ),
            ],
          ),
          for (final text in recent)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history),
              title: Text(text),
              onTap: () => _useRecent(text),
            ),
          SizedBox(height: 2.h),
        ],
        Text(
          'Try a word like peace, a phrase in "quotes", or a reference like '
          'John 3:16 or Psalm 23.',
          style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13),
        ),
      ],
    );
  }

  Widget _resultList(ThemeData theme, _Results results) {
    final verses = results.verses;
    final notes = _showAllNotes ? results.notes : results.notes.take(3).toList();
    final nothing = results.reference == null &&
        results.topics.isEmpty &&
        results.notes.isEmpty &&
        verses.total == 0;
    if (nothing) {
      return const Center(child: Text('No matches. Try fewer or shorter words.'));
    }

    Widget header(String text) => Padding(
          padding: EdgeInsets.only(top: 2.h, bottom: 1.h),
          child: Text(text,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        );

    final children = <Widget>[
      if (results.reference case final reference?)
        Card(
          color: theme.primaryColor,
          margin: EdgeInsets.only(top: 1.h),
          child: ListTile(
            leading: Icon(Icons.menu_book_outlined, color: theme.primaryColorDark),
            title: Text('Go to ${reference.quotation}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => _openPassage(reference.toReaderQuotation()),
          ),
        ),
      if (results.topics.isNotEmpty) ...[
        header('Topics'),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: [for (final t in results.topics) TopicChip(topic: t)],
        ),
      ],
      if (results.notes.isNotEmpty) ...[
        header('Notes'),
        for (final note in notes)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.sticky_note_2_outlined),
            title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle:
                Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () {
              _remember();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NoteEditor(notes: note)),
              );
            },
          ),
        if (results.notes.length > notes.length)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _showAllNotes = true),
              child: Text('Show all ${results.notes.length} notes',
                  style: TextStyle(color: theme.primaryColorDark)),
            ),
          ),
      ],
      if (verses.total > 0)
        header(verses.total > verses.hits.length
            ? 'Showing ${verses.hits.length} of ${verses.total} verses. '
                'Narrow it down with a filter.'
            : '${verses.total} ${verses.total == 1 ? 'verse' : 'verses'}'),
    ];

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 3.h),
      itemCount: children.length + verses.hits.length,
      itemBuilder: (context, index) {
        if (index < children.length) return children[index];
        final hit = verses.hits[index - children.length];
        return _VerseHitTile(
          hit: hit,
          onTap: () => _openPassage(
            Quotation.fromVerses([hit.verse], versionId: _versionId)
                .toReaderQuotation(),
          ),
        );
      },
    );
  }
}

class _VerseHitTile extends StatelessWidget {
  const _VerseHitTile({required this.hit, required this.onTap});

  final VerseHit hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verse = hit.verse;
    final text = verse.text;
    final base = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: theme.textTheme.bodyLarge?.color,
    );
    final highlight = base.copyWith(
      fontWeight: FontWeight.w700,
      backgroundColor: theme.primaryColorDark.withValues(alpha: .25),
    );

    final spans = <TextSpan>[];
    var cursor = 0;
    for (final (start, end) in hit.highlights) {
      if (start > cursor) spans.add(TextSpan(text: text.substring(cursor, start)));
      spans.add(TextSpan(text: text.substring(start, end), style: highlight));
      cursor = end;
    }
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${verse.bookName} ${verse.chapter}:${verse.verse}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: theme.primaryColorDark,
              ),
            ),
            SizedBox(height: .4.h),
            Text.rich(TextSpan(style: base, children: spans)),
          ],
        ),
      ),
    );
  }
}
