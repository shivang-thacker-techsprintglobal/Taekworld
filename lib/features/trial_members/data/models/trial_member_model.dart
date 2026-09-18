import '../../domain/entities/trial_member_entity.dart';

/// DTO for Trial Member item from `GET /api/TrialMember/students/{dojangId}?category={category}`.
class TrialMemberModel {
  const TrialMemberModel({
    required this.id,
    required this.name,
    this.email = '',
    this.parentName = '',
    this.parentPhone = '',
    this.joinDate = '',
    this.status = 'new',
    this.trialEndDate = '',
    this.isTrialUser = true,
    this.trialType = '7',
    this.userCode = '',
    this.registrationDate = '',
    this.daysRemaining = 0,
    this.isNewStudent = true,
  });

  final int id;
  final String name;
  final String email;
  final String parentName;
  final String parentPhone;
  final String joinDate;
  final String status;
  final String trialEndDate;
  final bool isTrialUser;
  final String trialType;
  final String userCode;
  final String registrationDate;
  final int daysRemaining;
  final bool isNewStudent;

  factory TrialMemberModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'] as String? ?? json['fullName'] as String? ?? '';
    final trialTypeStr = json['trialType']?.toString() ?? '7';
    final isNew = (json['status'] == 'new') || (json['isNewStudent'] as bool? ?? true);

    int calculatedDays = json['daysRemaining'] as int? ?? 0;
    if (calculatedDays == 0 && json['trialEndDate'] != null) {
      final endDate = DateTime.tryParse(json['trialEndDate'].toString());
      if (endDate != null) {
        calculatedDays = endDate.difference(DateTime.now()).inDays;
        if (calculatedDays < 0) calculatedDays = 0;
      }
    }

    return TrialMemberModel(
      id: json['id'] as int? ?? json['userId']?.hashCode ?? 0,
      name: rawName,
      email: json['email'] as String? ?? '',
      parentName: json['parentName'] as String? ?? '',
      parentPhone: json['parentPhone'] as String? ?? json['phoneNumber'] as String? ?? '',
      joinDate: json['joinDate'] as String? ?? json['trialStartDate'] as String? ?? '',
      status: json['status'] as String? ?? 'new',
      trialEndDate: json['trialEndDate'] as String? ?? '',
      isTrialUser: json['isTrialUser'] as bool? ?? true,
      trialType: trialTypeStr,
      userCode: json['userCode'] as String? ?? '',
      registrationDate: json['registrationDate'] as String? ?? json['joinDate'] as String? ?? '',
      daysRemaining: calculatedDays,
      isNewStudent: isNew,
    );
  }

  TrialMemberEntity toEntity() => TrialMemberEntity(
        id: id,
        name: name,
        email: email,
        parentName: parentName,
        parentPhone: parentPhone,
        joinDate: joinDate,
        status: status,
        trialEndDate: trialEndDate,
        isTrialUser: isTrialUser,
        trialType: trialType,
        userCode: userCode,
        registrationDate: registrationDate,
        daysRemaining: daysRemaining,
        isNewStudent: isNewStudent,
      );
}
