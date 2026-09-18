import '../../domain/entities/application_item_entity.dart';

abstract class ApplicationsState {
  const ApplicationsState();
}

class ApplicationsInitial extends ApplicationsState {
  const ApplicationsInitial();
}

class ApplicationsLoading extends ApplicationsState {
  const ApplicationsLoading();
}

class ApplicationsSuccess extends ApplicationsState {
  const ApplicationsSuccess({
    required this.pending,
    required this.history,
    this.isRefreshing = false,
  });

  final List<ApplicationItemEntity> pending;
  final List<ApplicationItemEntity> history;
  final bool isRefreshing;

  int get unviewedCount => pending.where((item) => item.isNew).length;
  int get totalPending => pending.length;
  int get totalHistory => history.length;

  ApplicationsSuccess copyWith({
    List<ApplicationItemEntity>? pending,
    List<ApplicationItemEntity>? history,
    bool? isRefreshing,
  }) {
    return ApplicationsSuccess(
      pending: pending ?? this.pending,
      history: history ?? this.history,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class ApplicationsError extends ApplicationsState {
  const ApplicationsError(this.message);
  final String message;
}
