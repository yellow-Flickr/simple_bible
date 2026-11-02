// dio_provider.dart
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
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
            log("Connection timed out. Please try again.");
            break;
          case DioExceptionType.badResponse:
            final statusCode = error.response?.statusCode;
            if (statusCode == 404) {
              log("Resource not found (404).");
            } else if (statusCode == 500) {
              log("Server error (500).");
            } else {
              log("Received invalid status code: $statusCode");
            }
            break;
          case DioExceptionType.unknown:
            log("Unknown error occurred: ${error.message}");
            break;
          default:
            log("Request failed: ${error.message}");
        }

        // Pass the error onward
        return handler.next(error);
      },
    ),
  );

  return dio;
});

/// The device's current connections.
final connectivityProvider =
    StreamProvider<List<ConnectivityResult>>((ref) async* {
  final connectivity = Connectivity();
  yield await connectivity.checkConnectivity();
  yield* connectivity.onConnectivityChanged;
});

/// Whether the device has any connection. Only a hint: a request can still
/// fail while "online", so failures are judged from the request itself.
final isOnlineProvider = Provider<bool>((ref) {
  final connections = ref.watch(connectivityProvider).valueOrNull;
  // Assume online until the platform says otherwise.
  return connections == null ||
      connections.any((c) => c != ConnectivityResult.none);
});

/// Whether the only connection is mobile data.
final isMeteredProvider = Provider<bool>((ref) {
  final connections = ref.watch(connectivityProvider).valueOrNull ?? const [];
  return connections.contains(ConnectivityResult.mobile) &&
      !connections.contains(ConnectivityResult.wifi) &&
      !connections.contains(ConnectivityResult.ethernet);
});
