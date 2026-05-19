import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/api_client.dart';
import '../../../core/database/app_database.dart';
import '../../../core/offline/sync_service.dart';
import '../../../core/storage/secure_auth_storage.dart';

part 'auth_provider.g.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? name;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.userId,
    this.email,
    this.name,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? userId,
    String? email,
    String? name,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      error: error,
    );
  }
}

@riverpod
class Auth extends _$Auth {
  @override
  Future<AuthState> build() async {
    final storage = SecureAuthStorage.shared;
    final token = await storage.readToken();
    final user = await storage.readUser();

    if (token == null || user == null) {
      return const AuthState();
    }

    final expiry = _jwtExpiry(token);
    if (expiry != null && expiry.isBefore(DateTime.now())) {
      await storage.clearAll();
      return const AuthState();
    }

    return AuthState(
      isAuthenticated: true,
      userId: user.id,
      email: user.email,
      name: user.name,
    );
  }

  Future<bool> login(String email, String password) async {
    state = AsyncData(
      state.valueOrNull?.copyWith(isLoading: true, error: null) ??
          const AuthState(isLoading: true),
    );

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['token'] as String;
      final userMap = response.data['user'] as Map<String, dynamic>;
      final userId = userMap['id'] as String;
      final userEmail = userMap['email'] as String;
      final userName = userMap['name'] as String?;

      final storage = SecureAuthStorage.shared;
      await storage.saveToken(token);
      await storage.saveUser(id: userId, email: userEmail, name: userName);

      state = AsyncData(AuthState(
        isAuthenticated: true,
        userId: userId,
        email: userEmail,
        name: userName,
      ));

      // Kick off a background sync — don't await, let UI proceed.
      unawaited(SyncService(ref.read(dioProvider)).fullRefresh(userId));

      return true;
    } on DioException catch (e) {
      final message = e.response?.data?['error'] as String? ?? 'Login failed';
      state = AsyncData(AuthState(error: message));
      return false;
    } catch (e) {
      state = AsyncData(const AuthState(error: 'An unexpected error occurred'));
      return false;
    }
  }

  Future<bool> register(String email, String password, {String? name}) async {
    state = AsyncData(
      state.valueOrNull?.copyWith(isLoading: true, error: null) ??
          const AuthState(isLoading: true),
    );

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      });

      final token = response.data['token'] as String;
      final userMap = response.data['user'] as Map<String, dynamic>;
      final userId = userMap['id'] as String;
      final userEmail = userMap['email'] as String;
      final userName = userMap['name'] as String?;

      final storage = SecureAuthStorage.shared;
      await storage.saveToken(token);
      await storage.saveUser(id: userId, email: userEmail, name: userName);

      state = AsyncData(AuthState(
        isAuthenticated: true,
        userId: userId,
        email: userEmail,
        name: userName,
      ));

      unawaited(SyncService(ref.read(dioProvider)).fullRefresh(userId));

      return true;
    } on DioException catch (e) {
      final message =
          e.response?.data?['error'] as String? ?? 'Registration failed';
      state = AsyncData(AuthState(error: message));
      return false;
    } catch (e) {
      state = AsyncData(const AuthState(error: 'An unexpected error occurred'));
      return false;
    }
  }

  Future<void> logout() async {
    await SecureAuthStorage.shared.clearAll();
    await AppDatabase.instance.clearUserData();
    state = const AsyncData(AuthState());
  }

  void setUnauthenticated() {
    state = const AsyncData(AuthState());
  }

  static DateTime? _jwtExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final exp = map['exp'] as int?;
      return exp != null
          ? DateTime.fromMillisecondsSinceEpoch(exp * 1000)
          : null;
    } catch (_) {
      return null;
    }
  }
}
