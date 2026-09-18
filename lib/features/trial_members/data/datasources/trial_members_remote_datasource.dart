import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/network_exceptions.dart';
import '../models/trial_member_model.dart';

/// Remote data source for Trial Member list endpoints.
class TrialMembersRemoteDataSource {
  TrialMembersRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<TrialMemberModel>> getTrialStudents(String dojangId, String category) async {
    try {
      final response = await _client.get<List<dynamic>>(
        Api.trialStudents(dojangId),
        queryParameters: {'category': category},
      );

      final data = response.data ?? [];
      return data
          .map((item) => TrialMemberModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}

final trialMembersRemoteDataSourceProvider =
    Provider<TrialMembersRemoteDataSource>((ref) {
  return TrialMembersRemoteDataSource(ref.watch(dioClientProvider));
});
