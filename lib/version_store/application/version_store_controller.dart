import 'dart:collection';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_bible/bible_reader/domain/scripture_models.dart';
import 'package:simple_bible/bible_reader/presentation/scripture_initialization_controller.dart'
    show installedVersionsProvider, scriptureServiceProvider;
import 'package:simple_bible/search/presentation/search_controller.dart';
import 'package:simple_bible/shared/configs/objectbox.dart';
import 'package:simple_bible/shared/network_providers.dart';
import 'package:simple_bible/version_store/data/catalogue_config.dart';
import 'package:simple_bible/version_store/data/remote_catalogue_repository.dart';
import 'package:simple_bible/version_store/data/version_downloader.dart';
import 'package:simple_bible/version_store/domain/catalogue.dart';
import 'package:simple_bible/version_store/domain/catalogue_repository.dart';
import 'package:simple_bible/version_store/domain/download_job.dart';

final catalogueRepositoryProvider = Provider<CatalogueRepository>(
  (ref) => RemoteCatalogueRepository(
    ref.watch(dioProvider),
    ref.watch(objectBoxProvider).objStore,
    catalogueUri,
  ),
);

final versionDownloaderProvider = Provider<VersionDownloader>(
  (ref) => VersionDownloader(
    ref.watch(dioProvider),
    directory: getTemporaryDirectory,
  ),
);

/// The catalogue, and whether it is the saved copy because fetching failed.
typedef CatalogueSnapshot = ({Catalogue catalogue, bool fromCache});

class CatalogueController extends AsyncNotifier<CatalogueSnapshot> {
  @override
  Future<CatalogueSnapshot> build() => _load();

  /// Fetches the catalogue again, keeping the current one on screen meanwhile.
  Future<void> refresh() async {
    state = const AsyncLoading<CatalogueSnapshot>();
    state = await AsyncValue.guard(_load);
  }

  Future<CatalogueSnapshot> _load() async {
    final repository = ref.read(catalogueRepositoryProvider);
    try {
      return (catalogue: await repository.fetch(), fromCache: false);
    } on Object catch (e) {
      final cached = repository.cached();
      if (cached == null) rethrow;
      developer.log('Showing the saved catalogue',
          name: 'VersionStore', error: e);
      return (catalogue: cached, fromCache: true);
    }
  }
}

final catalogueProvider =
    AsyncNotifierProvider<CatalogueController, CatalogueSnapshot>(
  CatalogueController.new,
);

/// Installed revision per version id.
final installedRevisionsProvider = Provider<Map<String, int>>((ref) => {
      for (final version in ref.watch(installedVersionsProvider))
        version.id: version.revision,
    });

/// Downloads versions one at a time. State holds the queued, running and
/// failed jobs by version id; finished and cancelled jobs are dropped.
class VersionDownloadController extends Notifier<Map<String, DownloadJob>> {
  final _queue = Queue<CatalogueEntry>();
  CancelToken? _cancelToken;
  String? _currentId;

  @override
  Map<String, DownloadJob> build() {
    ref.listen(isOnlineProvider, (wasOnline, online) {
      if (online && wasOnline == false) _retryWaiting();
    });
    return const {};
  }

  void download(CatalogueEntry entry) {
    if (state[entry.id]?.isActive ?? false) return;
    _queue.add(entry);
    _set(DownloadJob(entry, DownloadPhase.queued));
    _run();
  }

  void retry(String id) {
    final job = state[id];
    if (job != null) download(job.entry);
  }

  /// Stops a queued or downloading job. Installing can't be interrupted.
  void cancel(String id) {
    if (id == _currentId) {
      if (state[id]?.phase == DownloadPhase.downloading) _cancelToken?.cancel();
      return;
    }
    _queue.removeWhere((entry) => entry.id == id);
    _clear(id);
  }

  /// Deletes an installed version. Throws [StateError] for the last one.
  void remove(String id) {
    ref.read(scriptureServiceProvider).remove(id);
    _versionsChanged();
  }

  Future<void> _run() async {
    if (_currentId != null) return;
    while (_queue.isNotEmpty) {
      final entry = _queue.removeFirst();
      _currentId = entry.id;
      await _install(entry);
    }
    _currentId = null;
  }

  Future<void> _install(CatalogueEntry entry) async {
    final token = _cancelToken = CancelToken();
    _set(DownloadJob(entry, DownloadPhase.downloading));
    try {
      final json = await ref.read(versionDownloaderProvider).fetch(
        entry,
        entry.fileUri(versionFilesBaseUri),
        cancelToken: token,
        onProgress: (progress) {
          if (!token.isCancelled) _progress(entry, progress);
        },
      );
      _set(DownloadJob(entry, DownloadPhase.installing));
      final version = Versions.fromJson(json)..revision = entry.revision;
      await ref.read(scriptureServiceProvider).install(version);
      _clear(entry.id);
      _versionsChanged();
    } on DioException {
      // Only thrown when cancelled.
      _clear(entry.id);
    } on VersionDownloadException catch (e) {
      _set(DownloadJob(
        entry,
        DownloadPhase.failed,
        error: e.message,
        waitingForNetwork: e.isNetworkError,
      ));
    } on Object catch (e, stack) {
      developer.log('Installing ${entry.abbreviation} failed',
          name: 'VersionStore', error: e, stackTrace: stack);
      _set(DownloadJob(entry, DownloadPhase.failed, error: "Couldn't install"));
    } finally {
      _cancelToken = null;
    }
  }

  /// Updates at most once per percent, so the list isn't rebuilt per chunk.
  void _progress(CatalogueEntry entry, double progress) {
    final previous = state[entry.id]?.progress;
    if (previous != null &&
        (progress * 100).floor() == (previous * 100).floor()) {
      return;
    }
    _set(DownloadJob(entry, DownloadPhase.downloading, progress: progress));
  }

  void _retryWaiting() {
    for (final job in state.values.toList()) {
      if (job.waitingForNetwork) download(job.entry);
    }
  }

  void _versionsChanged() {
    ref.invalidate(installedVersionsProvider);
    // Drop search indexes built from the old text.
    ref.invalidate(searchServiceProvider);
  }

  void _set(DownloadJob job) => state = {...state, job.entry.id: job};

  void _clear(String id) => state = {...state}..remove(id);
}

final versionDownloadControllerProvider =
    NotifierProvider<VersionDownloadController, Map<String, DownloadJob>>(
  VersionDownloadController.new,
);
