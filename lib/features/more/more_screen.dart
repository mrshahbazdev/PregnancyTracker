import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../affirmations/affirmations_screen.dart';
import '../backup/backup_screen.dart';
import '../appointments/appointments_screen.dart';
import '../babycare/baby_care_screen.dart';
import '../babymilestones/baby_milestones_screen.dart';
import '../birthplan/birth_plan_screen.dart';
import '../budget/budget_screen.dart';
import '../checklists/prep_hub_screen.dart';
import '../contacts/emergency_contacts_screen.dart';
import '../cravings/cravings_screen.dart';
import '../exercises/breathing_screen.dart';
import '../glossary/glossary_screen.dart';
import '../notifications/notification_settings_screen.dart';
import '../nutrition/nutrition_screen.dart';
import '../photos/bump_photos_screen.dart';
import '../sharing/partner_share_screen.dart';
import '../growth/growth_screen.dart';
import '../journal/journal_screen.dart';
import '../memory/time_capsule_screen.dart';
import '../milestones/milestones_screen.dart';
import '../names/baby_names_screen.dart';
import '../postpartum/postpartum_screen.dart';
import '../safety/safety_checker_screen.dart';
import '../settings/settings_screen.dart';
import '../sleep/sleep_screen.dart';
import '../tips/weekly_tips_screen.dart';
import '../trends/health_trends_screen.dart';
import '../trends/kick_history_screen.dart';
import '../trends/symptom_trends_screen.dart';
import '../vaccination/vaccination_screen.dart';
import '../weight/weight_goal_screen.dart';
import '../wellness/wellness_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
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
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          _SectionHeader(
            icon: Icons.favorite_rounded,
            title: 'Health & Tracking',
            color: AppColors.primary,
          ),
          _FeatureGrid(items: _healthItems),
          const SizedBox(height: 20),
          _SectionHeader(
            icon: Icons.show_chart_rounded,
            title: 'Trends & Insights',
            color: AppColors.secondary,
          ),
          _FeatureGrid(items: _trendItems),
          const SizedBox(height: 20),
          _SectionHeader(
            icon: Icons.checklist_rounded,
            title: 'Planning & Prep',
            color: AppColors.primaryDark,
          ),
          _FeatureGrid(items: _planningItems),
          const SizedBox(height: 20),
          _SectionHeader(
            icon: Icons.auto_awesome_rounded,
            title: 'Emotional & Memory',
            color: AppColors.accent,
          ),
          _FeatureGrid(items: _emotionalItems),
          const SizedBox(height: 20),
          _SectionHeader(
            icon: Icons.child_friendly_rounded,
            title: 'Post-Birth & Baby',
            color: AppColors.secondary,
          ),
          _FeatureGrid(items: _postBirthItems),
          const SizedBox(height: 20),
          _SectionHeader(
            icon: Icons.menu_book_rounded,
            title: 'Learn & Reference',
            color: AppColors.primaryDark,
          ),
          _FeatureGrid(items: _learnItems),
          const SizedBox(height: 20),
          _SectionHeader(
            icon: Icons.build_rounded,
            title: 'Tools & Data',
            color: AppColors.accent,
          ),
          _FeatureGrid(items: _toolsItems),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Settings available in the top-right corner',
              style: TextStyle(color: mutedColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 0, 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.items});
  final List<_FeatureItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return _FeatureTile(item: item);
      },
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.item});
  final _FeatureItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: item.builder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: isDark ? 0.25 : 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.builder,
  });
  final IconData icon;
  final String label;
  final Color color;
  final WidgetBuilder builder;
}

// ---- Feature item lists by category ----

final _healthItems = [
  _FeatureItem(
    icon: Icons.spa_rounded,
    label: 'Daily Wellness',
    color: AppColors.secondary,
    builder: (_) => const WellnessScreen(),
  ),
  _FeatureItem(
    icon: Icons.bedtime_rounded,
    label: 'Sleep',
    color: AppColors.secondary,
    builder: (_) => const SleepScreen(),
  ),
  _FeatureItem(
    icon: Icons.restaurant_rounded,
    label: 'Cravings',
    color: AppColors.accent,
    builder: (_) => const CravingsScreen(),
  ),
  _FeatureItem(
    icon: Icons.restaurant_menu_rounded,
    label: 'Nutrition',
    color: Colors.green,
    builder: (_) => const NutritionScreen(),
  ),
  _FeatureItem(
    icon: Icons.monitor_weight_rounded,
    label: 'Weight Goal',
    color: AppColors.primaryDark,
    builder: (_) => const WeightGoalScreen(),
  ),
  _FeatureItem(
    icon: Icons.self_improvement_rounded,
    label: 'Breathing',
    color: AppColors.primary,
    builder: (_) => const BreathingScreen(),
  ),
];

