import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_bible/version_store/data/version_downloader.dart';
import 'package:simple_bible/version_store/domain/catalogue.dart';

const _entry = CatalogueEntry(
  id: 'eng-tst',
  translationId: 'TST',
  name: 'Test Version',
  abbreviation: 'TST',
  languageCode: 'en',
  languageName: 'English',
  revision: 1,
  url: 'tst.v1.json',
  sizeBytes: 0,
  bookCount: 2,
  verseCount: 3,
  license: 'Public Domain',
  minSchemaVersion: 1,
);

String _versionFile({String id = 'eng-tst', int verses = 3}) => jsonEncode({
      'id': id,
      'version_name': 'Test Version',
      'version': [
        for (var i = 0; i < verses; i++)
          {
            'id': i,
            'book_id': i == 0 ? 1 : 2,
            'chapter': 1,
            'verse': i + 1,
            'text': 'Verse $i',
            'translation_id': 'TST',
            'book_name': i == 0 ? 'Genesis' : 'Exodus',
            'testament': 'Old Testament',
          },
      ],
    });

void main() {
  group('decodeVersionFile', () {
    test('returns the JSON when it matches the entry', () {
      final json = decodeVersionFile(_versionFile(), _entry);
      expect((json['version'] as List).length, 3);
    });

    test('rejects a truncated file', () {
      final text = _versionFile();
      expect(
        () => decodeVersionFile(text.substring(0, text.length ~/ 2), _entry),
        throwsA(isA<VersionDownloadException>()),
      );
    });

    test('rejects a file with missing verses', () {
      expect(
        () => decodeVersionFile(_versionFile(verses: 2), _entry),
        throwsA(isA<VersionDownloadException>()),
      );
    });

    test('rejects a file for another version', () {
      expect(
        () => decodeVersionFile(_versionFile(id: 'eng-other'), _entry),
        throwsA(isA<VersionDownloadException>()),
      );
    });
  });

  group('VersionDownloader', () {
    late Directory directory;
    late _FakeAdapter adapter;
    late VersionDownloader downloader;
    final url = Uri.parse('https://example.com/tst.v1.json');

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('version_downloader');
      adapter = _FakeAdapter();
      downloader = VersionDownloader(
        Dio()..httpClientAdapter = adapter,
        directory: () async => directory,
        retryDelay: Duration.zero,
      );
    });

    tearDown(() => directory.delete(recursive: true));

    test('downloads, reports progress and cleans up the file', () async {
      adapter.responses.add(() => _ok(_versionFile()));
      final progress = <double>[];

      final json = await downloader.fetch(_entry, url, onProgress: progress.add);

      expect(json['id'], 'eng-tst');
      expect(progress.last, 1.0);
      expect(directory.listSync(), isEmpty);
    });

    test('retries after a connection error', () async {
      adapter.responses
        ..add(() => throw SocketException('offline'))
        ..add(() => _ok(_versionFile()));

      final json = await downloader.fetch(_entry, url);

      expect(json['id'], 'eng-tst');
      expect(adapter.calls, 2);
    });

    test('reports a network error after the last retry', () async {
      for (var i = 0; i < 3; i++) {
        adapter.responses.add(() => throw SocketException('offline'));
      }

      await expectLater(
        downloader.fetch(_entry, url),
        throwsA(isA<VersionDownloadException>()
            .having((e) => e.isNetworkError, 'isNetworkError', isTrue)),
      );
      expect(adapter.calls, 3);
    });

    test('does not retry a cancelled download', () async {
      final token = CancelToken()..cancel();
      adapter.responses.add(() => _ok(_versionFile()));

      await expectLater(
        downloader.fetch(_entry, url, cancelToken: token),
        throwsA(isA<DioException>()
            .having(CancelToken.isCancel, 'isCancel', isTrue)),
      );
    });

    test('rejects an incomplete download', () async {
      adapter.responses.add(() => _ok(_versionFile(verses: 2)));

      await expectLater(
        downloader.fetch(_entry, url),
        throwsA(isA<VersionDownloadException>()
            .having((e) => e.isNetworkError, 'isNetworkError', isFalse)),
      );
      expect(directory.listSync(), isEmpty);
    });
  });
}

ResponseBody _ok(String body) {
  final bytes = Uint8List.fromList(utf8.encode(body));
  return ResponseBody.fromBytes(bytes, 200, headers: {
    Headers.contentLengthHeader: ['${bytes.length}'],
  });
}

class _FakeAdapter implements HttpClientAdapter {
  final responses = <ResponseBody Function()>[];
  var calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    return responses.removeAt(0)();
  }

  @override
  void close({bool force = false}) {}
}
