// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AuthUserModel _$AuthUserModelFromJson(Map<String, dynamic> json) {
  return _AuthUserModel.fromJson(json);
}

/// @nodoc
mixin _$AuthUserModel {
  String get uid => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get role => throw _privateConstructorUsedError;
  List<String> get roles => throw _privateConstructorUsedError;

  /// Dojang id used by every authenticated call. Wire format is a string.
  String? get academyId => throw _privateConstructorUsedError;
  String? get academyName => throw _privateConstructorUsedError;
  String? get academyPhoneNumber => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get statusText => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
  String? get userCode => throw _privateConstructorUsedError;

  /// Serializes this AuthUserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthUserModelCopyWith<AuthUserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthUserModelCopyWith<$Res> {
  factory $AuthUserModelCopyWith(
    AuthUserModel value,
    $Res Function(AuthUserModel) then,
  ) = _$AuthUserModelCopyWithImpl<$Res, AuthUserModel>;
  @useResult
  $Res call({
    String uid,
    String email,
    String? firstName,
    String? lastName,
    String? displayName,
    String? phoneNumber,
    String? role,
    List<String> roles,
    String? academyId,
    String? academyName,
    String? academyPhoneNumber,
    String? status,
    String? statusText,
    bool? isActive,
    String? userCode,
  });
}

