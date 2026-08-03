import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_habit_engine/core/date_tools.dart';

void main() {
  test('key formats dates as ISO day strings', () {
    expect(DateTools.key(DateTime(2026, 3, 5)), '2026-03-05');
    expect(DateTools.key(DateTime(2026, 12, 1)), '2026-12-01');
  });

  test('fromKey restores the same local day', () {
    expect(DateTools.fromKey('2026-03-05'), DateTime(2026, 3, 5));
  });

  test('key and fromKey round trip without loss', () {
    final source = DateTime(2026, 12, 31);
    expect(DateTools.fromKey(DateTools.key(source)), DateTime(2026, 12, 31));
  });

  test('addDays crosses month boundaries', () {
    expect(DateTools.addDays(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 1));
    expect(DateTools.addDays(DateTime(2026, 2, 28), 1), DateTime(2026, 3, 1));
    expect(DateTools.addDays(DateTime(2026, 3, 1), -1), DateTime(2026, 2, 28));
  });

  test('inclusiveDaysBetween counts both endpoints', () {
    expect(
      DateTools.inclusiveDaysBetween(DateTime(2026, 1, 1), DateTime(2026, 1, 7)),
      7,
    );
    expect(
      DateTools.inclusiveDaysBetween(DateTime(2026, 1, 7), DateTime(2026, 1, 1)),
      0,
    );
  });

  test('shortWeekday returns Mon through Sun', () {
    expect(DateTools.shortWeekday(DateTime(2026, 3, 2)), 'Mon');
    expect(DateTools.shortWeekday(DateTime(2026, 3, 8)), 'Sun');
  });

  test('monthAndDay formats a friendly label', () {
    expect(DateTools.monthAndDay(DateTime(2026, 3, 5)), 'Mar 5');
    expect(DateTools.monthAndDay(DateTime(2026, 12, 25)), 'Dec 25');
  });
}
