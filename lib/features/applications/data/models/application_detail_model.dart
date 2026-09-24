import '../../domain/entities/application_detail_entity.dart';

/// DTO for Application Detail API response per `02-API-INTEGRATION.md` §3.4.
class ApplicationDetailModel {
  const ApplicationDetailModel({
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

  factory ApplicationDetailModel.fromJson(Map<String, dynamic> json) {
    return ApplicationDetailModel(
      id: json['id'] as int? ?? 0,
      studentFirstName: json['studentFirstName'] as String? ?? '',
      studentLastName: json['studentLastName'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      schoolNameGrade: json['schoolNameGrade'] as String? ?? '',
      parentFullName: json['parentFullName'] as String? ?? json['parentName'] as String? ?? '',
      relationshipToStudent: json['relationshipToStudent'] as String? ?? '',
      parentPhoneNumber: json['parentPhoneNumber'] as String? ?? json['parentPhone'] as String? ?? '',
      parentEmail: json['parentEmail'] as String? ?? '',
      streetAddress: json['streetAddress'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zipCode'] as String? ?? '',
      emergencyContactName: json['emergencyContactName'] as String? ?? '',
      emergencyContactPhone: json['emergencyContactPhone'] as String? ?? '',
      hasMedicalConditions: json['hasMedicalConditions'] as String? ?? 'no',
      allergies: json['allergies'] as String? ?? '',
      medicalConditionDetails: json['medicalConditionDetails'] as String? ?? '',
      currentMedication: json['currentMedication'] as String? ?? '',
      applicationDate: json['applicationDate'] as String? ?? '',
      applicationStatus: json['applicationStatus'] as String? ?? json['status'] as String? ?? 'Pending',
      // Detail payload uses receiptDate when first viewed; viewedDate is also accepted.
      viewedDate: (json['viewedDate'] as String?)?.trim().isNotEmpty == true
          ? json['viewedDate'] as String?
          : (json['receiptDate'] as String?),
      enrollmentDate: json['enrollmentDate'] as String?,
      hasPaymentMethod: json['hasPaymentMethod'] as bool? ?? false,
    );
  }

  ApplicationDetailEntity toEntity() => ApplicationDetailEntity(
        id: id,
        studentFirstName: studentFirstName,
        studentLastName: studentLastName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        schoolNameGrade: schoolNameGrade,
        parentFullName: parentFullName,
        relationshipToStudent: relationshipToStudent,
        parentPhoneNumber: parentPhoneNumber,
        parentEmail: parentEmail,
        streetAddress: streetAddress,
        city: city,
        state: state,
        zipCode: zipCode,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
        hasMedicalConditions: hasMedicalConditions,
        allergies: allergies,
        medicalConditionDetails: medicalConditionDetails,
        currentMedication: currentMedication,
        applicationDate: applicationDate,
        applicationStatus: applicationStatus,
        viewedDate: viewedDate,
        enrollmentDate: enrollmentDate,
        hasPaymentMethod: hasPaymentMethod,
      );
}
