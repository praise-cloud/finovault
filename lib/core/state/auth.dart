import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models.dart';
import '../mock/api.dart';
import '../providers.dart';
import 'onboarding.dart';

class AuthState {
  const AuthState({this.user, this.restoring = true, this.busy = false, this.error});

  final UserProfile? user;
  final bool restoring;
  final bool busy;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({UserProfile? user, bool clearUser = false, bool? restoring, bool? busy, String? error, bool clearError = false}) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        restoring: restoring ?? this.restoring,
        busy: busy ?? this.busy,
        error: clearError ? null : (error ?? this.error),
      );
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  FinovaultApi get _api => ref.read(apiProvider);

  /// Cold-start: re-validate any stored token before showing the app.
  Future<void> restore() async {
    if (!state.restoring) return;
    final token = ref.read(kvStoreProvider).getString(sessionKey);
    if (token == null) {
      state = state.copyWith(restoring: false);
      return;
    }
    try {
      final user = await _api.getSession(token);
      if (user != null) {
        await ref.read(onboardingProvider.notifier).completeFromAuth();
      }
      state = AuthState(user: user, restoring: false);
      if (user == null) await ref.read(kvStoreProvider).remove(sessionKey);
    } on FvApiException {
      // Token expired/invalid or backend unreachable — drop the session and
      // start fresh instead of hanging on the splash.
      await ref.read(kvStoreProvider).remove(sessionKey);
      state = const AuthState(restoring: false);
    }
  }

  void setUser(UserProfile user) {
    state = state.copyWith(user: user, clearError: true);
  }

  /// Returns true on success (caller then pops back to the root gate).
  Future<bool> login(String email, String password) async {
    state = state.copyWith(busy: true, error: null, clearError: true);
    try {
      final result = await _api.login(email: email, password: password);
      await ref.read(kvStoreProvider).setString(sessionKey, result.token);
      await ref.read(onboardingProvider.notifier).completeFromAuth();
      state = AuthState(user: result.user, restoring: false);
      return true;
    } on FvApiException catch (e) {
      state = state.copyWith(busy: false, error: e.message);
      return false;
    }
  }

  Future<bool> signup(String fullName, String email, String password) async {
    state = state.copyWith(busy: true, error: null, clearError: true);
    try {
      final result = await _api.signup(fullName: fullName, email: email, password: password);
      await ref.read(kvStoreProvider).setString(sessionKey, result.token);
      state = AuthState(user: result.user, restoring: false);
      return true;
    } on FvApiException catch (e) {
      state = state.copyWith(busy: false, error: e.message);
      return false;
    }
  }

  Future<void> logout() async {
    final token = ref.read(kvStoreProvider).getString(sessionKey);
    try {
      await _api.logout(token);
    } on FvApiException {
      // best-effort
    }
    await ref.read(kvStoreProvider).remove(sessionKey);
    state = const AuthState(restoring: false);
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

final currentUserProvider = Provider<UserProfile?>((ref) => ref.watch(authProvider).user);
