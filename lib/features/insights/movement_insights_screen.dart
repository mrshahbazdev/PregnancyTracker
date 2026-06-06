import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';
import '../tracking/kick_counter_screen.dart';
import 'movement_insights.dart';

/// Visual treatment for each [MovementStatus].
class _StatusStyle {
  const _StatusStyle(this.color, this.icon, this.label);
  final Color color;
  final IconData icon;
  final String label;

  static _StatusStyle of(MovementStatus s) => switch (s) {
        MovementStatus.learning =>
          const _StatusStyle(AppColors.secondary, Icons.auto_graph_rounded,
              'Learning the pattern'),
        MovementStatus.normal => const _StatusStyle(
            Color(0xFF4CAF82), Icons.check_circle_rounded, 'Looks normal'),
        MovementStatus.watch => const _StatusStyle(
            Color(0xFFD9822B), Icons.warning_amber_rounded, 'Worth watching'),
      };
}

class MovementInsightsScreen extends ConsumerWidget {
  const MovementInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(movementInsightsProvider);
    final sessions = ref.watch(kickSessionsProvider);
    final style = _StatusStyle.of(insights.status);

    return Scaffold(
      appBar: AppBar(title: const Text('Movement Insights')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _StatusBanner(style: style, message: insights.message),
          const SizedBox(height: 16),
          _BaselineCard(insights: insights),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const KickCounterScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Start a kick count'),
          ),
          const SizedBox(height: 24),
          const Text('Recent sessions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (sessions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No sessions logged yet.',
                  style: TextStyle(color: AppColors.textMuted)),
            )
          else
            ...sessions.take(10).map((s) => _SessionTile(session: s)),
          const SizedBox(height: 20),
          const _Disclaimer(),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.style, required this.message});
  final _StatusStyle style;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(style.icon, color: style.color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(style.label,
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: style.color)),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BaselineCard extends StatelessWidget {
  const _BaselineCard({required this.insights});
  final MovementInsights insights;

  @override
  Widget build(BuildContext context) {
    final avgKicks =
        insights.baselineSessions == 0 ? '—' : insights.averageKicks.round().toString();
    final avgTime = insights.averageMinutesToTen == null
        ? '—'
        : '${insights.averageMinutesToTen!.round()} min';
    final today = insights.todayBestKicks?.toString() ?? '—';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            _Stat(label: 'Usual kicks', value: avgKicks),
            _divider(),
            _Stat(label: 'Time to 10', value: avgTime),
            _divider(),
            _Stat(label: 'Today', value: today),
            _divider(),
            _Stat(
                label: 'Sessions',
                value: insights.totalSessions.toString()),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        color: AppColors.textMuted.withValues(alpha: 0.18),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final KickSession session;

  @override
  Widget build(BuildContext context) {
    final mins = (session.durationSeconds / 60).floor();
    final secs = session.durationSeconds % 60;
    final duration = '${mins}m ${secs}s';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text('${session.kicks}',
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
        ),
        title: Text('${session.kicks} movements'),
        subtitle: Text(
            '${DateFormat('MMM d, h:mm a').format(session.start)} · $duration'),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Movement insights are informational and learned from your own logs — '
      'not a medical diagnosis. Every baby is different. If you ever feel '
      'movements have reduced or stopped, contact your provider immediately.',
      style: TextStyle(
          fontSize: 12,
          height: 1.5,
          color: AppColors.textMuted.withValues(alpha: 0.9)),
    );
  }
}
