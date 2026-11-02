import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:simple_bible/version_store/domain/catalogue.dart';

class VersionDownloadException implements Exception {
  const VersionDownloadException(this.message, {this.isNetworkError = false});

  final String message;

  /// The device couldn't reach the server, as opposed to a bad file or a
  /// server error.
  final bool isNetworkError;

  @override
  String toString() => 'VersionDownloadException: $message';
}

/// Downloads version files and checks them against their catalogue entry.
class VersionDownloader {
  VersionDownloader(
    this._dio, {
    required Future<Directory> Function() directory,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  }) : _directory = directory;

  final Dio _dio;
  final Future<Directory> Function() _directory;
  final int maxRetries;

  /// Multiplied by the attempt number between retries.
  final Duration retryDelay;

  /// Downloads [entry] from [url] and returns its decoded JSON, in the format
  /// [Versions.fromJson] reads. [onProgress] gets 0-1.
  ///
  /// Throws [VersionDownloadException], or a cancel [DioException] when
  /// [cancelToken] is cancelled.
  Future<Map<String, dynamic>> fetch(
    CatalogueEntry entry,
    Uri url, {
    CancelToken? cancelToken,
    void Function(double progress)? onProgress,
  }) async {
    final directory = await _directory();
    final path =
        '${directory.path}/version_${entry.id}_r${entry.revision}.json';
    try {
      await _download(entry, url, path, cancelToken, onProgress);
      return await _decodeFile(path, entry);
    } finally {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
  }

  Future<void> _download(
    CatalogueEntry entry,
    Uri url,
    String path,
    CancelToken? cancelToken,
    void Function(double progress)? onProgress,
  ) async {
    for (var attempt = 1;; attempt++) {
      try {
        await _dio.downloadUri(
          url,
          path,
          cancelToken: cancelToken,
          options: Options(receiveTimeout: const Duration(seconds: 30)),
          onReceiveProgress: (received, total) {
            // Compressed responses report no total; fall back to the
            // catalogue's uncompressed size, which is what `received` counts.
            final size = total > 0 ? total : entry.sizeBytes;
            if (size > 0) onProgress?.call((received / size).clamp(0.0, 1.0));
          },
        );
        return;
      } on DioException catch (e) {
        if (CancelToken.isCancel(e)) rethrow;
        developer.log(
          'Download attempt $attempt/$maxRetries of ${entry.abbreviation} failed',
          name: 'VersionDownloader',
          error: e,
        );
        if (attempt >= maxRetries) throw _describe(e);
        await Future<void>.delayed(retryDelay * attempt);
      }
    }
  }

  static VersionDownloadException _describe(DioException e) => switch (e.type) {
        DioExceptionType.connectionError ||
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          const VersionDownloadException(
            'No connection',
            isNetworkError: true,
          ),
        DioExceptionType.unknown when e.error is SocketException =>
          const VersionDownloadException(
            'No connection',
            isNetworkError: true,
          ),
        DioExceptionType.badResponse => VersionDownloadException(
            'Server error (${e.response?.statusCode})',
          ),
        _ => const VersionDownloadException('Download failed'),
      };
}

/// Decodes and checks the file off the UI isolate; version files are ~10 MB.
Future<Map<String, dynamic>> _decodeFile(String path, CatalogueEntry entry) =>
    Isolate.run(
      () async => decodeVersionFile(await File(path).readAsString(), entry),
    );

/// Decodes a version file and checks it is the complete text of [entry].
/// Throws [VersionDownloadException] when it is damaged or incomplete.
Map<String, dynamic> decodeVersionFile(String text, CatalogueEntry entry) {
  try {
    final json = jsonDecode(text) as Map<String, dynamic>;
    final verses = json['version'] as List;
    final books = {for (final verse in verses) (verse as Map)['book_id']};
    if (json['id'] != entry.id ||
        books.length != entry.bookCount ||
        verses.length != entry.verseCount) {
      throw const FormatException('Contents do not match the catalogue');
    }
    return json;
  } on Object catch (e) {
    developer.log('Bad file for ${entry.abbreviation}',
        name: 'VersionDownloader', error: e);
    throw const VersionDownloadException('The download was incomplete');
  }
}
