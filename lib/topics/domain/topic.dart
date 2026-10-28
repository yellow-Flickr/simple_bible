import 'package:simple_bible/bible_reader/domain/scripture_models.dart';

class Topic {
  const Topic({
    required this.slug,
    required this.name,
    required this.relatedSlugs,
    required this.references,
  });

  final String slug;
  final String name;
  final List<String> relatedSlugs;
  final List<TopicReference> references;
}

/// A passage listed under a topic, using 1-based canonical numbering
/// (Genesis is book 1) so it can be looked up in any installed version.
class TopicReference {
  const TopicReference({
    required this.bookNumber,
    required this.chapter,
    required this.fromVerse,
    required this.toVerse,
    this.otherTopicSlugs = const [],
  });

  final int bookNumber;
  final int chapter;
  final int fromVerse;
  final int toVerse;
  final List<String> otherTopicSlugs;
}

/// A topic passage resolved against a specific version.
class TopicVerse {
  const TopicVerse({
    required this.quotation,
    required this.verses,
    required this.otherTopics,
    required this.translationId,
  });

  /// 1-based quotation with the version's text and book name.
  final Quotation quotation;
  final List<Verse> verses;
  final List<Topic> otherTopics;
  final String translationId;
}

const _canonicalBooks = [
  'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua',
  'Judges', 'Ruth', '1 Samuel', '2 Samuel', '1 Kings', '2 Kings',
  '1 Chronicles', '2 Chronicles', 'Ezra', 'Nehemiah', 'Esther', 'Job',
  'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Solomon', 'Isaiah',
  'Jeremiah', 'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos',
  'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk', 'Zephaniah', 'Haggai',
  'Zechariah', 'Malachi', 'Matthew', 'Mark', 'Luke', 'John',
  'Acts of the Apostles', 'Romans', '1 Corinthians', '2 Corinthians',
  'Galatians', 'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians',
  '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus', 'Philemon', 'Hebrews',
  'James', '1 Peter', '2 Peter', '1 John', '2 John', '3 John', 'Jude',
  'Revelation',
];

const _bookAliases = {
  'psalm': 'Psalms',
  'acts': 'Acts of the Apostles',
  'song of songs': 'Song of Solomon',
};

final _bookNumbers = {
  for (final (index, name) in _canonicalBooks.indexed)
    name.toLowerCase(): index + 1,
};

/// The 1-based canonical number of an English book [name], or null.
int? canonicalBookNumber(String name) {
  final key = name.trim().toLowerCase();
  return _bookNumbers[_bookAliases[key]?.toLowerCase() ?? key];
}

/// Parses `"16"` or `"16-18"` into an inclusive verse range, or null.
(int, int)? parseVerseRange(String verses) {
  final match = RegExp(r'^\s*(\d+)\s*(?:-\s*(\d+))?\s*$').firstMatch(verses);
  if (match == null) return null;
  final from = int.parse(match[1]!);
  final to = int.parse(match[2] ?? match[1]!);
  if (from < 1 || to < from) return null;
  return (from, to);
}
