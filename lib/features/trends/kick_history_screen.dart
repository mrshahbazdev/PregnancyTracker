import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/kick_trends.dart';
import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';
import '../insights/movement_insights_screen.dart';
import '../tracking/kick_counter_screen.dart';

class KickHistoryScreen extends ConsumerWidget {
  const KickHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(kickSessionsProvider);
    final trends = KickTrends.from(sessions);
    final series = kickSeries(sessions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kick History & Trends'),
        actions: [
          IconButton(
            tooltip: 'Movement insights',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const MovementInsightsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const KickCounterScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Count kicks'),
      ),
      body: sessions.isEmpty
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.sports_soccer_rounded,
                        color: AppColors.primary,
                        title: 'Sessions',
                        value: '${trends.totalSessions}',
                        subtitle: 'avg ${trends.averageKicks.toStringAsFixed(1)} kicks',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.timer_outlined,
                        color: AppColors.secondary,
                        title: 'Avg to 10 kicks',
                        value: trends.averageMinutesToTen == null
                            ? '—'
                            : '${trends.averageMinutesToTen!.toStringAsFixed(0)} min',
                        subtitle: 'best ${trends.bestKicks} kicks',
                      ),
                    ),
                  ],
                ),
                if (series.length >= 2) ...[
                  const SizedBox(height: 20),
                  const _SectionLabel('Kicks per session'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
                      child: SizedBox(
                          height: 200, child: _KicksChart(series: series)),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const _SectionLabel('History'),
                const SizedBox(height: 12),
                ...sessions.map((s) => _SessionCard(
                      session: s,
                      onDelete: () => ref
                          .read(kickSessionsProvider.notifier)
                          .remove(s.id),
                    )),
                const SizedBox(height: 16),
                const _Disclaimer(),
              ],
            ),
    );
  }
}

class _KicksChart extends StatelessWidget {
  const _KicksChart({required this.series});
  final List<KickSession> series;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < series.length; i++)
        FlSpot(i.toDouble(), series[i].kicks.toDouble()),
    ];
    final maxKicks =
        series.map((s) => s.kicks).reduce((a, b) => a > b ? a : b).toDouble();
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: (maxKicks + 2).clamp(5, double.infinity),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.black12, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (series.length / 4).ceilToDouble().clamp(1, 999),
              getTitlesWidget: (v, _) {
                final i = v.round();
                if (i < 0 || i >= series.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(DateFormat.Md().format(series[i].start),
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textMuted)),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onDelete});
  final KickSession session;
  final VoidCallback onDelete;

  String _fmt(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final toTen = minutesToTen(session);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text('${session.kicks}',
              style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold)),
        ),
        title: Text('${session.kicks} kicks in ${_fmt(session.durationSeconds)}'),
        subtitle: Text(
          '${DateFormat.MMMd().add_jm().format(session.start)}'
          '${toTen != null ? ' · 10 kicks in ~${toTen.toStringAsFixed(0)} min' : ''}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w900)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16));
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Kick trends are for your awareness only. If you notice a clear drop in '
      'your baby\'s usual movement, contact your provider right away.',
      style: TextStyle(
          fontSize: 12, color: AppColors.textMuted, height: 1.4),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_soccer_rounded,
                size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('No kick sessions yet',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Count your baby\'s kicks to build a history and see trends here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const KickCounterScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Count kicks'),
            ),
          ],
        ),
      ),
    );
  }
}
