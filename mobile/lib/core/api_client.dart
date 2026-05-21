import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'offline/offline_queue.dart';

part 'api_client.g.dart';

const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://momentum-production-419f.up.railway.app/api',
);

// Methods whose failures should be queued for offline retry (mutations only).
const _queueableMethods = {'POST', 'PUT', 'DELETE'};

@riverpod
Dio dio(Ref ref) {
  final client = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  client.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        const storage = FlutterSecureStorage(
          aOptions: AndroidOptions(),
        );
        final token = await storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final isConnectivityError =
            error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.receiveTimeout;

        final method = error.requestOptions.method.toUpperCase();
        final path = error.requestOptions.path;
        final isAuthEndpoint = path.startsWith('/auth/');
        final shouldQueue =
            isConnectivityError &&
            _queueableMethods.contains(method) &&
            !isAuthEndpoint;

        if (shouldQueue) {
          final body = error.requestOptions.data as Map<String, dynamic>? ?? {};
          await OfflineQueue.enqueue(
            PendingOp(
              method: method,
              endpoint: error.requestOptions.path,
              body: body,
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );
          // Return a synthetic "queued" response so the caller can proceed
          // optimistically — the UI already updated before the request.
          handler.resolve(
            Response(
              requestOptions: error.requestOptions,
              statusCode: 202,
              data: {'queued': true},
            ),
          );
          return;
        }

        handler.next(error);
      },
    ),
  );

  return client;
}
