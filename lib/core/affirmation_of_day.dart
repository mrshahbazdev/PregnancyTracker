import 'affirmations_data.dart';

/// Deterministic "affirmation of the day": stable for a given calendar [date]
/// so it doesn't change on rebuilds, but rotates day to day. Pure for tests.
Affirmation affirmationOfDay(DateTime date,
    {List<Affirmation> pool = kAffirmations}) {
  assert(pool.isNotEmpty);
  // Days since epoch as a stable rotating index.
  final dayNumber =
      DateTime(date.year, date.month, date.day).millisecondsSinceEpoch ~/
          Duration.millisecondsPerDay;
  final idx = dayNumber % pool.length;
  return pool[idx];
}
