

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

