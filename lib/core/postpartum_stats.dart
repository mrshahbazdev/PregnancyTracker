import 'package:flutter/foundation.dart';

import '../models/log_entry.dart';

/// Aggregate stats over a set of [PostpartumEntry]s.
@immutable
class PostpartumStats {
  const PostpartumStats({
    required this.days,
    required this.avgMood,
    required this.avgPain,
    required this.avgFeeds,
    required this.hasHeavyBleeding,
  });

  final int days;
  final double avgMood;
  final double avgPain;
  final double avgFeeds;

  /// True if any logged day reported heavy bleeding (prompts a caution note).
  final bool hasHeavyBleeding;
}

PostpartumStats postpartumStats(Iterable<PostpartumEntry> entries) {
  final list = entries.toList();
  if (list.isEmpty) {
    return const PostpartumStats(
      days: 0,
      avgMood: 0,
      avgPain: 0,
      avgFeeds: 0,
      hasHeavyBleeding: false,
    );
  }
  final rated = list.where((e) => e.mood > 0).toList();
  final totalMood = rated.fold<int>(0, (s, e) => s + e.mood);
  final totalPain = list.fold<int>(0, (s, e) => s + e.pain);
  final totalFeeds = list.fold<int>(0, (s, e) => s + e.feeds);
  return PostpartumStats(
    days: list.length,
    avgMood: rated.isEmpty ? 0 : totalMood / rated.length,
    avgPain: totalPain / list.length,
    avgFeeds: totalFeeds / list.length,
    hasHeavyBleeding: list.any((e) => e.bleeding == BleedingLevel.heavy),
  );
}
