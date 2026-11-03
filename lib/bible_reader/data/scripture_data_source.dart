import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:simple_bible/bible_reader/data/scripture_load_exception.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/domain/scripture_repository.dart';

/// Data source for scripture operations
class ScriptureDataSource implements ScriptureAssetSource {
  const ScriptureDataSource();

  /// Asset paths for local scripture files
  static const List<String> _scriptureAssets = [
    'asset/kjv.json',
  ];

  /// Loads all local scripture versions concurrently
  ///
  /// Returns a list of [Versions] loaded from local assets.
  /// Throws [ScriptureLoadException] if any asset fails to load or parse.
  @override
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
}

final scriptureDataProvider =
    Provider<ScriptureDataSource>((ref) => const ScriptureDataSource());
