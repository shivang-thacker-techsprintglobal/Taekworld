import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions/network_exceptions.dart';
import '../models/pending_notifications_response.dart';

/// Remote Notification API (register / delete / pending / mark-delivered).
class NotificationsRemoteDatasource {
  NotificationsRemoteDatasource(this._client);

  final DioClient _client;

  Future<void> registerDevice({
    required String fcmToken,
    required String platform,
    required int dojangId,
    required String deviceInfo,
  }) async {
    try {
      await _client.post<Map<String, dynamic>>(
        Api.registerDevice,
        data: {
          'fcmToken': fcmToken,
          'platform': platform,
          'dojangId': dojangId,
          'deviceInfo': deviceInfo,
        },
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> deleteDevice({required String fcmToken}) async {
    try {
      await _client.post<Map<String, dynamic>>(
        Api.deleteDevice,
        data: {'fcmToken': fcmToken},
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<PendingNotificationsResponse> getPending({
    required String dojangId,
    required String deviceId,
  }) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        Api.pendingNotifications(dojangId),
        queryParameters: {'deviceId': deviceId},
      );
      return PendingNotificationsResponse.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  Future<void> markDelivered({
    required List<int> notificationIds,
    required String deviceId,
  }) async {
    if (notificationIds.isEmpty) return;
    try {
      await _client.post<Map<String, dynamic>>(
        Api.markDelivered,
        data: {
          'notificationIds': notificationIds,
          'deviceId': deviceId,
        },
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}

final notificationsRemoteDatasourceProvider =
    Provider<NotificationsRemoteDatasource>((ref) {
  return NotificationsRemoteDatasource(ref.watch(dioClientProvider));
});
