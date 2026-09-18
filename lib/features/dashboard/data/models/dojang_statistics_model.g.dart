// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dojang_statistics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DojangStatisticsModelImpl _$$DojangStatisticsModelImplFromJson(
  Map<String, dynamic> json,
) => _$DojangStatisticsModelImpl(
  currentStudents: (json['currentStudents'] as num?)?.toInt() ?? 0,
  sevenDaysTrial: (json['sevenDaysTrial'] as num?)?.toInt() ?? 0,
  thirtyDaysTrial: (json['thirtyDaysTrial'] as num?)?.toInt() ?? 0,
  newStudents: (json['newStudents'] as num?)?.toInt() ?? 0,
  totalMembers: (json['totalMembers'] as num?)?.toInt() ?? 0,
  recommendationCount: (json['recommendationCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$DojangStatisticsModelImplToJson(
  _$DojangStatisticsModelImpl instance,
) => <String, dynamic>{
  'currentStudents': instance.currentStudents,
  'sevenDaysTrial': instance.sevenDaysTrial,
  'thirtyDaysTrial': instance.thirtyDaysTrial,
  'newStudents': instance.newStudents,
  'totalMembers': instance.totalMembers,
  'recommendationCount': instance.recommendationCount,
};
