import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../main_shell/application/shell_providers.dart';
import '../../data/repositories/applications_repository_impl.dart';
import '../../domain/repositories/applications_repository.dart';
import 'applications_state.dart';

class ApplicationsController extends StateNotifier<ApplicationsState> {
  ApplicationsController(this._repository, this._ref)
      : super(const ApplicationsInitial());

  final ApplicationsRepository _repository;
  final Ref _ref;

  Future<void> loadApplications(String dojangId, {bool isSilent = false}) async {
    if (!isSilent) {
      if (state is! ApplicationsSuccess) {
        state = const ApplicationsLoading();
      }
    } else if (state is ApplicationsSuccess) {
      final current = state as ApplicationsSuccess;
      state = current.copyWith(isRefreshing: true);
    }

    try {
      final result = await _repository.getApplications(dojangId);
      final newState = ApplicationsSuccess(
        pending: result.pending,
        history: result.history,
        isRefreshing: false,
      );
      state = newState;

      // Update badge in Main Shell
      _ref.read(applicationsBadgeProvider.notifier).state = newState.unviewedCount;
    } on Failure catch (failure) {
      if (state is! ApplicationsSuccess) {
        state = ApplicationsError(failure.message);
      } else {
        final current = state as ApplicationsSuccess;
        state = current.copyWith(isRefreshing: false);
      }
    } catch (_) {
      if (state is! ApplicationsSuccess) {
        state = const ApplicationsError('Failed to load student applications.');
      } else {
        final current = state as ApplicationsSuccess;
        state = current.copyWith(isRefreshing: false);
      }
    }
  }

  void markAsViewed(int id) {
    if (state is ApplicationsSuccess) {
      final current = state as ApplicationsSuccess;
      final today = DateTime.now();
      final stamp =
          '${today.year.toString().padLeft(4, '0')}-'
          '${today.month.toString().padLeft(2, '0')}-'
          '${today.day.toString().padLeft(2, '0')}';

      final updatedPending = current.pending.map((item) {
        if (item.id == id) {
          return item.copyWith(
            isViewed: true,
            viewedDateFormatted: stamp,
          );
        }
        return item;
      }).toList();

      final newState = current.copyWith(pending: updatedPending);
      state = newState;
      _ref.read(applicationsBadgeProvider.notifier).state = newState.unviewedCount;
    }
  }
}

final applicationsControllerProvider =
    StateNotifierProvider<ApplicationsController, ApplicationsState>((ref) {
  return ApplicationsController(
    ref.watch(applicationsRepositoryProvider),
    ref,
  );
});
