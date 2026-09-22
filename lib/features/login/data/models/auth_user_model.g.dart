// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthUserModelImpl _$$AuthUserModelImplFromJson(Map<String, dynamic> json) =>
    _$AuthUserModelImpl(
      uid: json['uid'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      displayName: json['displayName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      role: json['role'] as String?,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      academyId: json['academyId'] as String?,
      academyName: json['academyName'] as String?,
      academyPhoneNumber: json['academyPhoneNumber'] as String?,
      status: json['status'] as String?,
      statusText: json['statusText'] as String?,
      isActive: json['isActive'] as bool?,
      userCode: json['userCode'] as String?,
    );

Map<String, dynamic> _$$AuthUserModelImplToJson(_$AuthUserModelImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'displayName': instance.displayName,
      'phoneNumber': instance.phoneNumber,
      'role': instance.role,
      'roles': instance.roles,
      'academyId': instance.academyId,
      'academyName': instance.academyName,
      'academyPhoneNumber': instance.academyPhoneNumber,
      'status': instance.status,
      'statusText': instance.statusText,
      'isActive': instance.isActive,
      'userCode': instance.userCode,
    };
