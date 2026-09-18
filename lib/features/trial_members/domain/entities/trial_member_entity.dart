/// Domain entity representing a trial member item per UI-SPEC §4.6 & `02-API-INTEGRATION.md` §3.2.
class TrialMemberEntity {
  const TrialMemberEntity({
    required this.id,
    required this.name,
    this.email = '',
    this.parentName = '',
    this.parentPhone = '',
    this.joinDate = '',
    this.status = 'new',
    this.trialEndDate = '',
    this.isTrialUser = true,
    this.trialType = '7', // '7' or '30'
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

  bool get isSevenDay => trialType.contains('7');
  bool get isThirtyDay => trialType.contains('30');
  bool get isExpired => daysRemaining <= 0;
  String get displayName => name.isNotEmpty ? name : (parentName.isNotEmpty ? parentName : 'Student');
}
