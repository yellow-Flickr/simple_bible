import 'package:simple_bible/version_store/domain/catalogue.dart';

enum DownloadPhase { queued, downloading, installing, failed }

/// A version being fetched or installed, or one whose download failed.
class DownloadJob {
  const DownloadJob(
    this.entry,
    this.phase, {
    this.progress,
    this.error,
    this.waitingForNetwork = false,
  });

  final CatalogueEntry entry;
  final DownloadPhase phase;

  /// 0-1 while downloading; null when the size isn't known yet.
  final double? progress;
  final String? error;

  /// The download failed because the device went offline. It is retried
  /// automatically once the connection comes back.
  final bool waitingForNetwork;

  bool get isActive => phase != DownloadPhase.failed;
}
