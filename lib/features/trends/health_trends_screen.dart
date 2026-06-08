import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/health_trends.dart';
import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';
import '../tracking/measurements_screen.dart';

class HealthTrendsScreen extends ConsumerWidget {
  const HealthTrendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(measurementsProvider);
    final weights = weightSeries(items);
    final bps = bpSeries(items);
    final lw = latestWeight(items);
    final lb = latestBp(items);
    final change = weightChangeKg(items);

    return Scaffold(
      appBar: AppBar(title: const Text('Health Trends')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MeasurementsScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add reading'),
      ),
      body: items.isEmpty
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
              children: [
                Row(
                  children: [
                    Expanded(child: _WeightSummaryCard(latest: lw, change: change)),
                    const SizedBox(width: 12),
                    Expanded(child: _BpSummaryCard(latest: lb)),
                  ],
                ),
                if (weights.length >= 2) ...[
                  const SizedBox(height: 20),
                  const _SectionLabel('Weight trend (kg)'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
                      child: SizedBox(
                          height: 200, child: _WeightChart(weights: weights)),
                    ),
                  ),
                ],
                if (bps.length >= 2) ...[
                  const SizedBox(height: 20),
                  const _SectionLabel('Blood pressure trend (mmHg)'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
                      child:
                          SizedBox(height: 200, child: _BpChart(readings: bps)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _BpLegend(),
                ],
                if (lb != null) ...[
                  const SizedBox(height: 20),
                  const _SectionLabel('Guidance'),
                  const SizedBox(height: 12),
                  _BpGuidanceCard(latest: lb),
                ],
                const SizedBox(height: 16),
                const _Disclaimer(),
              ],
            ),
    );
  }
}

Color _bpColor(BpSeverity s) {
  switch (s) {
    case BpSeverity.normal:
      return const Color(0xFF4CAF82);
    case BpSeverity.elevated:
      return const Color(0xFFE0A030);
    case BpSeverity.high:
      return const Color(0xFFE2603F);
    case BpSeverity.severe:
      return const Color(0xFFD23A3A);
  }
}

class _WeightSummaryCard extends StatelessWidget {
  const _WeightSummaryCard({required this.latest, required this.change});

  final Measurement? latest;
  final double? change;

  @override
  Widget build(BuildContext context) {
    final value =
        latest?.weightKg == null ? '—' : '${latest!.weightKg!.toStringAsFixed(1)} kg';
    String? sub;
    if (change != null) {
      final sign = change! >= 0 ? '+' : '';
      sub = '$sign${change!.toStringAsFixed(1)} kg since start';
    }
    return _StatCard(
      icon: Icons.monitor_weight_outlined,
      color: AppColors.primary,
      title: 'Latest weight',
      value: value,
      subtitle: sub,
    );
  }
}

class _BpSummaryCard extends StatelessWidget {
  const _BpSummaryCard({required this.latest});

  final Measurement? latest;

  @override
  Widget build(BuildContext context) {
    if (latest == null) {
      return const _StatCard(
        icon: Icons.favorite_outline_rounded,
        color: AppColors.secondary,
        title: 'Latest BP',
        value: '—',
      );
    }
    final cls = classifyBp(latest!.systolic!, latest!.diastolic!);
    return _StatCard(
      icon: Icons.favorite_rounded,
      color: _bpColor(cls.severity),
      title: 'Latest BP',
      value: '${latest!.systolic}/${latest!.diastolic}',
      badge: cls.label,
      badgeColor: _bpColor(cls.severity),
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
    this.badge,
    this.badgeColor,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String? subtitle;
  final String? badge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900)),
            if (badge != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (badgeColor ?? color).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(badge!,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: badgeColor ?? color)),
              ),
            ],
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
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
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800));
  }
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.weights});
  final List<Measurement> weights;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < weights.length; i++)
        FlSpot(i.toDouble(), weights[i].weightKg!),
    ];
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 36),
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

class _BpChart extends StatelessWidget {
  const _BpChart({required this.readings});
  final List<Measurement> readings;

  @override
  Widget build(BuildContext context) {
    final sys = <FlSpot>[
      for (var i = 0; i < readings.length; i++)
        FlSpot(i.toDouble(), readings[i].systolic!.toDouble()),
    ];
    final dia = <FlSpot>[
      for (var i = 0; i < readings.length; i++)
        FlSpot(i.toDouble(), readings[i].diastolic!.toDouble()),
    ];
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 36),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: sys,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
          LineChartBarData(
            spots: dia,
            isCurved: true,
            color: AppColors.secondary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}

class _BpLegend extends StatelessWidget {
  const _BpLegend();

  @override
  Widget build(BuildContext context) {
    Widget dot(Color c, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 12,
                height: 12,
                decoration:
                    BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 6),
            Text(label,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        );
    return Row(
      children: [
        dot(AppColors.primary, 'Systolic'),
        const SizedBox(width: 18),
        dot(AppColors.secondary, 'Diastolic'),
      ],
    );
  }
}

class _BpGuidanceCard extends StatelessWidget {
  const _BpGuidanceCard({required this.latest});
  final Measurement latest;

  @override
  Widget build(BuildContext context) {
    final cls = classifyBp(latest.systolic!, latest.diastolic!);
    final color = _bpColor(cls.severity);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              cls.severity == BpSeverity.normal
                  ? Icons.check_circle_rounded
                  : Icons.info_rounded,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Blood pressure: ${cls.label}',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, color: color)),
                  const SizedBox(height: 4),
                  Text(cls.advice,
                      style: const TextStyle(
                          height: 1.5, color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  Text(
                    'Last reading ${DateFormat.yMMMd().format(latest.date)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline_rounded,
            size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'These ranges are educational only and not a diagnosis. Always '
            'follow your healthcare provider for your personal care.',
            style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textMuted.withValues(alpha: 0.9)),
          ),
        ),
      ],
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
            const Icon(Icons.show_chart_rounded,
                size: 56, color: AppColors.textMuted),
            const SizedBox(height: 12),
            const Text(
              'No readings yet. Add your weight and blood pressure to see '
              'trends and guidance here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MeasurementsScreen()),
              ),
              child: const Text('Add a reading'),
            ),
          ],
        ),
      ),
    );
  }
}
