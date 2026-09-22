import '../../domain/entities/trial_member_entity.dart';

/// DTO for `GET /api/TrialMember/students/{dojangId}?category=…`.
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

  final String id;
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
    final rawName =
        json['name'] as String? ?? json['fullName'] as String? ?? '';
    final trialTypeStr = json['trialType']?.toString() ?? '7';
    final status = json['status']?.toString() ?? 'new';
    final isTrialUser = json['isTrialUser'] as bool? ?? true;
    final isNewStudent = status.toLowerCase() == 'new' || isTrialUser;

    var calculatedDays = (json['daysRemaining'] as num?)?.toInt() ?? 0;
    if (json['trialEndDate'] != null) {
      final endDate = DateTime.tryParse(json['trialEndDate'].toString());
      if (endDate != null) {
        final today = DateTime.now();
        final endDay = DateTime(endDate.year, endDate.month, endDate.day);
        final todayDay = DateTime(today.year, today.month, today.day);
        calculatedDays = endDay.difference(todayDay).inDays;
      }
    }

    return TrialMemberModel(
      id: _readId(json),
      name: rawName,
      email: json['email'] as String? ?? '',
      parentName: json['parentName'] as String? ?? '',
      parentPhone: json['parentPhone'] as String? ??
          json['phoneNumber'] as String? ??
          '',
      joinDate: json['joinDate'] as String? ??
          json['trialStartDate'] as String? ??
          '',
      status: status,
      trialEndDate: json['trialEndDate'] as String? ?? '',
      isTrialUser: isTrialUser,
      trialType: trialTypeStr,
      userCode: json['userCode'] as String? ?? '',
      registrationDate: json['registrationDate'] as String? ??
          json['joinDate'] as String? ??
          '',
      daysRemaining: calculatedDays,
      isNewStudent: isNewStudent,
    );
  }

  static String _readId(Map<String, dynamic> json) {
    final raw = json['id'] ?? json['userId'];
    if (raw == null) return '';
    return raw.toString();
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
