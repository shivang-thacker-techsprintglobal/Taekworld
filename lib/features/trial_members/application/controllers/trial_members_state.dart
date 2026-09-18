import '../../domain/entities/trial_member_entity.dart';

abstract class TrialMembersState {
  const TrialMembersState();
}

class TrialMembersInitial extends TrialMembersState {
  const TrialMembersInitial();
}

class TrialMembersLoading extends TrialMembersState {
  const TrialMembersLoading();
}

class TrialMembersSuccess extends TrialMembersState {
  const TrialMembersSuccess({
    required this.sevenDay,
    required this.thirtyDay,
    this.isRefreshing = false,
  });

  final List<TrialMemberEntity> sevenDay;
  final List<TrialMemberEntity> thirtyDay;
  final bool isRefreshing;

  int get totalSevenDay => sevenDay.length;
  int get totalThirtyDay => thirtyDay.length;
  int get totalMembers => totalSevenDay + totalThirtyDay;
  int get newMembersCount =>
      sevenDay.where((m) => m.isNewStudent).length +
      thirtyDay.where((m) => m.isNewStudent).length;

  TrialMembersSuccess copyWith({
    List<TrialMemberEntity>? sevenDay,
    List<TrialMemberEntity>? thirtyDay,
    bool? isRefreshing,
  }) {
    return TrialMembersSuccess(
      sevenDay: sevenDay ?? this.sevenDay,
      thirtyDay: thirtyDay ?? this.thirtyDay,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class TrialMembersError extends TrialMembersState {
  const TrialMembersError(this.message);
  final String message;
}