final _trendItems = [
  _FeatureItem(
    icon: Icons.show_chart_rounded,
    label: 'Health Trends',
    color: AppColors.secondary,
    builder: (_) => const HealthTrendsScreen(),
  ),
  _FeatureItem(
    icon: Icons.sports_soccer_rounded,
    label: 'Kick History',
    color: AppColors.primaryDark,
    builder: (_) => const KickHistoryScreen(),
  ),
  _FeatureItem(
    icon: Icons.insights_rounded,
    label: 'Symptom Trends',
    color: AppColors.primary,
    builder: (_) => const SymptomTrendsScreen(),
  ),
];

final _planningItems = [
  _FeatureItem(
    icon: Icons.event_note_outlined,
    label: 'Appointments',
    color: AppColors.secondary,
    builder: (_) => const AppointmentsScreen(),
  ),
  _FeatureItem(
    icon: Icons.checklist_rounded,
    label: 'Prep & Lists',
    color: AppColors.primaryDark,
    builder: (_) => const PrepHubScreen(),
  ),
  _FeatureItem(
    icon: Icons.description_outlined,
    label: 'Birth Plan',
    color: AppColors.primary,
    builder: (_) => const BirthPlanScreen(),
  ),
  _FeatureItem(
    icon: Icons.savings_rounded,
    label: 'Baby Budget',
    color: AppColors.secondary,
    builder: (_) => const BudgetScreen(),
  ),
  _FeatureItem(
    icon: Icons.timeline_rounded,
    label: 'Milestones',
    color: AppColors.primary,
    builder: (_) => const MilestonesScreen(),
  ),
  _FeatureItem(
    icon: Icons.contact_phone_rounded,
    label: 'Emergency',
    color: AppColors.primaryDark,
    builder: (_) => const EmergencyContactsScreen(),
  ),
];

final _emotionalItems = [
  _FeatureItem(
    icon: Icons.menu_book_rounded,
    label: 'Journal',
    color: AppColors.primaryDark,
    builder: (_) => const JournalScreen(),
  ),
  _FeatureItem(
    icon: Icons.book_outlined,
    label: 'Time Capsule',
    color: AppColors.primary,
    builder: (_) => const TimeCapsuleScreen(),
  ),
  _FeatureItem(
    icon: Icons.auto_awesome_rounded,
    label: 'Affirmations',
    color: AppColors.secondary,
    builder: (_) => const AffirmationsScreen(),
  ),
  _FeatureItem(
    icon: Icons.badge_outlined,
    label: 'Baby Names',
    color: AppColors.primaryDark,
    builder: (_) => const BabyNamesScreen(),
  ),
  _FeatureItem(
    icon: Icons.photo_camera_rounded,
    label: 'Bump Photos',
    color: AppColors.primary,
    builder: (_) => const BumpPhotosScreen(),
  ),
];

final _postBirthItems = [
  _FeatureItem(
    icon: Icons.healing_rounded,
    label: 'Postpartum',
    color: AppColors.primary,
    builder: (_) => const PostpartumScreen(),
  ),
  _FeatureItem(
    icon: Icons.child_friendly_rounded,
    label: 'Feeds & Diapers',
    color: AppColors.secondary,
    builder: (_) => const BabyCareScreen(),
  ),
  _FeatureItem(
    icon: Icons.straighten_rounded,
    label: 'Baby Growth',
    color: AppColors.primary,
    builder: (_) => const GrowthScreen(),
  ),
  _FeatureItem(
    icon: Icons.vaccines_rounded,
    label: 'Vaccines',
    color: AppColors.secondary,
    builder: (_) => const VaccinationScreen(),
  ),
  _FeatureItem(
    icon: Icons.emoji_events_rounded,
    label: 'Baby Milestones',
    color: Colors.amber,
    builder: (_) => const BabyMilestonesScreen(),
  ),
];

final _toolsItems = [
  _FeatureItem(
    icon: Icons.notifications_rounded,
    label: 'Notifications',
    color: AppColors.primary,
    builder: (_) => const NotificationSettingsScreen(),
  ),
  _FeatureItem(
    icon: Icons.cloud_download_rounded,
    label: 'Backup',
    color: AppColors.secondary,
    builder: (_) => const BackupScreen(),
  ),
  _FeatureItem(
    icon: Icons.favorite_rounded,
    label: 'Partner Share',
    color: AppColors.accent,
    builder: (_) => const PartnerShareScreen(),
  ),
];

final _learnItems = [
  _FeatureItem(
    icon: Icons.menu_book_rounded,
    label: 'Weekly Tips',
    color: AppColors.primary,
    builder: (_) => const WeeklyTipsScreen(),
  ),
  _FeatureItem(
    icon: Icons.health_and_safety_rounded,
    label: 'Food Safety',
    color: AppColors.secondary,
    builder: (_) => const SafetyCheckerScreen(),
  ),
  _FeatureItem(
    icon: Icons.menu_book_rounded,
    label: 'Glossary',
    color: AppColors.primaryDark,
    builder: (_) => const GlossaryScreen(),
  ),
];
