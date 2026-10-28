import 'package:flutter_test/flutter_test.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/user_space/application/user_space_service.dart';

void main() {
  group('resolvePreferredVersionId', () {
    final versions = [
      Versions(id: 100, versionName: 'KJV'),
      Versions(id: 200, versionName: 'Akuapem Twi'),
    ];

    test('keeps an installed preference', () {
      expect(resolvePreferredVersionId(200, versions), 200);
    });

    test('falls back to the first version when the preference is missing',
        () {
      expect(resolvePreferredVersionId(300, versions), 100);
    });

    test('keeps the preference while versions are still loading', () {
      expect(resolvePreferredVersionId(200, const []), 200);
    });
  });
}
