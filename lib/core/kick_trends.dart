import 'package:flutter/foundation.dart';

import '../models/log_entry.dart';

/// Aggregate stats across saved kick-counting sessions, for the history screen.
/// All values are derived; pure + deterministic for tests.
@immutable
class KickTrends {
  const KickTrends({
    required this.totalSessions,
    required this.averageKicks,
    required this.averageMinutesToTen,
    required this.bestKicks,
    required this.lastSession,
  });

  final int totalSessions;

  /// Average kicks per session (0 when there are no sessions).
  final double averageKicks;

  /// Average minutes to reach 10 kicks, across sessions that actually reached
  /// 10 with a positive duration. Null if none qualify.
  final double? averageMinutesToTen;

  /// Highest kick count in any single session (0 when none).
  final int bestKicks;

  /// Most recent session, or null when there are none.
  final KickSession? lastSession;

  factory KickTrends.from(List<KickSession> sessions) {
    if (sessions.isEmpty) {
      return const KickTrends(
        totalSessions: 0,
        averageKicks: 0,
        averageMinutesToTen: null,
        bestKicks: 0,
        lastSession: null,
      );
    }
    final sorted = [...sessions]..sort((a, b) => b.start.compareTo(a.start));
    final avg =
        sorted.map((s) => s.kicks).reduce((a, b) => a + b) / sorted.length;
    final best = sorted.map((s) => s.kicks).reduce((a, b) => a > b ? a : b);

    final reachedTen =
        sorted.where((s) => s.kicks >= 10 && s.durationSeconds > 0).toList();
    double? avgMinsToTen;
    if (reachedTen.isNotEmpty) {
      final mins = reachedTen
          .map((s) => s.durationSeconds / 60.0)
          .reduce((a, b) => a + b);
      avgMinsToTen = mins / reachedTen.length;
    }

    return KickTrends(
      totalSessions: sorted.length,
      averageKicks: avg,
      averageMinutesToTen: avgMinsToTen,
      bestKicks: best,
      lastSession: sorted.first,
    );
  }
}

/// Sessions sorted oldest-first — convenient for plotting over time.
List<KickSession> kickSeries(List<KickSession> sessions) {
  final list = [...sessions]..sort((a, b) => a.start.compareTo(b.start));
  return list;
}

/// Minutes to reach 10 kicks for a session, or null if it never reached 10 or
/// has no recorded duration.
double? minutesToTen(KickSession s) {
  if (s.kicks < 10 || s.durationSeconds <= 0) return null;
  return s.durationSeconds / 60.0;
}
