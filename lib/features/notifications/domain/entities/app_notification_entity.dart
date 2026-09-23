/// Notification entity per UI-SPEC §4.7.
class AppNotificationEntity {
  const AppNotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.type = 'other',
    this.isRead = false,
    this.url,
    this.entityId,
  });

  final String id;
  final String title;
  final String message;
  final DateTime timestamp;

  /// Normalized UI type: application | trial | registration | invitation | other
  final String type;
  final bool isRead;
  final String? url;
  final String? entityId;

  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }

  AppNotificationEntity copyWith({
    bool? isRead,
    String? url,
  }) {
    return AppNotificationEntity(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      type: type,
      isRead: isRead ?? this.isRead,
      url: url ?? this.url,
      entityId: entityId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'type': type,
        'isRead': isRead,
        'url': url,
        'entityId': entityId,
      };

  factory AppNotificationEntity.fromJson(Map<String, dynamic> json) {
    return AppNotificationEntity(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      type: json['type']?.toString() ?? 'other',
      isRead: json['isRead'] as bool? ?? false,
      url: json['url']?.toString(),
      entityId: json['entityId']?.toString(),
    );
  }

  /// Maps server `NotificationType` / FCM data `type` into UI type keys.
  static String normalizeType(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    if (value.contains('application') || value == 'newapplication') {
      return 'application';
    }
    if (value.contains('trial') || value == 'newtrialmember') {
      return 'trial';
    }
    if (value.contains('registration') || value == 'newregistration') {
      return 'registration';
    }
    if (value.contains('invitation') || value == 'parentinvitation') {
      return 'invitation';
    }
    if (value == 'application' ||
        value == 'trial' ||
        value == 'registration' ||
        value == 'invitation') {
      return value;
    }
    return 'other';
  }
}
