import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/exceptions/network_exceptions.dart';
import '../../domain/entities/trial_member_entity.dart';
import '../../domain/repositories/trial_members_repository.dart';
import '../datasources/trial_members_remote_datasource.dart';

class TrialMembersRepositoryImpl implements TrialMembersRepository {
  TrialMembersRepositoryImpl(this._remote);

  final TrialMembersRemoteDataSource _remote;

  static const List<TrialMemberEntity> _mockSevenDay = [
    TrialMemberEntity(
      id: 101,
      name: 'Jay Smith',
      email: 'p.smith@example.com',
      parentName: 'Pat Smith',
      parentPhone: '(703) 555-0100',
      joinDate: '9/15/2026',
      status: 'new',
      trialEndDate: '9/22/2026',
      trialType: '7',
      userCode: 'TM-7011',
      registrationDate: '9/15/2026',
      daysRemaining: 4,
      isNewStudent: true,
    ),
    TrialMemberEntity(
      id: 102,
      name: 'Chloe Wilson',
      email: 'wilson.c@example.com',
      parentName: 'Robert Wilson',
      parentPhone: '(703) 555-0133',
      joinDate: '9/12/2026',
      status: 'new',
      trialEndDate: '9/19/2026',
      trialType: '7',
      userCode: 'TM-7012',
      registrationDate: '9/12/2026',
      daysRemaining: 1,
      isNewStudent: true,
    ),
    TrialMemberEntity(
      id: 103,
      name: 'Mason Miller',
      email: 'mason.m@example.com',
      parentName: 'Karen Miller',
      parentPhone: '(703) 555-0155',
      joinDate: '9/08/2026',
      status: 'expired',
      trialEndDate: '9/15/2026',
      trialType: '7',
      userCode: 'TM-7009',
      registrationDate: '9/08/2026',
      daysRemaining: 0,
      isNewStudent: false,
    ),
  ];

  static const List<TrialMemberEntity> _mockThirtyDay = [
    TrialMemberEntity(
      id: 201,
      name: 'Ava Martinez',
      email: 'ava.m@example.com',
      parentName: 'Elena Martinez',
      parentPhone: '(703) 555-0188',
      joinDate: '9/01/2026',
      status: 'new',
      trialEndDate: '10/01/2026',
      trialType: '30',
      userCode: 'TM-3021',
      registrationDate: '9/01/2026',
      daysRemaining: 13,
      isNewStudent: true,
    ),
    TrialMemberEntity(
      id: 202,
      name: 'Noah Johnson',
      email: 'johnson.family@example.com',
      parentName: 'Mark Johnson',
      parentPhone: '(703) 555-0192',
      joinDate: '8/25/2026',
      status: 'active',
      trialEndDate: '9/25/2026',
      trialType: '30',
      userCode: 'TM-3018',
      registrationDate: '8/25/2026',
      daysRemaining: 7,
      isNewStudent: false,
    ),
  ];

  @override
  Future<({List<TrialMemberEntity> sevenDay, List<TrialMemberEntity> thirtyDay})>
      getTrialMembers(String dojangId) async {
    if (AppConstants.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return (sevenDay: _mockSevenDay, thirtyDay: _mockThirtyDay);
    }

    try {
      final sevenRaw = await _remote.getTrialStudents(dojangId, '7 days trial');
      final thirtyRaw = await _remote.getTrialStudents(dojangId, '30 days trial');
      return (
        sevenDay: sevenRaw.map((m) => m.toEntity()).toList(),
        thirtyDay: thirtyRaw.map((m) => m.toEntity()).toList(),
      );
    } on NetworkException catch (error) {
      throw _mapNetworkException(error);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }

  Failure _mapNetworkException(NetworkException error) {
    return switch (error) {
      UnauthorizedException() || ForbiddenException() =>
        AuthFailure(error.message),
      NoInternetException() || TimeoutException() =>
        NetworkFailure(error.message),
      ServerException() || BadRequestException() || NotFoundException() =>
        ServerFailure(error.message),
      UnknownNetworkException() => UnexpectedFailure(error.message),
    };
  }
}

final trialMembersRepositoryProvider = Provider<TrialMembersRepository>((ref) {
  return TrialMembersRepositoryImpl(ref.watch(trialMembersRemoteDataSourceProvider));
});
