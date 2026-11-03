import 'package:flutter_test/flutter_test.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/user_space/application/user_space_service.dart';

void main() {
  group('resolvePreferredVersionId', () {
    final versions = [
      Versions(id: 'eng-kjv', versionName: 'KJV'),
      Versions(id: 'twi-akna', versionName: 'Akuapem Twi'),
    ];

    test('keeps an installed preference', () {
      expect(resolvePreferredVersionId('twi-akna', versions), 'twi-akna');
    });

    test('falls back to the first version when the preference is missing',
        () {
      expect(resolvePreferredVersionId('eng-amp', versions), 'eng-kjv');
    });

    test('keeps the preference while versions are still loading', () {
      expect(resolvePreferredVersionId('twi-akna', const []), 'twi-akna');
    });
  });
}
