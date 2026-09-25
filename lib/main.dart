import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/widgets/app_crash_screen.dart';
import 'features/login/presentation/screens/auth_gate.dart';
import 'features/notifications/application/push_notification_service.dart';

/// Holds a restart callback so [ErrorWidget.builder] can remount the app tree.
VoidCallback? _appRestart;

Future<void> main() async {
  // ensureInitialized + runApp must share the same zone (avoids "Zone mismatch").
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Build-time widget failures → §4.8 crash UI instead of the red/yellow box.
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return AppCrashScreen(
        onRestart: () => _appRestart?.call(),
      );
    };

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) {
        debugPrint('PlatformDispatcher error: $error\n$stack');
      }
      AppBootstrap.reportFatalError(error);
      return true;
    };

    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    runApp(const ProviderScope(child: AppBootstrap()));
  }, (error, stack) {
    if (kDebugMode) {
      debugPrint('Uncaught zone error: $error\n$stack');
    }
    AppBootstrap.reportFatalError(error);
  });
}

/// Root bootstrap: remounts [TaekworldApp] on Reload, and can swap to the
/// global crash screen for fatal async / platform errors (UI-SPEC §4.8).
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  static _AppBootstrapState? _state;

  static void reportFatalError(Object error) {
    _state?._showCrash(error);
  }

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  Key _appKey = UniqueKey();
  Object? _fatalError;

  @override
  void initState() {
    super.initState();
    AppBootstrap._state = this;
    _appRestart = _restart;
  }

  @override
  void dispose() {
    if (AppBootstrap._state == this) {
      AppBootstrap._state = null;
    }
    if (_appRestart == _restart) {
      _appRestart = null;
    }
    super.dispose();
  }

  void _showCrash(Object error) {
    if (!mounted) return;
    if (_fatalError != null) return;
    setState(() => _fatalError = error);
  }

  void _restart() {
    if (!mounted) return;
    setState(() {
      _fatalError = null;
      _appKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_fatalError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(context),
        home: AppCrashScreen(onRestart: _restart),
      );
    }

    return KeyedSubtree(
      key: _appKey,
      child: const TaekworldApp(),
    );
  }
}

class TaekworldApp extends ConsumerStatefulWidget {
  const TaekworldApp({super.key});

  @override
  ConsumerState<TaekworldApp> createState() => _TaekworldAppState();
}

class _TaekworldAppState extends ConsumerState<TaekworldApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(pushNotificationServiceProvider).initialize();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Push notification init skipped: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(context),
      themeMode: ThemeMode.light,
      home: const AuthGate(),
    );
  }
}
