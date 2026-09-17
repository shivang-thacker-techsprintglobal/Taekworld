import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taekworld/main.dart';

void main() {
  testWidgets('Login screen renders brand and sign-in CTA', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TaekworldApp()),
    );

    expect(find.text('Taekworld'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
