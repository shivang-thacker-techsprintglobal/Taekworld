import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Gradient website banner per UI-SPEC §4.3 & §8.
class WebsiteBannerCard extends StatelessWidget {
  const WebsiteBannerCard({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  String get _targetUrl {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isNotEmpty) {
      return 'https://www.blackbelthw.com/$cleaned';
    }
    return 'https://www.blackbelthw.com/master';
  }

  Future<void> _launchWebsite(BuildContext context) async {
    final uri = Uri.parse(_targetUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showFallback(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showFallback(context);
      }
    }
  }

  void _showFallback(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Could not open website'),
        action: SnackBarAction(
          label: 'Copy Link',
          textColor: Colors.white,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: _targetUrl));
            context.showSnackBar('Link copied to clipboard');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launchWebsite(context),
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            gradient: const LinearGradient(
              colors: [
                AppColors.brandNavy,
                AppColors.accentBlueDark,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentBlueDark.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.open_in_browser,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'View Detailed Information',
                      style: AppTextStyle.t3(
                        context,
                        color: Colors.white,
                      ).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      'Click here to check detailed data on the website',
                      style: AppTextStyle.b4(
                        context,
                        color: Colors.white.withValues(alpha: 0.9),
                      ).copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
