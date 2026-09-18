import '../entities/trial_member_entity.dart';

abstract class TrialMembersRepository {
  Future<({List<TrialMemberEntity> sevenDay, List<TrialMemberEntity> thirtyDay})>
      getTrialMembers(String dojangId);
}
