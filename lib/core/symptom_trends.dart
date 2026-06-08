import 'package:flutter/foundation.dart';

import '../models/log_entry.dart';

/// A symptom and how often it appears across logs.
@immutable
class SymptomCount {
  const SymptomCount(this.name, this.count);
  final String name;
  final int count;
}

/// Count how often each symptom appears, most frequent first (ties broken
/// alphabetically). Pure + deterministic for tests.
List<SymptomCount> symptomCounts(List<SymptomLog> logs) {
  final counts = <String, int>{};
  for (final log in logs) {
    for (final s in log.symptoms) {
      counts[s] = (counts[s] ?? 0) + 1;
    }
  }
  final entries = counts.entries
      .map((e) => SymptomCount(e.key, e.value))
      .toList()
    ..sort((a, b) {
      final byCount = b.count.compareTo(a.count);
      return byCount != 0 ? byCount : a.name.compareTo(b.name);
    });
  return entries;
}

/// The [n] most common symptoms.
List<SymptomCount> topSymptoms(List<SymptomLog> logs, {int n = 5}) =>
    symptomCounts(logs).take(n).toList();

/// Logs that have a mood set (1–5), sorted oldest-first — handy for charts.
List<SymptomLog> moodLogs(List<SymptomLog> logs) {
  final list = logs.where((l) => l.mood > 0).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  return list;
}

/// Average mood (1–5) across logs that have a mood set, or null if none.
double? averageMood(List<SymptomLog> logs) {
  final moods = logs.where((l) => l.mood > 0).map((l) => l.mood).toList();
  if (moods.isEmpty) return null;
  return moods.reduce((a, b) => a + b) / moods.length;
}

/// Number of distinct calendar days that have at least one log.
int loggedDays(List<SymptomLog> logs) {
  final days = <String>{};
  for (final l in logs) {
    days.add('${l.date.year}-${l.date.month}-${l.date.day}');
  }
  return days.length;
}