/// @nodoc
class _$AuthUserModelCopyWithImpl<$Res, $Val extends AuthUserModel>
    implements $AuthUserModelCopyWith<$Res> {
  _$AuthUserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? displayName = freezed,
    Object? phoneNumber = freezed,
    Object? role = freezed,
    Object? roles = null,
    Object? academyId = freezed,
    Object? academyName = freezed,
    Object? academyPhoneNumber = freezed,
    Object? status = freezed,
    Object? statusText = freezed,
    Object? isActive = freezed,
    Object? userCode = freezed,
  }) {
    return _then(
      _value.copyWith(
            uid: null == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            firstName: freezed == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastName: freezed == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String?,
            displayName: freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            role: freezed == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String?,
            roles: null == roles
                ? _value.roles
                : roles // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            academyId: freezed == academyId
                ? _value.academyId
                : academyId // ignore: cast_nullable_to_non_nullable
                      as String?,
            academyName: freezed == academyName
                ? _value.academyName
                : academyName // ignore: cast_nullable_to_non_nullable
                      as String?,
            academyPhoneNumber: freezed == academyPhoneNumber
                ? _value.academyPhoneNumber
                : academyPhoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            statusText: freezed == statusText
                ? _value.statusText
                : statusText // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool?,
            userCode: freezed == userCode
                ? _value.userCode
                : userCode // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuthUserModelImplCopyWith<$Res>
    implements $AuthUserModelCopyWith<$Res> {
  factory _$$AuthUserModelImplCopyWith(
    _$AuthUserModelImpl value,
    $Res Function(_$AuthUserModelImpl) then,
  ) = __$$AuthUserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String uid,
    String email,
    String? firstName,
    String? lastName,
    String? displayName,
    String? phoneNumber,
    String? role,
    List<String> roles,
    String? academyId,
    String? academyName,
    String? academyPhoneNumber,
    String? status,
    String? statusText,
    bool? isActive,
    String? userCode,
  });
}

/// @nodoc
class __$$AuthUserModelImplCopyWithImpl<$Res>
    extends _$AuthUserModelCopyWithImpl<$Res, _$AuthUserModelImpl>
    implements _$$AuthUserModelImplCopyWith<$Res> {
  __$$AuthUserModelImplCopyWithImpl(
    _$AuthUserModelImpl _value,
    $Res Function(_$AuthUserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? displayName = freezed,
    Object? phoneNumber = freezed,
    Object? role = freezed,
    Object? roles = null,
    Object? academyId = freezed,
    Object? academyName = freezed,
    Object? academyPhoneNumber = freezed,
    Object? status = freezed,
    Object? statusText = freezed,
    Object? isActive = freezed,
    Object? userCode = freezed,
  }) {
    return _then(
      _$AuthUserModelImpl(
        uid: null == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        firstName: freezed == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastName: freezed == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String?,
        displayName: freezed == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        role: freezed == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String?,
        roles: null == roles
            ? _value._roles
            : roles // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        academyId: freezed == academyId
            ? _value.academyId
            : academyId // ignore: cast_nullable_to_non_nullable
                  as String?,
        academyName: freezed == academyName
            ? _value.academyName
            : academyName // ignore: cast_nullable_to_non_nullable
                  as String?,
        academyPhoneNumber: freezed == academyPhoneNumber
            ? _value.academyPhoneNumber
            : academyPhoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        statusText: freezed == statusText
            ? _value.statusText
            : statusText // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: freezed == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool?,
        userCode: freezed == userCode
            ? _value.userCode
            : userCode // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthUserModelImpl extends _AuthUserModel {
  const _$AuthUserModelImpl({
    required this.uid,
    required this.email,
    this.firstName,
    this.lastName,
    this.displayName,
    this.phoneNumber,
    this.role,
    final List<String> roles = const <String>[],
    this.academyId,
    this.academyName,
    this.academyPhoneNumber,
    this.status,
    this.statusText,
    this.isActive,
    this.userCode,
  }) : _roles = roles,
       super._();

  factory _$AuthUserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthUserModelImplFromJson(json);

  @override
  final String uid;
  @override
  final String email;
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? displayName;
  @override
  final String? phoneNumber;
  @override
  final String? role;
  final List<String> _roles;
  @override
  @JsonKey()
  List<String> get roles {
    if (_roles is EqualUnmodifiableListView) return _roles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_roles);
  }

  /// Dojang id used by every authenticated call. Wire format is a string.
  @override
  final String? academyId;
  @override
  final String? academyName;
  @override
  final String? academyPhoneNumber;
  @override
  final String? status;
  @override
  final String? statusText;
  @override
  final bool? isActive;
  @override
  final String? userCode;

  @override
  String toString() {
    return 'AuthUserModel(uid: $uid, email: $email, firstName: $firstName, lastName: $lastName, displayName: $displayName, phoneNumber: $phoneNumber, role: $role, roles: $roles, academyId: $academyId, academyName: $academyName, academyPhoneNumber: $academyPhoneNumber, status: $status, statusText: $statusText, isActive: $isActive, userCode: $userCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthUserModelImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.role, role) || other.role == role) &&
            const DeepCollectionEquality().equals(other._roles, _roles) &&
            (identical(other.academyId, academyId) ||
                other.academyId == academyId) &&
            (identical(other.academyName, academyName) ||
                other.academyName == academyName) &&
            (identical(other.academyPhoneNumber, academyPhoneNumber) ||
                other.academyPhoneNumber == academyPhoneNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.statusText, statusText) ||
                other.statusText == statusText) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.userCode, userCode) ||
                other.userCode == userCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    uid,
    email,
    firstName,
    lastName,
    displayName,
    phoneNumber,
    role,
    const DeepCollectionEquality().hash(_roles),
    academyId,
    academyName,
    academyPhoneNumber,
    status,
    statusText,
    isActive,
    userCode,
  );

  /// Create a copy of AuthUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthUserModelImplCopyWith<_$AuthUserModelImpl> get copyWith =>
      __$$AuthUserModelImplCopyWithImpl<_$AuthUserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthUserModelImplToJson(this);
  }
}

abstract class _AuthUserModel extends AuthUserModel {
  const factory _AuthUserModel({
    required final String uid,
    required final String email,
    final String? firstName,
    final String? lastName,
    final String? displayName,
    final String? phoneNumber,
    final String? role,
    final List<String> roles,
    final String? academyId,
    final String? academyName,
    final String? academyPhoneNumber,
    final String? status,
    final String? statusText,
    final bool? isActive,
    final String? userCode,
  }) = _$AuthUserModelImpl;
  const _AuthUserModel._() : super._();

  factory _AuthUserModel.fromJson(Map<String, dynamic> json) =
      _$AuthUserModelImpl.fromJson;

  @override
  String get uid;
  @override
  String get email;
  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  String? get displayName;
  @override
  String? get phoneNumber;
  @override
  String? get role;
  @override
  List<String> get roles;

  /// Dojang id used by every authenticated call. Wire format is a string.
  @override
  String? get academyId;
  @override
  String? get academyName;
  @override
  String? get academyPhoneNumber;
  @override
  String? get status;
  @override
  String? get statusText;
  @override
  bool? get isActive;
  @override
  String? get userCode;

  /// Create a copy of AuthUserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthUserModelImplCopyWith<_$AuthUserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
