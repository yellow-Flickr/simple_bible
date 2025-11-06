import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/common/network_providers.dart';

/// Exception thrown when scripture loading fails
class ScriptureLoadException implements Exception {
  final String message;
  final String? assetPath;
  final dynamic originalError;

  const ScriptureLoadException(
    this.message, {
    this.assetPath,
    this.originalError,
  });

  @override
  String toString() => 'ScriptureLoadException: $message'
      '${assetPath != null ? ' (Asset: $assetPath)' : ''}';
}

/// Exception thrown when scripture download fails
class ScriptureDownloadException implements Exception {
  final String message;
  final String? url;
  final String? filePath;
  final dynamic originalError;

  const ScriptureDownloadException(
    this.message, {
    this.url,
    this.filePath,
    this.originalError,
  });

  @override
  String toString() => 'ScriptureDownloadException: $message'
      '${url != null ? ' (URL: $url)' : ''}'
      '${filePath != null ? ' (File: $filePath)' : ''}';
}

/// Result of a successful scripture download
class DownloadResult {
  final String filePath;
  final int fileSize;
  final String downloadUrl;
  final DateTime downloadedAt;

  const DownloadResult({
    required this.filePath,
    required this.fileSize,
    required this.downloadUrl,
    required this.downloadedAt,
  });

  @override
  String toString() => 'DownloadResult(filePath: $filePath, '
      'fileSize: $fileSize bytes, downloadUrl: $downloadUrl, '
      'downloadedAt: $downloadedAt)';
}

/// Data source for scripture operations
class ScriptureDataSource {
  ScriptureDataSource(this._dio, this._progressNotifier);

  final Dio _dio;
  final DownloadProgressNotifier _progressNotifier;

  /// Asset paths for local scripture files
  static const List<String> _scriptureAssets = [
    'asset/kjv.json',
    'asset/AkuapemTwi.json',
  ];

  /// Loads all local scripture versions concurrently
  ///
  /// Returns a list of [Versions] loaded from local assets.
  /// Throws [ScriptureLoadException] if any asset fails to load or parse.
  Future<List<Versions>> loadLocalScriptures() async {
    try {
      // Load all scripture files concurrently for better performance
      final futures = _scriptureAssets.map(_loadScriptureAsset);
      final versions = await Future.wait(futures);

      developer.log(
        'Successfully loaded ${versions.length} scripture versions',
        name: 'ScriptureRepository',
      );

      return versions;
    } catch (e) {
      developer.log(
        'Failed to load scripture versions: $e',
        name: 'ScriptureRepository',
        error: e,
      );
      rethrow;
    }
  }

  /// Loads a single scripture asset file
  ///
  /// [assetPath] - Path to the scripture JSON asset
  /// Returns a [Versions] object parsed from the asset
  /// Throws [ScriptureLoadException] on failure
  Future<Versions> _loadScriptureAsset(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);

      if (jsonString.isEmpty) {
        throw ScriptureLoadException(
          'Asset file is empty',
          assetPath: assetPath,
        );
      }

      final version = versionsFromJson(jsonString);

      developer.log(
        'Loaded scripture: ${version.versionName} from $assetPath',
        name: 'ScriptureRepository',
      );

