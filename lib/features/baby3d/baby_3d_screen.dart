import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/baby_data.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import 'baby_visual.dart';

/// Interactive 3D baby viewer. Users can drag to rotate the baby and scrub
/// through weeks to watch it grow and change shape.
///
/// The default renderer is a fully offline, always-available visual
/// ([BabyVisual]). In production this can be upgraded per-week to photorealistic
/// glTF models with AR (model_viewer_plus / Filament).
class Baby3DScreen extends ConsumerStatefulWidget {
  const Baby3DScreen({super.key});

  @override
  ConsumerState<Baby3DScreen> createState() => _Baby3DScreenState();
}

class _Baby3DScreenState extends ConsumerState<Baby3DScreen> {
  int? _overrideWeek;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    if (profile == null) return const SizedBox.shrink();
    final currentWeek = profile.currentWeek(DateTime.now());
    final week = _overrideWeek ?? currentWeek;
    final info = weekInfoFor(week);

    return Scaffold(
      appBar: AppBar(title: const Text('3D Baby')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.secondary.withValues(alpha: 0.10),
                  ],
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: BabyVisual(week: week),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stat(label: 'Week', value: '$week'),
                _Stat(
                    label: 'Length',
                    value: '${info.lengthCm.toStringAsFixed(1)} cm'),
                _Stat(
                    label: 'Weight',
                    value: info.weightG > 0 ? '${info.weightG} g' : '—'),
                _Stat(label: 'Size', value: info.sizeComparison),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('4'),
                Expanded(
                  child: Slider(
                    value: week.toDouble(),
                    min: 4,
                    max: 40,
                    divisions: 36,
                    label: 'Week $week',
                    activeColor: AppColors.primary,
                    onChanged: (v) =>
                        setState(() => _overrideWeek = v.round()),
                  ),
                ),
                const Text('40'),
              ],
            ),
          ),
          if (_overrideWeek != null && _overrideWeek != currentWeek)
            TextButton.icon(
              onPressed: () => setState(() => _overrideWeek = null),
              icon: const Icon(Icons.restore, size: 18),
              label: Text('Back to current (week $currentWeek)'),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              'Drag to rotate · slide the timeline to watch baby grow',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 15)),
        Text(label,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }
}
