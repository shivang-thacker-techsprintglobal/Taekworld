import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/dojang_statistics_entity.dart';

part 'dashboard_state.freezed.dart';

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState.initial() = DashboardInitial;
  const factory DashboardState.loading() = DashboardLoading;
  const factory DashboardState.success({
    required DojangStatisticsEntity statistics,
    @Default(false) bool isRefreshing,
  }) = DashboardSuccess;
  const factory DashboardState.error(String message) = DashboardError;
}
