import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../data/repositories/applications_repository_impl.dart';
import '../../domain/entities/application_detail_entity.dart';
import '../../domain/repositories/applications_repository.dart';

abstract class ApplicationDetailState {
  const ApplicationDetailState();
}

class ApplicationDetailLoading extends ApplicationDetailState {
  const ApplicationDetailLoading();
}

class ApplicationDetailSuccess extends ApplicationDetailState {
  const ApplicationDetailSuccess(this.detail);
  final ApplicationDetailEntity detail;
}

class ApplicationDetailError extends ApplicationDetailState {
  const ApplicationDetailError(this.message);
  final String message;
}

class ApplicationDetailController extends StateNotifier<ApplicationDetailState> {
  ApplicationDetailController(this._repository)
      : super(const ApplicationDetailLoading());

  final ApplicationsRepository _repository;

  Future<void> loadDetail(String applicationId) async {
    state = const ApplicationDetailLoading();
    try {
      final detail = await _repository.getApplicationDetail(applicationId);
      state = ApplicationDetailSuccess(detail);
    } on Failure catch (failure) {
      state = ApplicationDetailError(failure.message);
    } catch (_) {
      state = const ApplicationDetailError('Failed to load application details.');
    }
  }
}

final applicationDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<ApplicationDetailController, ApplicationDetailState, String>(
        (ref, applicationId) {
  final controller = ApplicationDetailController(ref.watch(applicationsRepositoryProvider));
  controller.loadDetail(applicationId);
  return controller;
});
