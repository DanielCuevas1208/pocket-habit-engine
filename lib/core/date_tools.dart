class DateTools {
  const DateTools._();

  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime daysFromToday(int offset) {
    final date = today();
    return DateTime(date.year, date.month, date.day + offset);
  }

  static DateTime addDays(DateTime date, int offset) {
    return DateTime(date.year, date.month, date.day + offset);
  }

  static int inclusiveDaysBetween(DateTime start, DateTime end) {
    final startUtc = DateTime.utc(start.year, start.month, start.day);
    final endUtc = DateTime.utc(end.year, end.month, end.day);
    if (endUtc.isBefore(startUtc)) return 0;
    return endUtc.difference(startUtc).inDays + 1;
  }

  static String key(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().substring(0, 10);
  }

  static DateTime fromKey(String value) {
    final parts = value.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  static String shortWeekday(DateTime date) {
    const names = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[date.weekday - 1];
  }

  static String monthAndDay(DateTime date) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
