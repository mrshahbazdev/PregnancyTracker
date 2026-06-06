import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/log_entry.dart';
import '../../state/app_state.dart';

/// Overall assessment of the baby's recent movement relative to the learned
/// baseline. This is informational only — never a diagnosis.
enum MovementStatus {
  /// Not enough history yet to establish a personal baseline.
  learning,

  /// Movement is consistent with the learned baseline.
  normal,

  /// Today's movement looks noticeably lower than usual — worth paying
  /// attention to and, if it persists, contacting a provider.
  watch,
}

/// A lightweight, on-device "AI" that learns the baby's typical kick pattern
/// from past counting sessions and flags meaningful deviations.
///
/// It is intentionally conservative: it only raises a [MovementStatus.watch]
/// once a personal baseline exists, and it always frames findings as guidance,
/// not medical advice.
class MovementInsights {
  const MovementInsights({
    required this.status,
    required this.totalSessions,
    required this.baselineSessions,
    required this.averageKicks,
    required this.averageMinutesToTen,
    required this.todayBestKicks,
    required this.lastSession,
    required this.message,
  });

  final MovementStatus status;
  final int totalSessions;

  /// Number of past sessions used to build the baseline (excludes today).
  final int baselineSessions;

  /// Average kicks per session across the baseline window.
  final double averageKicks;

  /// Average minutes to reach 10 movements, across baseline sessions that
  /// actually reached 10. Null if none did.
  final double? averageMinutesToTen;

  /// Best (highest) kick count logged today, or null if none logged today.
  final int? todayBestKicks;

  final KickSession? lastSession;
  final String message;

  /// How many sessions of history are needed before a baseline is trusted.
  static const int minBaseline = 3;

  /// Today's movement is flagged when the best session is below this fraction
  /// of the personal average.
  static const double lowFraction = 0.5;

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  factory MovementInsights.from(List<KickSession> sessions, DateTime now) {
    if (sessions.isEmpty) {
      return const MovementInsights(
        status: MovementStatus.learning,
        totalSessions: 0,
        baselineSessions: 0,
        averageKicks: 0,
        averageMinutesToTen: null,
        todayBestKicks: null,
        lastSession: null,
        message:
            'Log a few kick-counting sessions and I\'ll learn your baby\'s '
            'normal movement pattern.',
      );
    }

    final sorted = [...sessions]..sort((a, b) => b.start.compareTo(a.start));
    final lastSession = sorted.first;

    final today = sorted.where((s) => _sameDay(s.start, now)).toList();
    final baseline = sorted.where((s) => !_sameDay(s.start, now)).toList();
    // Use the most recent 14 baseline sessions.
    final window = baseline.take(14).toList();

    double avgKicks = 0;
    if (window.isNotEmpty) {
      avgKicks =
          window.map((s) => s.kicks).reduce((a, b) => a + b) / window.length;
    }

    final reachedTen =
        window.where((s) => s.kicks >= 10 && s.durationSeconds > 0).toList();
    double? avgMinutesToTen;
    if (reachedTen.isNotEmpty) {
      final mins =
          reachedTen.map((s) => s.durationSeconds / 60.0).reduce((a, b) => a + b);
      avgMinutesToTen = mins / reachedTen.length;
    }

    final int? todayBest = today.isEmpty
        ? null
        : today.map((s) => s.kicks).reduce((a, b) => a > b ? a : b);

    // Still learning the baseline.
    if (window.length < minBaseline) {
      final remaining = minBaseline - window.length;
      return MovementInsights(
        status: MovementStatus.learning,
        totalSessions: sessions.length,
        baselineSessions: window.length,
        averageKicks: avgKicks,
        averageMinutesToTen: avgMinutesToTen,
        todayBestKicks: todayBest,
        lastSession: lastSession,
        message:
            'Learning your baby\'s pattern — about $remaining more '
            '${remaining == 1 ? 'session' : 'sessions'} on different days and '
            'I can start spotting changes.',
      );
    }

    // Baseline exists: compare today.
    if (todayBest == null) {
      return MovementInsights(
        status: MovementStatus.normal,
        totalSessions: sessions.length,
        baselineSessions: window.length,
        averageKicks: avgKicks,
        averageMinutesToTen: avgMinutesToTen,
        todayBestKicks: null,
        lastSession: lastSession,
        message:
            'Your baby usually moves about ${avgKicks.round()} times per count. '
            'Try a session today — sit or lie down after a meal for the best '
            'sense of movement.',
      );
    }

    if (todayBest < avgKicks * lowFraction) {
      return MovementInsights(
        status: MovementStatus.watch,
        totalSessions: sessions.length,
        baselineSessions: window.length,
        averageKicks: avgKicks,
        averageMinutesToTen: avgMinutesToTen,
        todayBestKicks: todayBest,
        lastSession: lastSession,
        message:
            'Today\'s count ($todayBest) is lower than your usual '
            '~${avgKicks.round()}. Have a cold drink, lie on your side and '
            'count again. If movements still feel reduced, contact your '
            'provider right away — don\'t wait.',
      );
    }

    return MovementInsights(
      status: MovementStatus.normal,
      totalSessions: sessions.length,
      baselineSessions: window.length,
      averageKicks: avgKicks,
      averageMinutesToTen: avgMinutesToTen,
      todayBestKicks: todayBest,
      lastSession: lastSession,
      message:
          'Today\'s movement ($todayBest) is in line with your usual '
          '~${avgKicks.round()}. Keep up the daily counts.',
    );
  }
}

/// Live movement insights derived from the saved kick sessions.
final movementInsightsProvider = Provider<MovementInsights>((ref) {
  final sessions = ref.watch(kickSessionsProvider);
  return MovementInsights.from(sessions, DateTime.now());
});
