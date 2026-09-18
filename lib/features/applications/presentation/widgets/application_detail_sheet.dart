import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_text_style.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/info_row.dart';
import '../../application/controllers/application_detail_controller.dart';
import '../../domain/entities/application_detail_entity.dart';

/// Modal Bottom Sheet for Student Application Details (90% screen height) per UI-SPEC §4.5.
class ApplicationDetailSheet extends ConsumerWidget {
  const ApplicationDetailSheet({
    super.key,
    required this.applicationId,
    required this.initialStudentName,
  });

  final String applicationId;
  final String initialStudentName;

  static Future<void> show(
    BuildContext context, {
    required String applicationId,
    required String initialStudentName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.90,
        child: ApplicationDetailSheet(
          applicationId: applicationId,
          initialStudentName: initialStudentName,
        ),
      ),
    );
  }

  Future<void> _launchEnrollmentWeb(BuildContext context) async {
    const enrollUrl = 'https://www.blackbelthw.com/master/newstudent';
    final uri = Uri.parse(enrollUrl);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enrollment page opened. Refreshing application status'),
              duration: Duration(seconds: 3),
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      } else if (context.mounted) {
        _showEnrollFallbackDialog(context, enrollUrl);
      }
    } catch (_) {
      if (context.mounted) {
        _showEnrollFallbackDialog(context, enrollUrl);
      }
    }
  }

  void _showEnrollFallbackDialog(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Unable to Open Browser',
          style: AppTextStyle.t1(ctx, color: AppColors.brandNavy),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Could not open the enrollment page in your browser.\nPlease copy this URL and open it manually:',
              style: AppTextStyle.b2(ctx),
            ),
            const SizedBox(height: 12),
            SelectableText(
              url,
              style: const TextStyle(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('URL copied to clipboard')),
              );
            },
            child: const Text('Copy URL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(applicationDetailControllerProvider(applicationId));

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        children: [
          // Header (Brand red, top radius 20)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Application',
                        style: AppTextStyle.h4(
                          context,
                          color: Colors.white,
                        ).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        state is ApplicationDetailSuccess
                            ? state.detail.studentFullName
                            : initialStudentName,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 26),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Body Content
          Expanded(
            child: _buildBody(context, ref, state),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ApplicationDetailState state,
  ) {
    if (state is ApplicationDetailLoading) {
      return const Center(child: AppLoader());
    }

    if (state is ApplicationDetailError) {
      return Center(
        child: AppErrorView(
          message: state.message,
          onRetry: () {
            ref
                .read(applicationDetailControllerProvider(applicationId).notifier)
                .loadDetail(applicationId);
          },
        ),
      );
    }

    if (state is ApplicationDetailSuccess) {
      final detail = state.detail;

      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Student Information
                  _buildSectionCard(
                    context,
                    title: 'Student Information',
                    rows: [
                      InfoRow(label: 'First Name', value: detail.studentFirstName, labelWidth: 120),
                      InfoRow(label: 'Last Name', value: detail.studentLastName, labelWidth: 120),
                      InfoRow(label: 'Date of Birth', value: detail.dateOfBirth, labelWidth: 120),
                      InfoRow(label: 'Gender', value: detail.gender, labelWidth: 120),
                      InfoRow(label: 'School/Grade', value: detail.schoolNameGrade, labelWidth: 120),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // 2. Parent/Guardian Information
                  _buildSectionCard(
                    context,
                    title: 'Parent/Guardian Information',
                    rows: [
                      InfoRow(label: 'Name', value: detail.parentFullName, labelWidth: 120),
                      InfoRow(label: 'Relationship', value: detail.relationshipToStudent, labelWidth: 120),
                      InfoRow(label: 'Phone', value: detail.parentPhoneNumber, labelWidth: 120),
                      InfoRow(label: 'Email', value: detail.parentEmail, labelWidth: 120),
                      InfoRow(label: 'Address', value: detail.fullAddress, labelWidth: 120),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // 3. Emergency Contact
                  _buildSectionCard(
                    context,
                    title: 'Emergency Contact',
                    rows: [
                      InfoRow(label: 'Name', value: detail.emergencyContactName, labelWidth: 120),
                      InfoRow(label: 'Phone', value: detail.emergencyContactPhone, labelWidth: 120),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // 4. Medical Information (only when present)
                  if (detail.hasMedicalInfo) ...[
                    _buildSectionCard(
                      context,
                      title: 'Medical Information',
                      rows: [
                        if (detail.allergies.isNotEmpty)
                          InfoRow(label: 'Allergies', value: detail.allergies, labelWidth: 120),
                        if (detail.medicalConditionDetails.isNotEmpty)
                          InfoRow(
                            label: 'Medical Conditions',
                            value: detail.medicalConditionDetails,
                            labelWidth: 120,
                          ),
                        if (detail.currentMedication.isNotEmpty)
                          InfoRow(
                            label: 'Current Medications',
                            value: detail.currentMedication,
                            labelWidth: 120,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                  ],

                  // 5. Application Details
                  _buildSectionCard(
                    context,
                    title: 'Application Details',
                    rows: [
                      InfoRow(label: 'Application Date', value: detail.applicationDate, labelWidth: 120),
                      InfoRow(
                        label: 'Status',
                        value: detail.applicationStatus,
                        labelWidth: 120,
                        valueColor: detail.isEnrolled ? AppColors.success : AppColors.accentOrange,
                      ),
                      if (detail.viewedDate != null && detail.viewedDate!.isNotEmpty)
                        InfoRow(label: 'Viewed Date', value: detail.viewedDate, labelWidth: 120),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),

          // Pinned Bottom Button
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1.0),
              ),
            ),
            child: detail.isEnrolled
                ? ElevatedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text(
                      'Already Enrolled',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () => _launchEnrollmentWeb(context),
                    icon: const Icon(Icons.open_in_browser, color: Colors.white),
                    label: const Text(
                      'Enroll Student (Web)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandNavy,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 0,
                    ),
                  ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.t1(
              context,
              color: AppColors.brandNavy,
            ).copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12.0),
          ...rows,
        ],
      ),
    );
  }
}
