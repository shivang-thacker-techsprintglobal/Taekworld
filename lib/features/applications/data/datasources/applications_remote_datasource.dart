import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/network_exceptions.dart';
import '../models/application_detail_model.dart';
import '../models/applications_response_model.dart';

/// Remote data source for Applications API endpoints.
class ApplicationsRemoteDataSource {
  ApplicationsRemoteDataSource(this._client);

  final DioClient _client;

  Future<ApplicationsResponseModel> getApplications(String dojangId) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        Api.applications(dojangId),
      );

      final data = response.data;
      if (data == null) {
        throw const UnknownNetworkException('Empty applications response.');
      }

      final payload = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;

      return ApplicationsResponseModel.fromJson(payload);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<ApplicationDetailModel> getApplicationDetail(String applicationId) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        Api.applicationDetail(applicationId),
      );

      final data = response.data;
      if (data == null) {
        throw const UnknownNetworkException('Empty application detail response.');
      }

      final payload = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;

      return ApplicationDetailModel.fromJson(payload);
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}

final applicationsRemoteDataSourceProvider =
    Provider<ApplicationsRemoteDataSource>((ref) {
  return ApplicationsRemoteDataSource(ref.watch(dioClientProvider));
});
