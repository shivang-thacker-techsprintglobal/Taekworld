/// Domain entity representing an application list item.
class ApplicationItemEntity {
  const ApplicationItemEntity({
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

  /// Check if the application is pending and not yet viewed
  bool get isNew => !isViewed && status.toLowerCase() == 'pending';

  ApplicationItemEntity copyWith({
    bool? isViewed,
    String? viewedDate,
    String? viewedDateFormatted,
  }) {
    return ApplicationItemEntity(
      id: id,
      studentName: studentName,
      parentName: parentName,
      applicationDate: applicationDate,
      status: status,
      studentFirstName: studentFirstName,
      studentLastName: studentLastName,
      parentEmail: parentEmail,
      parentPhone: parentPhone,
      isViewed: isViewed ?? this.isViewed,
      viewedDate: viewedDate ?? this.viewedDate,
      viewedDateFormatted: viewedDateFormatted ?? this.viewedDateFormatted,
      paymentStatus: paymentStatus,
      paymentAmount: paymentAmount,
    );
  }
}
