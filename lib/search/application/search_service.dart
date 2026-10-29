import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/notes/domain/notes.dart';
import 'package:simple_bible/search/data/verse_source.dart';
import 'package:simple_bible/search/domain/recent_search.dart';
import 'package:simple_bible/search/domain/search_query.dart';
import 'package:simple_bible/topics/domain/topic.dart';

/// Which part of the Bible to search. Books use canonical numbers (1-66).
sealed class SearchScope {
  const SearchScope();

  bool includes(int bookId);
}

class WholeBible extends SearchScope {
  const WholeBible();

  @override
  bool includes(int bookId) => true;
}

class OldTestament extends SearchScope {
  const OldTestament();

  @override
  bool includes(int bookId) => bookId <= 39;
}

class NewTestament extends SearchScope {
  const NewTestament();

  @override
  bool includes(int bookId) => bookId >= 40;
}

class SingleBook extends SearchScope {
  const SingleBook(this.bookId);

  final int bookId;

  @override
  bool includes(int bookId) => bookId == this.bookId;

  @override
  bool operator ==(Object other) => other is SingleBook && other.bookId == bookId;

  @override
  int get hashCode => bookId.hashCode;
}

/// A matching verse and where the matched words are in its text.
typedef VerseHit = ({Verse verse, List<(int, int)> highlights});

/// The first [limit] matching verses, plus how many matched in total.
typedef VerseResults = ({List<VerseHit> hits, int total});

/// A version's verses with their search-ready text, built once per version.
class VerseIndex {
  VerseIndex(this.verses)
      : _normalized = [for (final v in verses) normalizeForSearch(v.text)];

  final List<Verse> verses;
  final List<String> _normalized;

  VerseResults search(
    SearchQuery query, {
    SearchScope scope = const WholeBible(),
    int limit = 300,
  }) {
    if (query.isEmpty) return (hits: const [], total: 0);
    final hits = <VerseHit>[];
    var total = 0;
    for (var i = 0; i < verses.length; i++) {
      if (!scope.includes(verses[i].bookId)) continue;
      final text = _normalized[i];
      if (!query.matches(text)) continue;
      total++;
      if (hits.length < limit) {
        hits.add((verse: verses[i], highlights: query.highlights(text)));
      }
    }
    return (hits: hits, total: total);
  }
}

class SearchService {
  SearchService(this._verses, this._recent, {this.maxRecent = 10});

  final VerseSource _verses;
  final RecentSearchRepository _recent;
  final int maxRecent;
  final _indexes = <String, VerseIndex>{};

  VerseIndex indexFor(String translationId) =>
      _indexes[translationId] ??= VerseIndex(_verses.versesOf(translationId));

  /// Recent searches, newest first.
  List<String> recentSearches() {
    final all = [..._recent.getAll()]..sort((a, b) => b.usedAt.compareTo(a.usedAt));
    return [for (final r in all.take(maxRecent)) r.query];
  }

  /// Remembers [query], moving it to the top if it was already there (ignoring
  /// case) and keeping only the newest [maxRecent].
  void addRecent(String query, {DateTime? now}) {
    final text = query.trim();
    if (text.length < 2) return;
    final all = _recent.getAll();
    final existing =
        all.where((r) => r.query.toLowerCase() == text.toLowerCase()).firstOrNull;
    _recent.save(RecentSearch(
      uid: existing?.uid,
      query: text,
      usedAt: (now ?? DateTime.now()).millisecondsSinceEpoch,
    ));

    final sorted = [..._recent.getAll()]..sort((a, b) => b.usedAt.compareTo(a.usedAt));
    final stale = sorted.skip(maxRecent).map((r) => r.uid!).toList();
    if (stale.isNotEmpty) _recent.removeMany(stale);
  }

  void clearRecent() =>
      _recent.removeMany([for (final r in _recent.getAll()) r.uid!]);
}

/// Topics whose name contains the typed text, best matches (prefix) first.
List<Topic> matchTopics(List<Topic> topics, String input, {int limit = 8}) {
  final q = normalizeForSearch(input.trim());
  if (q.length < 2) return const [];
  final matches = topics.where((t) => normalizeForSearch(t.name).contains(q)).toList()
    ..sort((a, b) {
      final aStarts = normalizeForSearch(a.name).startsWith(q) ? 0 : 1;
      final bStarts = normalizeForSearch(b.name).startsWith(q) ? 0 : 1;
      return aStarts != bStarts ? aStarts - bStarts : a.name.compareTo(b.name);
    });
  return matches.take(limit).toList();
}

/// Notes whose title or text contains every term, most recently edited first.
List<Notes> matchNotes(List<Notes> notes, SearchQuery query) {
  if (query.isEmpty) return const [];
  return notes
      .where((n) => query.matches(normalizeForSearch('${n.title}\n${n.content}')))
      .toList()
    ..sort((a, b) => b.lastModified.compareTo(a.lastModified));
}
