import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/exceptions/network_exceptions.dart';
import '../../domain/entities/trial_member_entity.dart';
import '../../domain/repositories/trial_members_repository.dart';
import '../datasources/trial_members_remote_datasource.dart';

class TrialMembersRepositoryImpl implements TrialMembersRepository {
  TrialMembersRepositoryImpl(this._remote);

  final TrialMembersRemoteDataSource _remote;

  @override
  Future<({List<TrialMemberEntity> sevenDay, List<TrialMemberEntity> thirtyDay})>
      getTrialMembers(String dojangId) async {
    try {
      final results = await Future.wait([
        _remote.getSevenDayTrials(dojangId),
        _remote.getThirtyDayTrials(dojangId),
      ]);

      return (
        sevenDay: results[0].map((m) => m.toEntity()).toList(),
        thirtyDay: results[1].map((m) => m.toEntity()).toList(),
      );
    } on NetworkException catch (error) {
      throw _mapNetworkException(error);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }

  Failure _mapNetworkException(NetworkException error) {
    return switch (error) {
      UnauthorizedException() || ForbiddenException() || RateLimitException() =>
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
  return TrialMembersRepositoryImpl(
    ref.watch(trialMembersRemoteDataSourceProvider),
  );
});
