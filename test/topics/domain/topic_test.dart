import 'package:flutter_test/flutter_test.dart';
import 'package:simple_bible/topics/domain/topic.dart';

void main() {
  group('canonicalBookNumber', () {
    test('maps canonical names regardless of case and spacing', () {
      expect(canonicalBookNumber('Genesis'), 1);
      expect(canonicalBookNumber(' 1 john '), 62);
      expect(canonicalBookNumber('REVELATION'), 66);
    });

    test('maps the topic data aliases', () {
      expect(canonicalBookNumber('Psalm'), 19);
      expect(canonicalBookNumber('Acts'), 44);
      expect(canonicalBookNumber('Song of songs'), 22);
    });

    test('returns null for unknown books', () {
      expect(canonicalBookNumber('Maccabees'), isNull);
      expect(canonicalBookNumber(''), isNull);
    });
  });

  group('parseVerseRange', () {
    test('parses single verses and ranges', () {
      expect(parseVerseRange('16'), (16, 16));
      expect(parseVerseRange('20-23'), (20, 23));
      expect(parseVerseRange(' 5 - 6 '), (5, 6));
    });

    test('rejects malformed and inverted ranges', () {
      for (final input in ['', 'a', '0', '5-2', '1,2', '1-']) {
        expect(parseVerseRange(input), isNull, reason: input);
      }
    });
  });
}