      return version;
    } on PlatformException catch (e) {
      throw ScriptureLoadException(
        'Failed to load asset: ${e.message ?? 'Unknown platform error'}',
        assetPath: assetPath,
        originalError: e,
      );
    } on FormatException catch (e) {
      throw ScriptureLoadException(
        'Invalid JSON format: ${e.message}',
        assetPath: assetPath,
        originalError: e,
      );
    } catch (e) {
      developer.log(e.toString());
      throw ScriptureLoadException(
        'Unexpected error loading scripture',
        assetPath: assetPath,
        originalError: e,
      );
    }
  }

  /// Downloads scripture data from a remote source with comprehensive error handling
  ///
  /// [scriptureUrl] - The URL to download scripture data from
  /// [fileName] - Optional custom filename for the downloaded file
  /// [maxRetries] - Maximum number of retry attempts (default: 3)
  ///
  /// Returns a [DownloadResult] containing the file path and metadata
  /// Throws [ScriptureDownloadException] on failure after all retries
  Future<DownloadResult> downloadScripture({
    required String scriptureUrl,
    String? fileName,
    int maxRetries = 3,
  }) async {
    final sanitizedFileName =
        'scripture_${fileName ?? scriptureUrl.replaceAll(RegExp(r'/'), '_')}.json';
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$sanitizedFileName';

    developer.log(
      'Starting scripture download from: $scriptureUrl',
      name: 'ScriptureRepository',
    );

    // Reset progress before starting
    _progressNotifier.reset();

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await _dio.download(
          scriptureUrl,
          filePath,
          options: Options(
            headers: {
              HttpHeaders.acceptEncodingHeader: '*', // Disable gzip
              HttpHeaders.userAgentHeader: 'SimpleBible/1.0',
            },
            validateStatus: (status) => status != null && status < 400,
            followRedirects: true,
            maxRedirects: 3,
          ),
          onReceiveProgress: (received, total) {
            if (total <= 0) {
              developer.log(
                'Download progress: $received bytes received (total unknown)',
                name: 'ScriptureRepository',
              );
              return;
            }

            final progress = (received / total * 100);
            developer.log(
              'Download progress: ${progress.toStringAsFixed(1)}% '
              '($received/$total bytes)',
              name: 'ScriptureRepository',
            );
            _progressNotifier.updateProgress(progress);
          },
        );

        // Validate the downloaded file
        final downloadedFile = File(filePath);
        if (!await downloadedFile.exists()) {
          throw ScriptureDownloadException(
            'Downloaded file does not exist',
            url: scriptureUrl,
            filePath: filePath,
          );
        }

        final fileSize = await downloadedFile.length();
        if (fileSize == 0) {
          throw ScriptureDownloadException(
            'Downloaded file is empty',
            url: scriptureUrl,
            filePath: filePath,
          );
        }

        final result = DownloadResult(
          filePath: filePath,
          fileSize: fileSize,
          downloadUrl: scriptureUrl,
          downloadedAt: DateTime.now(),
        );

        developer.log(
          'Successfully downloaded scripture: $fileSize bytes to $filePath',
          name: 'ScriptureRepository',
        );

        _progressNotifier.updateProgress(100.0);
        return result;
      } on DioException catch (e) {
        final isLastAttempt = attempt == maxRetries;

        developer.log(
          'Download attempt $attempt/$maxRetries failed: ${e.message}',
          name: 'ScriptureRepository',
          error: e,
        );

        if (isLastAttempt) {
          throw ScriptureDownloadException(
            'Failed to download scripture after $maxRetries attempts: ${e.message}',
            url: scriptureUrl,
            originalError: e,
          );
        }

        // Exponential backoff for retries
        final delaySeconds = attempt * 2;
        developer.log(
          'Retrying download in ${delaySeconds}s...',
          name: 'ScriptureRepository',
        );
        await Future.delayed(Duration(seconds: delaySeconds));
      } catch (e) {
        final isLastAttempt = attempt == maxRetries;

        developer.log(
          'Unexpected error during download attempt $attempt/$maxRetries: $e',
          name: 'ScriptureRepository',
          error: e,
        );

        if (isLastAttempt) {
          throw ScriptureDownloadException(
            'Unexpected error during scripture download: $e',
            url: scriptureUrl,
            originalError: e,
          );
        }

        // Shorter delay for unexpected errors
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    // This should never be reached, but included for completeness
    throw ScriptureDownloadException(
      'Download failed after all retry attempts',
      url: scriptureUrl,
    );
  }
}

final scriptureDataProvider = Provider<ScriptureDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  final progressNotifier = ref.watch(downloadProgressProvider.notifier);
  return ScriptureDataSource(dio, progressNotifier);
});
