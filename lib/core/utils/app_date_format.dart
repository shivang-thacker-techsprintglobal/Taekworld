/// Shared display-date helpers (UI-SPEC uses `M/D/YYYY`).
abstract final class AppDateFormat {
  /// Formats ISO / common date strings as `M/D/YYYY`.
  ///
  /// Returns [fallback] when [raw] is empty or unparseable.
  static String display(
    String? raw, {
    String fallback = 'N/A',
  }) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return fallback;

    final parsed = DateTime.tryParse(value) ?? _trySlashOrDash(value);
    if (parsed == null) return value;

    return '${parsed.month}/${parsed.day}/${parsed.year}';
  }

  /// Like [display], but returns '' when empty (for optional fields).
  static String displayOrEmpty(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return '';
    return display(value, fallback: value);
  }

  static DateTime? _trySlashOrDash(String value) {
    // yyyy-MM-dd or yyyy/MM/dd (date-only without time)
    final parts = value.split(RegExp(r'[T\s]')).first.split(RegExp(r'[-/]'));
    if (parts.length != 3) return null;

    final a = int.tryParse(parts[0]);
    final b = int.tryParse(parts[1]);
    final c = int.tryParse(parts[2]);
    if (a == null || b == null || c == null) return null;

    // Year-first
    if (parts[0].length == 4) {
      return DateTime(a, b, c);
    }
    // M/D/YYYY or D/M/YYYY — prefer US M/D/YYYY per UI-SPEC
    if (parts[2].length == 4) {
      return DateTime(c, a, b);
    }
    return null;
  }
}
