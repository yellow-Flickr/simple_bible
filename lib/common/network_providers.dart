// dio_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.publicapis.io/v1', 
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
    ),
  );

  // Add error handling interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (DioException error, handler) {
        // Log the error or show a custom error message
        switch (error.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
            print("Connection timed out. Please try again.");
            break;
          case DioExceptionType.badResponse:
            final statusCode = error.response?.statusCode;
            if (statusCode == 404) {
              print("Resource not found (404).");
            } else if (statusCode == 500) {
              print("Server error (500).");
            } else {
              print("Received invalid status code: $statusCode");
            }
            break;
          case DioExceptionType.unknown:
            print("Unknown error occurred: ${error.message}");
            break;
          default:
            print("Request failed: ${error.message}");
        }

        // Pass the error onward
        return handler.next(error);
      },
    ),
  );

  return dio;
});



// download_progress_notifier.dart
class DownloadProgressNotifier extends StateNotifier<double?> {
  DownloadProgressNotifier() : super(null);

  void updateProgress(double progress) {
    state = progress;
  }

  void reset() {
    state = null;
  }
}

// Provide it via Riverpod
final downloadProgressProvider =
    StateNotifierProvider<DownloadProgressNotifier, double?>(
  (ref) => DownloadProgressNotifier(),
);