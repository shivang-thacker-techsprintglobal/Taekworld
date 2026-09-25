import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../main_shell/application/shell_providers.dart';
import '../../data/repositories/trial_members_repository_impl.dart';
import '../../domain/repositories/trial_members_repository.dart';
import 'trial_members_state.dart';

class TrialMembersController extends StateNotifier<TrialMembersState> {
  TrialMembersController(this._repository, this._ref)
      : super(const TrialMembersInitial());

  final TrialMembersRepository _repository;
  final Ref _ref;

  /// Loads trial members.
  ///
  /// [isSilent] background refreshes (push / timer) never show a loader.
  /// Manual refresh with data already on screen uses the app-bar spinner only.
  Future<void> loadTrialMembers(String dojangId, {bool isSilent = false}) async {
    final hasData = state is TrialMembersSuccess;

    if (!hasData) {
      if (!isSilent) {
        state = const TrialMembersLoading();
      }
    } else if (!isSilent) {
      final current = state as TrialMembersSuccess;
      if (!current.isRefreshing) {
        state = current.copyWith(isRefreshing: true);
      }
    }

    try {
      final result = await _repository.getTrialMembers(dojangId);
      final newState = TrialMembersSuccess(
        sevenDay: result.sevenDay,
        thirtyDay: result.thirtyDay,
        isRefreshing: false,
      );
      state = newState;

      // Update badge in Main Shell
      _ref.read(trialMembersBadgeProvider.notifier).state = newState.newMembersCount;
    } on Failure catch (failure) {
      if (state is! TrialMembersSuccess) {
        state = TrialMembersError(failure.message);
      } else {
        final current = state as TrialMembersSuccess;
        state = current.copyWith(isRefreshing: false);
      }
    } catch (_) {
      if (state is! TrialMembersSuccess) {
        state = const TrialMembersError('Failed to load trial members.');
      } else {
        final current = state as TrialMembersSuccess;
        state = current.copyWith(isRefreshing: false);
      }
    }
  }
}

final trialMembersControllerProvider =
    StateNotifierProvider<TrialMembersController, TrialMembersState>((ref) {
  return TrialMembersController(
    ref.watch(trialMembersRepositoryProvider),
    ref,
  );
});
