import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import 'login_state.dart';

class LoginController extends StateNotifier<LoginState> {
  LoginController(this._repository) : super(const LoginState.initial());

  final AuthRepository _repository;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const LoginState.loading();

    try {
      final user = await _repository.login(
        email: email.trim(),
        password: password,
      );
      state = LoginState.success(user);
    } on Failure catch (failure) {
      state = LoginState.error(failure.message);
    } catch (_) {
      state = const LoginState.error(
        'Something went wrong. Please try again.',
      );
    }
  }

  void reset() {
    state = const LoginState.initial();
  }
}

final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginController, LoginState>((ref) {
  return LoginController(ref.watch(authRepositoryProvider));
});
