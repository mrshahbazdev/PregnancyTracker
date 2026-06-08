import '../models/log_entry.dart';

/// Daily water goal (glasses) recommended during pregnancy.
const int kWaterGoal = 8;

/// Stable yyyy-MM-dd key for a given day (local time, ignores time-of-day).
String wellnessDateKey(DateTime date) {
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '${date.year}-$m-$d';
}

/// Consecutive-day logging streak ending on (or just before) [today].
///
/// A day counts toward the streak if it has any activity. If today has no
/// activity yet, the streak is measured from yesterday so a day in progress
/// doesn't reset a run; the streak only breaks once a full day is missed.
int wellnessStreak(List<WellnessDay> days, DateTime today) {
  final active = <String>{
    for (final d in days)
      if (d.hasActivity) d.dateKey,
  };
  if (active.isEmpty) return 0;

  final todayKey = wellnessDateKey(today);
  var cursor = DateTime(today.year, today.month, today.day);
  // If today isn't logged yet, start counting from yesterday.
  if (!active.contains(todayKey)) {
    cursor = cursor.subtract(const Duration(days: 1));
  }

  var streak = 0;
  while (active.contains(wellnessDateKey(cursor))) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}
