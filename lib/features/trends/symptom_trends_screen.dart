import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/symptom_trends.dart';
import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';
import '../tracking/symptom_log_screen.dart';

const _moodEmojis = ['😢', '😕', '😐', '🙂', '😄'];

class SymptomTrendsScreen extends ConsumerWidget {
  const SymptomTrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(symptomLogsProvider);
    final top = topSymptoms(logs, n: 6);
    final moods = moodLogs(logs);
    final avg = averageMood(logs);
    final days = loggedDays(logs);

    return Scaffold(
      appBar: AppBar(title: const Text('Symptom & Mood Trends')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SymptomLogScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Log entry'),
      ),
      body: logs.isEmpty
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
              children: [
                Row(
                  children: [
                    Expanded(child: _AvgMoodCard(avg: avg)),
                    const SizedBox(width: 12),
                    Expanded(child: _LoggedDaysCard(days: days, entries: logs.length)),
                  ],
                ),
                if (moods.length >= 2) ...[
                  const SizedBox(height: 20),
                  const _SectionLabel('Mood over time'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
                      child: SizedBox(
                          height: 200, child: _MoodChart(logs: moods)),
                    ),
                  ),
                ],
                if (top.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _SectionLabel('Most common symptoms'),
                  const SizedBox(height: 12),
                  _SymptomBars(items: top),
                ],
                const SizedBox(height: 16),
                const _Disclaimer(),
              ],
            ),
    );
  }
}

class _AvgMoodCard extends StatelessWidget {
  const _AvgMoodCard({required this.avg});
  final double? avg;

  @override
  Widget build(BuildContext context) {
    final emoji = avg == null
        ? '📝'
        : _moodEmojis[(avg!.round().clamp(1, 5)) - 1];
    return _StatCard(
      icon: Icons.mood_rounded,
      color: AppColors.primary,
      title: 'Average mood',
      value: avg == null ? '—' : '$emoji ${avg!.toStringAsFixed(1)}/5',
    );
  }
}

class _LoggedDaysCard extends StatelessWidget {
  const _LoggedDaysCard({required this.days, required this.entries});
  final int days;
  final int entries;

  @override
  Widget build(BuildContext context) {
    return _StatCard(
      icon: Icons.event_note_rounded,
      color: AppColors.secondary,
      title: 'Days logged',
      value: '$days',
      subtitle: '$entries ${entries == 1 ? 'entry' : 'entries'}',
    );
  }
}

class _MoodChart extends StatelessWidget {
  const _MoodChart({required this.logs});
  final List<SymptomLog> logs;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < logs.length; i++)
        FlSpot(i.toDouble(), logs[i].mood.toDouble()),
    ];
    return LineChart(
      LineChartData(
        minY: 1,
        maxY: 5,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.black12, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 30,
              getTitlesWidget: (v, _) {
                final i = v.round();
                if (i < 1 || i > 5) return const SizedBox.shrink();
                return Text(_moodEmojis[i - 1],
                    style: const TextStyle(fontSize: 14));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (logs.length / 4).ceilToDouble().clamp(1, 999),
              getTitlesWidget: (v, _) {
                final i = v.round();
                if (i < 0 || i >= logs.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(DateFormat.Md().format(logs[i].date),
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

class _SymptomBars extends StatelessWidget {
  const _SymptomBars({required this.items});
  final List<SymptomCount> items;

  @override
  Widget build(BuildContext context) {
    final max = items.first.count;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
        child: Column(
          children: [
            for (final s in items) ...[
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(s.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: max == 0 ? 0 : s.count / max,
                        minHeight: 12,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.10),
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 28,
                    child: Text('${s.count}',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ],
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
      'Trends are based on what you log and are for your awareness only — '
      'not medical advice. Share any concerns with your provider.',
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
            const Icon(Icons.insights_rounded,
                size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('No logs yet',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Log your symptoms and mood to see trends here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SymptomLogScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Log entry'),
            ),
          ],
        ),
      ),
    );
  }
}
