import 'package:flutter/foundation.dart';

import '../models/log_entry.dart';

/// Summary of a recent run of contractions plus the 5-1-1 guidance flag.
///
/// 5-1-1 (educational, not medical advice): contractions about **5 minutes**
/// apart, each lasting about **1 minute**, sustained for about **1 hour** is a
/// common "time to call your provider / head in" guideline.
@immutable
class ContractionStats {
  const ContractionStats({
    required this.recentCount,
    required this.avgDuration,
    required this.avgInterval,
    required this.spanMinutes,
    required this.meets511,
  });

  /// Contractions counted within the recent (1-hour) window.
  final int recentCount;

  /// Average contraction length in the window.
  final Duration avgDuration;

  /// Average start-to-start interval in the window (zero if <2 contractions).
  final Duration avgInterval;

  /// Minutes between the first and last contraction in the window.
  final int spanMinutes;

  final bool meets511;
}

/// 5-1-1 thresholds (with small tolerances so real-world taps still qualify).
const Duration _kMaxInterval = Duration(minutes: 5);
const Duration _kMinDuration = Duration(seconds: 55);
const int _kMinSpanMinutes = 45;
const int _kMinCount = 4;
const Duration _kWindow = Duration(hours: 1);

/// Analyse [all] contractions, looking at the last hour relative to the most
/// recent one (or [now] when provided). Pure + deterministic for tests.
ContractionStats analyzeContractions(List<Contraction> all, {DateTime? now}) {
  if (all.isEmpty) {
    return const ContractionStats(
      recentCount: 0,
      avgDuration: Duration.zero,
      avgInterval: Duration.zero,
      spanMinutes: 0,
      meets511: false,
    );
  }

  final sorted = [...all]..sort((a, b) => a.start.compareTo(b.start));
  final anchor = now ?? sorted.last.start;
  final cutoff = anchor.subtract(_kWindow);
  final recent =
      sorted.where((c) => !c.start.isBefore(cutoff)).toList();

  if (recent.isEmpty) {
    return const ContractionStats(
      recentCount: 0,
      avgDuration: Duration.zero,
      avgInterval: Duration.zero,
      spanMinutes: 0,
      meets511: false,
    );
  }

  final avgDurSecs = recent
          .map((c) => c.duration.inSeconds)
          .reduce((a, b) => a + b) /
      recent.length;

  var avgIntervalSecs = 0.0;
  if (recent.length >= 2) {
    final intervals = <int>[];
    for (var i = 1; i < recent.length; i++) {
      intervals.add(recent[i].start.difference(recent[i - 1].start).inSeconds);
    }
    avgIntervalSecs =
        intervals.reduce((a, b) => a + b) / intervals.length;
  }

  final span = recent.last.start.difference(recent.first.start).inMinutes;
  final avgDuration = Duration(seconds: avgDurSecs.round());
  final avgInterval = Duration(seconds: avgIntervalSecs.round());

  final meets = recent.length >= _kMinCount &&
      avgInterval <= _kMaxInterval &&
      avgInterval > Duration.zero &&
      avgDuration >= _kMinDuration &&
      span >= _kMinSpanMinutes;

  return ContractionStats(
    recentCount: recent.length,
    avgDuration: avgDuration,
    avgInterval: avgInterval,
    spanMinutes: span,
    meets511: meets,
  );
}
