import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped when [AuthInterceptor] decides the session must end
/// (401 without `Token-Expired`, or refresh failed).
///
/// Kept separate from [dioClientProvider] / [loginControllerProvider] to avoid
/// a Riverpod dependency cycle. [AuthGate] listens and runs full logout.
final sessionExpiredSignalProvider = StateProvider<int>((ref) => 0);
