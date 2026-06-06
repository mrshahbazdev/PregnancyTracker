import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';

class MeasurementsScreen extends ConsumerStatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  ConsumerState<MeasurementsScreen> createState() =>
      _MeasurementsScreenState();
}

class _MeasurementsScreenState extends ConsumerState<MeasurementsScreen> {
  final _weight = TextEditingController();
  final _systolic = TextEditingController();
  final _diastolic = TextEditingController();

  @override
  void dispose() {
    _weight.dispose();
    _systolic.dispose();
    _diastolic.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final w = double.tryParse(_weight.text);
    final sys = int.tryParse(_systolic.text);
    final dia = int.tryParse(_diastolic.text);
    if (w == null && sys == null && dia == null) return;
    final m = Measurement(
      id: const Uuid().v4(),
      date: DateTime.now(),
      weightKg: w,
      systolic: sys,
      diastolic: dia,
    );
    await ref.read(measurementsProvider.notifier).add(m);
    if (!mounted) return;
    _weight.clear();
    _systolic.clear();
    _diastolic.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Measurement saved')),
    );
  }

  /// High BP warning (educational, not a diagnosis).
  bool _highBp(Measurement m) =>
      (m.systolic != null && m.systolic! >= 140) ||
      (m.diastolic != null && m.diastolic! >= 90);

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(measurementsProvider);
    final weights = items.where((m) => m.weightKg != null).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Weight & Blood Pressure')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: _field(_weight, 'Weight (kg)', TextInputType.number),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _field(
                      _systolic, 'Systolic', TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(
                  child: _field(
                      _diastolic, 'Diastolic', TextInputType.number)),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
              onPressed: _save, child: const Text('Add measurement')),
          const SizedBox(height: 28),
          if (weights.length >= 2) ...[
            const Text('Weight trend',
                style:
                    TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: _WeightChart(weights: weights)),
            const SizedBox(height: 24),
          ],
          if (items.isNotEmpty) ...[
            const Text('History',
                style:
                    TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 12),
            ...items.reversed.map((m) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Icon(
                      _highBp(m)
                          ? Icons.warning_amber_rounded
                          : Icons.favorite_rounded,
                      color: _highBp(m) ? Colors.red : AppColors.primary,
                    ),
                    title: Text([
                      if (m.weightKg != null)
                        '${m.weightKg!.toStringAsFixed(1)} kg',
                      if (m.systolic != null && m.diastolic != null)
                        '${m.systolic}/${m.diastolic} mmHg',
                    ].join('  ·  ')),
                    subtitle: Text(DateFormat.yMMMd().format(m.date)),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _field(
      TextEditingController c, String label, TextInputType type) {
    return TextField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
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
          topTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
