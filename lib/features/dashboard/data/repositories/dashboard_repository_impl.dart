import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/exceptions/network_exceptions.dart';
import '../../domain/entities/dojang_statistics_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dojang_statistics_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._remote);

  final DashboardRemoteDataSource _remote;

  @override
  Future<DojangStatisticsEntity> getStatistics(String dojangId) async {
    if (AppConstants.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return const DojangStatisticsEntity(
        currentStudents: 146,
        sevenDaysTrial: 31,
        thirtyDaysTrial: 101,
        newStudents: 12,
        totalMembers: 290,
        recommendationCount: 56,
      );
    }

    try {
      final model = await _remote.getStatistics(dojangId);
      return model.toEntity();
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

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardRemoteDataSourceProvider));
});
