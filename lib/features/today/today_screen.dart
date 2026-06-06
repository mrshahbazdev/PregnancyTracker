import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/baby_data.dart';
import '../../core/theme.dart';
import '../../models/pregnancy_profile.dart';
import '../../state/app_state.dart';
import '../memory/time_capsule_screen.dart';
import '../settings/settings_screen.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    if (profile == null) return const SizedBox.shrink();
    final now = DateTime.now();
    final week = profile.currentWeek(now);
    final day = profile.currentDayOfWeek(now);
    final info = weekInfoFor(week);
    final greeting = profile.name.isEmpty ? 'Hello' : 'Hello, ${profile.name}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(greeting,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800)),
          Text(profile.trimester(now),
              style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 20),
          _ProgressCard(profile: profile, now: now, week: week, day: day),
          const SizedBox(height: 16),
          _BabySizeCard(info: info),
          const SizedBox(height: 16),
          _DevelopmentCard(info: info),
          const SizedBox(height: 16),
          _QuickActions(),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard(
      {required this.profile,
      required this.now,
      required this.week,
      required this.day});

  final PregnancyProfile profile;
  final DateTime now;
  final int week;
  final int day;

  @override
  Widget build(BuildContext context) {
    final remaining = profile.daysRemaining(now);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: CircularProgressIndicator(
                      value: profile.progress(now),
                      strokeWidth: 9,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$week',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryDark)),
                      const Text('weeks',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Week $week, day $day',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(
                    remaining == 0
                        ? 'Your due date is here!'
                        : '$remaining days to go',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(profile.progress(now) * 100).round()}% complete',
                    style: const TextStyle(color: AppColors.textMuted),
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

class _BabySizeCard extends StatelessWidget {
  const _BabySizeCard({required this.info});
  final WeekInfo info;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.eco_rounded,
                  color: AppColors.primaryDark, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Baby is about the size of',
                      style: TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(info.sizeComparison,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    '${info.lengthCm.toStringAsFixed(1)} cm'
                    '${info.weightG > 0 ? ' · ${info.weightG} g' : ''}',
                    style: const TextStyle(color: AppColors.textMuted),
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

class _DevelopmentCard extends StatelessWidget {
  const _DevelopmentCard({required this.info});
  final WeekInfo info;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome,
                    color: AppColors.secondary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(info.headline,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(info.detail,
                style: const TextStyle(height: 1.5, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.book_outlined,
                  color: AppColors.primary),
              title: const Text('Time Capsule'),
              subtitle: const Text('Save a memory for your baby'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const TimeCapsuleScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
