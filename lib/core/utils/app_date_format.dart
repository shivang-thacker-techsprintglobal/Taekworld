/// Shared display-date helpers.
///
/// API timestamps are ISO-8601 **UTC**. UI-SPEC list style is `M/D/YYYY`;
/// when a value includes a real time, we show local `M/D/YYYY h:mm a`.
abstract final class AppDateFormat {
  /// Calendar date only (`M/D/YYYY`), no timezone shift for `yyyy-MM-dd` /
  /// midnight UTC values (safe for DOB / date-only fields).
  static String displayDate(
    String? raw, {
    String fallback = 'N/A',
  }) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return fallback;

    final ymd = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(value);
    if (ymd != null) {
      final month = int.parse(ymd.group(2)!);
      final day = int.parse(ymd.group(3)!);
      final year = int.parse(ymd.group(1)!);
      return '$month/$day/$year';
    }

    final parsed = DateTime.tryParse(value) ?? _trySlashOrDash(value);
    if (parsed == null) return value;
    final local = parsed.toLocal();
    return '${local.month}/${local.day}/${local.year}';
  }

  /// Local date + time (`M/D/YYYY h:mm a`) from a UTC/ISO timestamp.
  static String displayDateTime(
    String? raw, {
    String fallback = 'N/A',
  }) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return fallback;

    final parsed = DateTime.tryParse(value) ?? _trySlashOrDash(value);
    if (parsed == null) return value;

    final local = parsed.toLocal();
    return '${local.month}/${local.day}/${local.year} ${_formatTime(local)}';
  }

  /// Date-only when there is no meaningful clock time; otherwise local date+time.
  ///
  /// Prefer [displayDate] for DOB. Prefer [displayDateTime] when the API field
  /// is known to be a full timestamp (e.g. `applicationDateValue`).
  static String display(
    String? raw, {
    String fallback = 'N/A',
  }) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return fallback;

    if (!_hasMeaningfulTime(value)) {
      return displayDate(value, fallback: fallback);
    }
    return displayDateTime(value, fallback: fallback);
  }

  /// Like [display], but returns '' when empty (optional fields).
  static String displayOrEmpty(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return '';
    return display(value, fallback: value);
  }

  static bool _hasMeaningfulTime(String raw) {
    if (!raw.contains('T') && !RegExp(r'\d:\d{2}').hasMatch(raw)) {
      return false;
    }
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return false;
    // Midnight UTC with only a date intent (common for DOB) → date-only.
    final utc = parsed.toUtc();
    return utc.hour != 0 || utc.minute != 0 || utc.second != 0 || utc.millisecond != 0;
  }

  static String _formatTime(DateTime local) {
    final hour24 = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$hour12:$minute $period';
  }

  static DateTime? _trySlashOrDash(String value) {
    final parts = value.split(RegExp(r'[T\s]')).first.split(RegExp(r'[-/]'));
    if (parts.length != 3) return null;

    final a = int.tryParse(parts[0]);
    final b = int.tryParse(parts[1]);
    final c = int.tryParse(parts[2]);
    if (a == null || b == null || c == null) return null;

    if (parts[0].length == 4) {
      return DateTime.utc(a, b, c);
    }
    if (parts[2].length == 4) {
      return DateTime(c, a, b);
    }
    return null;
  }
}
