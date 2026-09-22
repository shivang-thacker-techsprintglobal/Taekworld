import '../../domain/entities/application_item_entity.dart';

/// DTO for Applications List API response.
class ApplicationsResponseModel {
  const ApplicationsResponseModel({
    this.pendingApplications = const [],
    this.enrolledApplications = const [],
    this.totalPending = 0,
    this.totalEnrolled = 0,
  });

  final List<ApplicationItemModel> pendingApplications;
  final List<ApplicationItemModel> enrolledApplications;
  final int totalPending;
  final int totalEnrolled;

  factory ApplicationsResponseModel.fromJson(Map<String, dynamic> json) {
    final pendingRaw = json['pendingApplications'] as List<dynamic>? ?? [];
    final enrolledRaw = json['enrolledApplications'] as List<dynamic>? ?? [];

    return ApplicationsResponseModel(
      pendingApplications: pendingRaw
          .map((item) => ApplicationItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      enrolledApplications: enrolledRaw
          .map((item) => ApplicationItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPending: json['totalPending'] as int? ?? pendingRaw.length,
      totalEnrolled: json['totalEnrolled'] as int? ?? enrolledRaw.length,
    );
  }
}

class ApplicationItemModel {
  const ApplicationItemModel({
    required this.id,
    required this.studentName,
    required this.parentName,
    required this.applicationDate,
    required this.status,
    this.studentFirstName = '',
    this.studentLastName = '',
    this.parentEmail = '',
    this.parentPhone = '',
    this.isViewed = false,
    this.viewedDate,
    this.viewedDateFormatted = '',
    this.paymentStatus,
    this.paymentAmount,
  });

  final int id;
  final String studentName;
  final String parentName;
  final String applicationDate;
  final String status;
  final String studentFirstName;
  final String studentLastName;
  final String parentEmail;
  final String parentPhone;
  final bool isViewed;
  final String? viewedDate;
  final String viewedDateFormatted;
  final String? paymentStatus;
  final double? paymentAmount;

  factory ApplicationItemModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['studentFirstName'] as String? ?? '';
    final lastName = json['studentLastName'] as String? ?? '';
    var name = json['studentName'] as String? ?? '';
    if (name.isEmpty && (firstName.isNotEmpty || lastName.isNotEmpty)) {
      name = '$firstName $lastName'.trim();
    }

    final viewedFormatted =
        (json['viewedDateFormatted'] as String?)?.trim() ?? '';

    return ApplicationItemModel(
      id: json['id'] as int? ?? 0,
      studentName: name.isNotEmpty ? name : 'Student',
      parentName:
          json['parentName'] as String? ?? json['parentFullName'] as String? ?? 'N/A',
      applicationDate: json['applicationDate'] as String? ?? '',
      status: json['status'] as String? ??
          json['applicationStatus'] as String? ??
          'Pending',
      studentFirstName: firstName,
      studentLastName: lastName,
      parentEmail: json['parentEmail'] as String? ?? '',
      parentPhone: json['parentPhone'] as String? ??
          json['parentPhoneNumber'] as String? ??
          '',
      isViewed: _readBool(json['isViewed']),
      viewedDate: json['viewedDate'] as String?,
      viewedDateFormatted: viewedFormatted,
      paymentStatus: json['paymentStatus'] as String?,
      paymentAmount: (json['paymentAmount'] as num?)?.toDouble(),
    );
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  ApplicationItemEntity toEntity() => ApplicationItemEntity(
        id: id,
        studentName: studentName,
        parentName: parentName,
        applicationDate: applicationDate,
        status: status,
        studentFirstName: studentFirstName,
        studentLastName: studentLastName,
        parentEmail: parentEmail,
        parentPhone: parentPhone,
        isViewed: isViewed,
        viewedDate: viewedDate,
        viewedDateFormatted: viewedDateFormatted,
        paymentStatus: paymentStatus,
        paymentAmount: paymentAmount,
      );
}
