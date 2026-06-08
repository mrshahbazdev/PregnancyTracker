import 'package:flutter/foundation.dart';

import '../models/log_entry.dart';

/// Aggregate stats over a set of [SleepEntry]s.
@immutable
class SleepStats {
  const SleepStats({
    required this.nights,
    required this.avgHours,
    required this.avgQuality,
  });

  final int nights;

  /// Average hours slept across all nights (0 if none).
  final double avgHours;

  /// Average quality across nights that recorded a quality (0 if none).
  final double avgQuality;
}

SleepStats sleepStats(Iterable<SleepEntry> entries) {
  final list = entries.toList();
  if (list.isEmpty) {
    return const SleepStats(nights: 0, avgHours: 0, avgQuality: 0);
  }
  final totalHours = list.fold<double>(0, (s, e) => s + e.hours);
  final rated = list.where((e) => e.quality > 0).toList();
  final totalQuality = rated.fold<int>(0, (s, e) => s + e.quality);
  return SleepStats(
    nights: list.length,
    avgHours: totalHours / list.length,
    avgQuality: rated.isEmpty ? 0 : totalQuality / rated.length,
  );
}
