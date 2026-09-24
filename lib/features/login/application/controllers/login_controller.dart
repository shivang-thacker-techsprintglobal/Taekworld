import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/providers/current_user_provider.dart';
import '../../../notifications/application/push_notification_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import 'login_state.dart';

class LoginController extends StateNotifier<LoginState> {
  LoginController(this._repository, this._ref)
      : super(const LoginState.checkingSession()) {
    restoreSession();
  }

  final AuthRepository _repository;
  final Ref _ref;
  bool _sessionExpiryInProgress = false;

  Future<void> restoreSession() async {
    state = const LoginState.checkingSession();

    try {
      final session = await _repository.restoreSession();
      if (session == null) {
        state = const LoginState.initial();
        return;
      }

      _ref.read(currentUserProvider.notifier).state = session.user;
      state = LoginState.success(session.user);
    } on Failure catch (failure) {
      await _repository.clearSession();
      state = LoginState.error(failure.message);
    } catch (_) {
      await _repository.clearSession();
      state = const LoginState.initial();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const LoginState.loading();

    try {
      final session = await _repository.login(
        email: email.trim(),
        password: password,
      );
      _ref.read(currentUserProvider.notifier).state = session.user;
      state = LoginState.success(session.user);
    } on Failure catch (failure) {
      state = LoginState.error(failure.message);
    } catch (_) {
      state = const LoginState.error(
        'Something went wrong. Please try again.',
      );
    }
  }

  /// User-initiated logout: delete-device → Auth/logout → clear → Login.
  Future<void> logout() async {
    try {
      await _ref.read(pushNotificationServiceProvider).unregisterDevice();
    } catch (_) {}
    await _repository.logout();
    _ref.read(currentUserProvider.notifier).state = null;
    state = const LoginState.initial();
  }

  /// Forced sign-out after a non-refreshable 401 or failed refresh
  /// (integration contract). Same cleanup as [logout]; guarded against re-entry
  /// when logout's own API calls also return 401.
  Future<void> onSessionExpired() async {
    if (_sessionExpiryInProgress) return;
    if (state is LoginInitial || state is LoginCheckingSession) return;

    _sessionExpiryInProgress = true;
    try {
      await logout();
    } finally {
      _sessionExpiryInProgress = false;
    }
  }

  void reset() {
    state = const LoginState.initial();
  }
}

final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>((ref) {
  return LoginController(ref.watch(authRepositoryProvider), ref);
});
