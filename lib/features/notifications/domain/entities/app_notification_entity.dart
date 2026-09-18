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
  });

  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type;
  final bool isRead;
  final String? url;

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
  }) {
    return AppNotificationEntity(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      type: type,
      isRead: isRead ?? this.isRead,
      url: url ?? this.url,
    );
  }
}
