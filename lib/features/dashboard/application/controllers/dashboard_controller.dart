import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';
import 'dashboard_state.dart';

class DashboardController extends StateNotifier<DashboardState> {
  DashboardController(this._repository) : super(const DashboardState.initial());

  final DashboardRepository _repository;

  Future<void> loadStatistics(String dojangId, {bool isSilent = false}) async {
    if (!isSilent) {
      if (state is! DashboardSuccess) {
        state = const DashboardState.loading();
      }
    } else if (state is DashboardSuccess) {
      final current = state as DashboardSuccess;
      state = current.copyWith(isRefreshing: true);
    }

    try {
      final stats = await _repository.getStatistics(dojangId);
      state = DashboardState.success(statistics: stats, isRefreshing: false);
    } on Failure catch (failure) {
      if (state is! DashboardSuccess) {
        state = DashboardState.error(failure.message);
      } else {
        // Keep existing data on background refresh failure
        final current = state as DashboardSuccess;
        state = current.copyWith(isRefreshing: false);
      }
    } catch (_) {
      if (state is! DashboardSuccess) {
        state = const DashboardState.error(
          'Failed to load statistics. Please try again.',
        );
      } else {
        final current = state as DashboardSuccess;
        state = current.copyWith(isRefreshing: false);
      }
    }
  }
}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
  return DashboardController(ref.watch(dashboardRepositoryProvider));
});
