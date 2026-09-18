import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/dojang_statistics_entity.dart';

part 'dojang_statistics_model.freezed.dart';
part 'dojang_statistics_model.g.dart';

@freezed
class DojangStatisticsModel with _$DojangStatisticsModel {
  const factory DojangStatisticsModel({
    @Default(0) int currentStudents,
    @Default(0) int sevenDaysTrial,
    @Default(0) int thirtyDaysTrial,
    @Default(0) int newStudents,
    @Default(0) int totalMembers,
    @Default(0) int recommendationCount,
  }) = _DojangStatisticsModel;

  factory DojangStatisticsModel.fromJson(Map<String, dynamic> json) =>
      _$DojangStatisticsModelFromJson(json);
}

extension DojangStatisticsModelX on DojangStatisticsModel {
  DojangStatisticsEntity toEntity() => DojangStatisticsEntity(
        currentStudents: currentStudents,
        sevenDaysTrial: sevenDaysTrial,
        thirtyDaysTrial: thirtyDaysTrial,
        newStudents: newStudents,
        totalMembers: totalMembers,
        recommendationCount: recommendationCount,
      );
}
