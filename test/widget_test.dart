import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taekworld/features/login/application/controllers/login_controller.dart';
import 'package:taekworld/features/login/application/controllers/login_state.dart';
import 'package:taekworld/features/login/domain/entities/auth_session.dart';
import 'package:taekworld/features/login/domain/entities/user_entity.dart';
import 'package:taekworld/features/login/domain/repositories/auth_repository.dart';
import 'package:taekworld/main.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<void> clearSession() async {}

  @override
  Future<AuthSession> getProfile() {
    throw UnimplementedError();
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity?> readCachedUser() async => null;

  @override
  Future<AuthSession> refreshToken() {
    throw UnimplementedError();
  }

  @override
  Future<AuthSession?> restoreSession() async => null;

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('Login screen renders brand and login CTA', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loginControllerProvider.overrideWith((ref) {
            final controller = LoginController(_FakeAuthRepository(), ref);
            controller.state = const LoginState.initial();
            return controller;
          }),
        ],
        child: const TaekworldApp(),
      ),
    );

    // AuthGate routes to Login when session check finishes as logged-out.
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
