import '../entities/dojang_statistics_entity.dart';

/// Contract for dashboard repository operations.
abstract class DashboardRepository {
  Future<DojangStatisticsEntity> getStatistics(String dojangId);
}
