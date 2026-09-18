import 'package:flutter/material.dart';

import '../../../../config/app_colors.dart';

/// Navigation badge icon per UI-SPEC §3.2.
///
/// Circle badge, min 18x18, white 10sp bold, `99+` cap, top-right offset.
class NavBadgeIcon extends StatelessWidget {
  const NavBadgeIcon({
    super.key,
    required this.icon,
    this.badgeCount = 0,
    this.badgeColor = AppColors.primary,
  });

  final Widget icon;
  final int badgeCount;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    if (badgeCount <= 0) {
      return icon;
    }

    final badgeText = badgeCount > 99 ? '99+' : '$badgeCount';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          top: -4,
          right: -8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            constraints: const BoxConstraints(
              minWidth: 18,
              minHeight: 18,
            ),
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
