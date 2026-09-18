import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/network_exceptions.dart';
import '../models/dojang_statistics_model.dart';

/// Remote data source for Dashboard / My Dojang APIs.
class DashboardRemoteDataSource {
  DashboardRemoteDataSource(this._client);

  final DioClient _client;

  Future<DojangStatisticsModel> getStatistics(String dojangId) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        Api.statistics(dojangId),
      );

      final data = response.data;
      if (data == null) {
        throw const UnknownNetworkException('Empty statistics response.');
      }

      final payload = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;

      return DojangStatisticsModel.fromJson(payload);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}

final dashboardRemoteDataSourceProvider =
    Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSource(ref.watch(dioClientProvider));
});
