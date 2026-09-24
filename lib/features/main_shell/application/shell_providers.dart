import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Main Shell Navigation Provider (current active tab index)
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Badge counts providers for tabs
final applicationsBadgeProvider = StateProvider<int>((ref) => 0);
final trialMembersBadgeProvider = StateProvider<int>((ref) => 0);
final notificationsBadgeProvider = StateProvider<int>((ref) => 0);

/// URL queued by a notification tap for MainShell to open externally.
final pendingBrowserOpenProvider = StateProvider<String?>((ref) => null);

/// Application id queued by a NewApplication push tap to open detail sheet.
final pendingApplicationOpenProvider = StateProvider<String?>((ref) => null);
