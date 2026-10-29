/// Lower-cases [text] and folds letters to plain ASCII where it can (Twi
/// `ɛ`/`ɔ` become `e`/`o`, accents are dropped) so searches don't need special
/// characters. The result always has the same length as [text], so match
/// positions in it are also positions in the original.
String normalizeForSearch(String text) {
  final out = StringBuffer();
  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    final folded = _fold[char] ?? char.toLowerCase();
    // Keep a 1:1 mapping, even for the rare letters whose lower case is longer.
    out.write(folded.length == char.length ? folded : char);
  }
  return out.toString();
}

const _fold = {
  'ɛ': 'e', 'Ɛ': 'e', 'ɔ': 'o', 'Ɔ': 'o',
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'À': 'a', 'Á': 'a', 'Â': 'a', 'Ä': 'a',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'È': 'e', 'É': 'e', 'Ê': 'e', 'Ë': 'e',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'Ì': 'i', 'Í': 'i', 'Î': 'i', 'Ï': 'i',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'Ò': 'o', 'Ó': 'o', 'Ô': 'o', 'Ö': 'o',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'Ù': 'u', 'Ú': 'u', 'Û': 'u', 'Ü': 'u',
  'ñ': 'n', 'Ñ': 'n', 'ç': 'c', 'Ç': 'c', '’': "'", '‘': "'",
};

/// What the user typed, split into words and "quoted phrases".
///
/// Every word and phrase must appear (AND). A word matches the start of a word
/// in the text ("love" finds "loveth" but not "glove"), or only the exact word
/// when [wholeWords] is on. A phrase always matches exactly, word for word.
class SearchQuery {
  SearchQuery._(this.words, this.phrases, this.wholeWords)
      : _patterns = [
          for (final w in words) _pattern(RegExp.escape(w), wholeWord: wholeWords),
          for (final p in phrases)
            _pattern(p.split(' ').map(RegExp.escape).join(r'\s+'), wholeWord: true),
        ];

  factory SearchQuery.parse(String input, {bool wholeWords = false}) {
    final normalized = normalizeForSearch(input);
    final phrases = <String>[];
    final rest = normalized.replaceAllMapped(RegExp(r'"([^"]*)"?'), (m) {
      final phrase = _terms(m[1]!).join(' ');
      if (phrase.isNotEmpty) phrases.add(phrase);
      return ' ';
    });
    return SearchQuery._(_terms(rest), phrases, wholeWords);
  }

  final List<String> words;
  final List<String> phrases;
  final bool wholeWords;
  final List<RegExp> _patterns;

  bool get isEmpty => words.isEmpty && phrases.isEmpty;

  /// Whether [normalizedText] (see [normalizeForSearch]) contains every term.
  bool matches(String normalizedText) =>
      !isEmpty && _patterns.every((p) => p.hasMatch(normalizedText));

  /// Sorted, non-overlapping `(start, end)` ranges of the matched terms in
  /// [normalizedText]; they are also valid in the original text.
  List<(int, int)> highlights(String normalizedText) {
    final ranges = [
      for (final p in _patterns)
        for (final m in p.allMatches(normalizedText)) (m.start, m.end),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    final merged = <(int, int)>[];
    for (final r in ranges) {
      if (merged.isNotEmpty && r.$1 <= merged.last.$2) {
        final last = merged.removeLast();
        merged.add((last.$1, r.$2 > last.$2 ? r.$2 : last.$2));
      } else {
        merged.add(r);
      }
    }
    return merged;
  }

  static List<String> _terms(String text) => text
      .split(RegExp(r"[^\p{L}\p{N}']+", unicode: true))
      .map((t) => t.replaceAll(RegExp(r"^'+|'+$"), ''))
      .where((t) => t.isNotEmpty)
      .toList();

  static RegExp _pattern(String body, {required bool wholeWord}) {
    const edge = r"(?<![\p{L}\p{N}])";
    final end = wholeWord ? r"(?![\p{L}\p{N}])" : '';
    return RegExp('$edge$body$end', unicode: true);
  }
}
