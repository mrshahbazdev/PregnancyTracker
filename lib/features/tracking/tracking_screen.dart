import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'contraction_timer_screen.dart';
import 'kick_counter_screen.dart';
import 'measurements_screen.dart';
import 'symptom_log_screen.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _TrackItem(
        icon: Icons.sports_soccer_rounded,
        color: AppColors.primary,
        title: 'Kick Counter',
        subtitle: 'Count baby movements & track patterns',
        builder: (_) => const KickCounterScreen(),
      ),
      _TrackItem(
        icon: Icons.timer_outlined,
        color: AppColors.secondary,
        title: 'Contraction Timer',
        subtitle: 'Time contractions & know when it\'s time',
        builder: (_) => const ContractionTimerScreen(),
      ),
      _TrackItem(
        icon: Icons.healing_outlined,
        color: AppColors.accent,
        title: 'Symptoms & Mood',
        subtitle: 'Log how you feel each day',
        builder: (_) => const SymptomLogScreen(),
      ),
      _TrackItem(
        icon: Icons.monitor_weight_outlined,
        color: AppColors.primaryDark,
        title: 'Weight & Blood Pressure',
        subtitle: 'Track measurements over time',
        builder: (_) => const MeasurementsScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Track')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, i) => items[i],
      ),
    );
  }
}

class _TrackItem extends StatelessWidget {
  const _TrackItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: builder)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.textMutedDark
                                : AppColors.textMuted,
                            fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textMutedDark
                      : AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
