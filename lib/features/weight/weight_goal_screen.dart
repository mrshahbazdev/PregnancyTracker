import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/health_trends.dart';
import '../../core/theme.dart';
import '../../core/weight_goal.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';

class WeightGoalScreen extends ConsumerWidget {
  const WeightGoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(weightGoalProvider);
    final profile = ref.watch(profileProvider);
    final measurements = ref.watch(measurementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight-Gain Goal'),
        actions: [
          if (config != null)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => _openSetup(context, ref, existing: config),
            ),
        ],
      ),
      body: config == null
          ? _SetupPrompt(onStart: () => _openSetup(context, ref))
          : _GoalView(
              config: config,
              week: profile?.currentWeek(DateTime.now()) ?? 0,
              latest: latestWeight(measurements),
            ),
    );
  }

  Future<void> _openSetup(
    BuildContext context,
    WidgetRef ref, {
    WeightGoalConfig? existing,
  }) async {
    final result = await showModalBottomSheet<WeightGoalConfig>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SetupSheet(existing: existing),
    );
    if (result != null) {
      await ref.read(weightGoalProvider.notifier).set(result);
    }
  }
}

class _SetupPrompt extends StatelessWidget {
  const _SetupPrompt({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monitor_weight_rounded,
                size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('Set your weight-gain goal',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 8),
            const Text(
              'Enter your pre-pregnancy weight and height. We\'ll suggest a '
              'healthy gain range based on IOM guidelines and track your '
              'progress from your logged weights.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Get started'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalView extends StatelessWidget {
  const _GoalView({
    required this.config,
    required this.week,
    required this.latest,
  });

  final WeightGoalConfig config;
  final int week;
  final Measurement? latest;

  @override
  Widget build(BuildContext context) {
    final bmiValue = bmi(config.prePregnancyKg, config.heightCm);
    final cat = bmiCategory(bmiValue);
    final total = recommendedTotalGain(cat);
    final byWeek = recommendedGainByWeek(cat, week);

    final currentKg = latest?.weightKg;
    final gain = currentKg == null ? null : currentKg - config.prePregnancyKg;
    final status = gain == null ? null : gainStatus(byWeek, gain);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        _BmiCard(bmiValue: bmiValue, cat: cat),
        const SizedBox(height: 16),
        _RangeCard(
          title: 'Recommended total gain',
          subtitle: 'Across your whole pregnancy',
          range: total,
        ),
        const SizedBox(height: 16),
        _ProgressCard(
          week: week,
          byWeek: byWeek,
          gain: gain,
          status: status,
        ),
        const SizedBox(height: 16),
        _BaselineCard(config: config, currentKg: currentKg),
        const SizedBox(height: 20),
        const Text(
          'Guidance is based on IOM (2009) singleton recommendations and is '
          'educational only — your provider may advise a different target.',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _BmiCard extends StatelessWidget {
  const _BmiCard({required this.bmiValue, required this.cat});
  final double bmiValue;
  final BmiCategory cat;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondary.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pre-pregnancy BMI',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
                Text(bmiValue.toStringAsFixed(1),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 26)),
              ],
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(cat.label,
                  style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeCard extends StatelessWidget {
  const _RangeCard({
    required this.title,
    required this.subtitle,
    required this.range,
  });
  final String title;
  final String subtitle;
  final GainRange range;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 10),
            Text(
              '${range.lowKg.toStringAsFixed(1)} – '
              '${range.highKg.toStringAsFixed(1)} kg',
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.week,
    required this.byWeek,
    required this.gain,
    required this.status,
  });

  final int week;
  final GainRange byWeek;
  final double? gain;
  final GainStatus? status;

  Color get _statusColor => switch (status) {
        GainStatus.onTrack => Colors.green.shade600,
        GainStatus.below => AppColors.secondary,
        GainStatus.above => AppColors.primaryDark,
        null => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress at week $week',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 12),
            if (gain == null)
              const Text(
                'Log a weight in Health Trends to see your current gain '
                'against the suggested range.',
                style: TextStyle(color: AppColors.textMuted),
              )
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${gain! >= 0 ? '+' : ''}${gain!.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 26),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('so far',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status!.label,
                    style: TextStyle(
                        color: _statusColor, fontWeight: FontWeight.w700)),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Suggested by now: ${byWeek.lowKg.toStringAsFixed(1)} – '
              '${byWeek.highKg.toStringAsFixed(1)} kg',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _BaselineCard extends StatelessWidget {
  const _BaselineCard({required this.config, required this.currentKg});
  final WeightGoalConfig config;
  final double? currentKg;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _row('Pre-pregnancy weight',
                '${config.prePregnancyKg.toStringAsFixed(1)} kg'),
            const Divider(height: 20),
            _row('Height', '${config.heightCm.toStringAsFixed(0)} cm'),
            const Divider(height: 20),
            _row('Latest logged weight',
                currentKg == null ? '—' : '${currentKg!.toStringAsFixed(1)} kg'),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      );
}

class _SetupSheet extends StatefulWidget {
  const _SetupSheet({this.existing});
  final WeightGoalConfig? existing;

  @override
  State<_SetupSheet> createState() => _SetupSheetState();
}

class _SetupSheetState extends State<_SetupSheet> {
  late final TextEditingController _weight = TextEditingController(
      text: widget.existing?.prePregnancyKg.toStringAsFixed(1) ?? '');
  late final TextEditingController _height = TextEditingController(
      text: widget.existing?.heightCm.toStringAsFixed(0) ?? '');
  String? _error;

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  void _save() {
    final w = double.tryParse(_weight.text.trim());
    final h = double.tryParse(_height.text.trim());
    if (w == null || w < 30 || w > 250) {
      setState(() => _error = 'Enter a valid weight in kg (30–250).');
      return;
    }
    if (h == null || h < 120 || h > 220) {
      setState(() => _error = 'Enter a valid height in cm (120–220).');
      return;
    }
    Navigator.of(context).pop(
      WeightGoalConfig(prePregnancyKg: w, heightCm: h),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Your baseline',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 16),
          TextField(
            controller: _weight,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Pre-pregnancy weight (kg)',
              hintText: 'e.g. 60',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _height,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Height (cm)',
              hintText: 'e.g. 165',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!,
                style: TextStyle(color: AppColors.primaryDark, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
