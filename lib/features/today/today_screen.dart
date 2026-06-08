import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import '../../core/baby_data.dart';
import '../../core/theme.dart';
import '../../models/pregnancy_profile.dart';
import '../../state/app_state.dart';
import '../appointments/appointments_screen.dart';
import '../checklists/prep_hub_screen.dart';
import '../insights/movement_insights.dart';
import '../insights/movement_insights_screen.dart';
import '../exercises/breathing_screen.dart';
import '../safety/safety_checker_screen.dart';
import '../memory/time_capsule_screen.dart';
import '../names/baby_names_screen.dart';
import '../settings/settings_screen.dart';
import '../tips/weekly_tips_screen.dart';
import '../trends/health_trends_screen.dart';
import '../trends/kick_history_screen.dart';
import '../trends/symptom_trends_screen.dart';
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
          const _MovementInsightCard(),
          const SizedBox(height: 16),
          const _NextAppointmentCard(),
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

class _MovementInsightCard extends ConsumerWidget {
  const _MovementInsightCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(movementInsightsProvider);
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
                  color: color.withValues(alpha: 0.16),
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
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
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
                  color: AppColors.secondary.withValues(alpha: 0.16),
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
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
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
              leading: const Icon(Icons.menu_book_rounded,
                  color: AppColors.primary),
              title: const Text('Weekly Tips'),
              subtitle: const Text('Guidance for your baby & you each week'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WeeklyTipsScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.show_chart_rounded,
                  color: AppColors.secondary),
              title: const Text('Health Trends'),
              subtitle: const Text('Weight & blood pressure over time'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HealthTrendsScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sports_soccer_rounded,
                  color: AppColors.primaryDark),
              title: const Text('Kick History & Trends'),
              subtitle: const Text('Saved kick sessions over time'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const KickHistoryScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.insights_rounded,
                  color: AppColors.primary),
              title: const Text('Symptom & Mood Trends'),
              subtitle: const Text('Common symptoms & mood over time'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const SymptomTrendsScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.event_note_outlined,
                  color: AppColors.secondary),
              title: const Text('Appointments'),
              subtitle: const Text('Manage prenatal visits & scans'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.checklist_rounded,
                  color: AppColors.primaryDark),
              title: const Text('Prep & Checklists'),
              subtitle: const Text('Hospital bag & pregnancy to-do'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrepHubScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.health_and_safety_rounded,
                  color: AppColors.secondary),
              title: const Text('Food & Medicine Safety'),
              subtitle: const Text('What\'s safe to eat, drink & take'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const SafetyCheckerScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.self_improvement_rounded,
                  color: AppColors.primary),
              title: const Text('Breathing & Relaxation'),
              subtitle: const Text('Guided breathing, labor & Kegel exercises'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BreathingScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.spa_rounded,
                  color: AppColors.secondary),
              title: const Text('Daily Wellness'),
              subtitle: const Text('Water, vitamin & mood + streak'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WellnessScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined,
                  color: AppColors.primaryDark),
              title: const Text('Baby Names'),
              subtitle: const Text('Browse, search & shortlist favourites'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BabyNamesScreen()),
              ),
            ),
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
