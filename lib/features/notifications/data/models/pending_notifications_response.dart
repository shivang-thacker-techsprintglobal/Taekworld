/// `GET /api/Notification/pending/{dojangId}` response.
class PendingNotificationsResponse {
  const PendingNotificationsResponse({
    required this.dojangId,
    required this.totalCount,
    required this.notifications,
  });

  final String dojangId;
  final int totalCount;
  final List<PendingNotificationItem> notifications;

  factory PendingNotificationsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['notifications'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(PendingNotificationItem.fromJson)
        .toList();
    return PendingNotificationsResponse(
      dojangId: '${json['dojangId'] ?? ''}',
      totalCount: (json['totalCount'] as num?)?.toInt() ?? list.length,
      notifications: list,
    );
  }
}

class PendingNotificationItem {
  const PendingNotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.payload = '',
    this.createdAt,
    this.entityType = '',
    this.entityId = '',
  });

  final int id;
  final String type;
  final String title;
  final String message;
  final String payload;
  final DateTime? createdAt;
  final String entityType;
  final String entityId;

  factory PendingNotificationItem.fromJson(Map<String, dynamic> json) {
    return PendingNotificationItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type']?.toString() ?? 'other',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      payload: json['payload']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      entityType: json['entityType']?.toString() ?? '',
      entityId: json['entityId']?.toString() ?? '',
    );
  }
}
