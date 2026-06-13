import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import '../../core/baby_data.dart';
import '../../core/theme.dart';
import '../../models/pregnancy_profile.dart';
import '../../state/app_state.dart';
import '../appointments/appointments_screen.dart';
import '../insights/movement_insights.dart';
import '../insights/movement_insights_screen.dart';
import '../settings/settings_screen.dart';
import '../tips/weekly_tips_screen.dart';
import '../wellness/wellness_screen.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;

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
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await Future<void>.delayed(const Duration(milliseconds: 400));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(greeting,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800)),
            Text(profile.trimester(now),
                style: TextStyle(color: mutedColor)),
            const SizedBox(height: 20),
            _ProgressCard(profile: profile, now: now, week: week, day: day),
            const SizedBox(height: 16),
            _BabySizeCard(info: info),
            const SizedBox(height: 16),
            _DevelopmentCard(info: info),
            const SizedBox(height: 16),
            const _MovementInsightCard(),
            const SizedBox(height: 16),
            const _NextAppointmentCard(),
            const SizedBox(height: 16),
            _QuickActions(),
          ],
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.12),
            AppColors.secondary.withValues(alpha: isDark ? 0.20 : 0.08),
          ],
        ),
      ),
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
                      Text('weeks',
                          style: TextStyle(
                              fontSize: 12, color: mutedColor)),
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
                    style: TextStyle(color: mutedColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(profile.progress(now) * 100).round()}% complete',
                    style: TextStyle(color: mutedColor),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: isDark ? 0.30 : 0.25),
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
                  Text('Baby is about the size of',
                      style: TextStyle(color: mutedColor)),
                  const SizedBox(height: 2),
                  Text(info.sizeComparison,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    '${info.lengthCm.toStringAsFixed(1)} cm'
                    '${info.weightG > 0 ? ' · ${info.weightG} g' : ''}',
                    style: TextStyle(color: mutedColor),
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

class _MovementInsightCard extends ConsumerWidget {
  const _MovementInsightCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(movementInsightsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final (color, icon) = switch (insights.status) {
      MovementStatus.learning => (AppColors.secondary, Icons.auto_graph_rounded),
      MovementStatus.normal => (const Color(0xFF4CAF82), Icons.favorite_rounded),
      MovementStatus.watch => (
          const Color(0xFFD9822B),
          Icons.warning_amber_rounded
        ),
    };

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MovementInsightsScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.25 : 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Fetal movement',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(insights.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: mutedColor, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: mutedColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextAppointmentCard extends ConsumerWidget {
  const _NextAppointmentCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = ref.watch(nextAppointmentProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: isDark ? 0.25 : 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.event_outlined,
                    color: AppColors.secondary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Next appointment',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      next == null
                          ? 'Tap to add your prenatal visits'
                          : '${next.title} · '
                              '${DateFormat('MMM d, h:mm a').format(next.dateTime)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: mutedColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: mutedColor),
            ],
          ),
        ),
      ),
    );
  }
}

/// Streamlined quick actions: only the most relevant daily actions.
/// All other features are accessible via the "More" tab.
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 4, 0, 10),
          child: Text('Quick actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ),
        Row(
          children: [
            _QuickActionChip(
              icon: Icons.menu_book_rounded,
              label: 'Weekly Tips',
              color: AppColors.primary,
              builder: (_) => const WeeklyTipsScreen(),
            ),
            const SizedBox(width: 10),
            _QuickActionChip(
              icon: Icons.spa_rounded,
              label: 'Wellness',
              color: AppColors.secondary,
              builder: (_) => const WellnessScreen(),
            ),
            const SizedBox(width: 10),
            _QuickActionChip(
              icon: Icons.event_note_outlined,
              label: 'Appointments',
              color: AppColors.primaryDark,
              builder: (_) => const AppointmentsScreen(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Explore all features in the More tab',
            style: TextStyle(color: mutedColor, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.builder,
  });

  final IconData icon;
  final String label;
  final Color color;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: builder),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.25 : 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 6),
                Text(label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 11.5, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
