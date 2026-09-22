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

  Future<List<TrialMemberModel>> getSevenDayTrials(String dojangId) {
    return _getByCategory(dojangId, Api.trialCategorySevenDay);
  }

  Future<List<TrialMemberModel>> getThirtyDayTrials(String dojangId) {
    return _getByCategory(dojangId, Api.trialCategoryThirtyDay);
  }

  Future<List<TrialMemberModel>> _getByCategory(
    String dojangId,
    String category,
  ) async {
    try {
      final response = await _client.get<dynamic>(
        Api.trialMembers(dojangId),
        queryParameters: {'category': category},
      );

      final data = response.data;
      if (data is! List) {
        throw const UnknownNetworkException(
          'Unexpected trial members response.',
        );
      }

      return data
          .whereType<Map>()
          .map(
            (item) => TrialMemberModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
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
