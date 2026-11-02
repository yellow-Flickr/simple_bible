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
