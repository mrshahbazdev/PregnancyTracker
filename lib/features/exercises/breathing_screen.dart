import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/breathing.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import 'breathing_player_screen.dart';

class BreathingScreen extends ConsumerWidget {
  const BreathingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(breathingCountsProvider);
    final total = counts.values.fold(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text('Breathing & Relaxation')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Card(
            color: AppColors.primary.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Icon(Icons.self_improvement_rounded,
                      color: AppColors.primary, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$total ${total == 1 ? 'session' : 'sessions'} completed',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 2),
                        const Text(
                            'A few minutes of slow breathing can ease stress and help with labor.',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final p in kBreathingPatterns)
            _PatternCard(
              pattern: p,
              done: counts[p.id] ?? 0,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => BreathingPlayerScreen(pattern: p)),
              ),
            ),
        ],
      ),
    );
  }
}

class _PatternCard extends StatelessWidget {
  const _PatternCard({
    required this.pattern,
    required this.done,
    required this.onTap,
  });

  final BreathingPattern pattern;
  final int done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mins = (pattern.totalSeconds / 60).ceil();
    final isKegel = pattern.id == 'kegel';
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isKegel
                      ? Icons.fitness_center_rounded
                      : Icons.air_rounded,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pattern.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(pattern.description,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    Text(
                        '~$mins min · ${pattern.cycles} ${isKegel ? 'reps' : 'cycles'}'
                        '${done > 0 ? ' · done $done×' : ''}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_fill_rounded,
                  color: AppColors.primary, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
