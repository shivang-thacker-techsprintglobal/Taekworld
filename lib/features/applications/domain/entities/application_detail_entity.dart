/// Domain entity for detailed student application view per UI-SPEC §4.5.
class ApplicationDetailEntity {
  const ApplicationDetailEntity({
    required this.id,
    required this.studentFirstName,
    required this.studentLastName,
    this.dateOfBirth = '',
    this.gender = '',
    this.schoolNameGrade = '',
    this.parentFullName = '',
    this.relationshipToStudent = '',
    this.parentPhoneNumber = '',
    this.parentEmail = '',
    this.streetAddress = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.hasMedicalConditions = 'no',
    this.allergies = '',
    this.medicalConditionDetails = '',
    this.currentMedication = '',
    this.applicationDate = '',
    this.applicationStatus = 'Pending',
    this.viewedDate,
    this.enrollmentDate,
    this.hasPaymentMethod = false,
  });

  final int id;
  final String studentFirstName;
  final String studentLastName;
  final String dateOfBirth;
  final String gender;
  final String schoolNameGrade;

  final String parentFullName;
  final String relationshipToStudent;
  final String parentPhoneNumber;
  final String parentEmail;
  final String streetAddress;
  final String city;
  final String state;
  final String zipCode;

  final String emergencyContactName;
  final String emergencyContactPhone;

  final String hasMedicalConditions;
  final String allergies;
  final String medicalConditionDetails;
  final String currentMedication;

  final String applicationDate;
  final String applicationStatus;
  final String? viewedDate;
  final String? enrollmentDate;
  final bool hasPaymentMethod;

  String get studentFullName => '$studentFirstName $studentLastName'.trim();

  String get fullAddress {
    final parts = [
      streetAddress,
      city,
      if (state.isNotEmpty && zipCode.isNotEmpty) '$state $zipCode' else state.isNotEmpty ? state : zipCode,
    ].where((p) => p.trim().isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : 'N/A';
  }

  bool get hasMedicalInfo =>
      hasMedicalConditions.toLowerCase() == 'yes' ||
      allergies.trim().isNotEmpty ||
      medicalConditionDetails.trim().isNotEmpty ||
      currentMedication.trim().isNotEmpty;

  bool get isEnrolled =>
      applicationStatus.toLowerCase() == 'enrolled' || enrollmentDate != null;
}
