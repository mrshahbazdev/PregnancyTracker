import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/baby_data.dart';
import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';

class PartnerShareScreen extends ConsumerWidget {
  const PartnerShareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final appointments = ref.watch(appointmentsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Share with Partner')),
        body: const Center(child: Text('Set up your profile first')),
      );
    }

    final now = DateTime.now();
    final week = profile.currentWeek(now);
    final day = profile.currentDayOfWeek(now);
    final info = weekInfoFor(week);
    final daysLeft = profile.daysRemaining(now);
    final progress = profile.progress(now);
    final trimester = profile.trimester(now);
    final dueDateStr = DateFormat.yMMMd().format(profile.dueDate);

    final upcoming = appointments
        .where((a) => a.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Scaffold(
      appBar: AppBar(title: const Text('Share with Partner')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Card(
            color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.favorite_rounded,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Share your pregnancy journey with your partner, '
                      'family, or friends',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Preview card
          const Text('Preview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _PreviewCard(
            name: profile.name,
            week: week,
            day: day,
            trimester: trimester,
            daysLeft: daysLeft,
            progress: progress,
            dueDate: dueDateStr,
            babySize: info.sizeComparison,
            headline: info.headline,
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // Share options
          const Text('Share Options',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),

          _ShareOptionTile(
            icon: Icons.text_snippet_rounded,
            title: 'Pregnancy Update',
            subtitle: 'Share current week, baby size & progress',
            color: AppColors.primary,
            onTap: () => _shareUpdate(context, profile.name, week, day,
                daysLeft, trimester, dueDateStr, info),
          ),
          const SizedBox(height: 8),

          _ShareOptionTile(
            icon: Icons.event_rounded,
            title: 'Upcoming Appointments',
            subtitle: upcoming.isEmpty
                ? 'No upcoming appointments'
                : '${upcoming.length} upcoming',
            color: AppColors.secondary,
            onTap: upcoming.isEmpty
                ? null
                : () => _shareAppointments(context, upcoming),
          ),
          const SizedBox(height: 8),

          _ShareOptionTile(
            icon: Icons.child_care_rounded,
            title: 'Baby Development',
            subtitle: 'Week $week details & milestones',
            color: Colors.amber.shade700,
            onTap: () => _shareBabyDev(context, week, info),
          ),
          const SizedBox(height: 8),

          _ShareOptionTile(
            icon: Icons.timer_rounded,
            title: 'Countdown',
            subtitle: '$daysLeft days until due date',
            color: AppColors.primaryDark,
            onTap: () => _shareCountdown(
                context, profile.name, daysLeft, dueDateStr, week),
          ),
        ],
      ),
    );
  }

  Future<void> _shareUpdate(
    BuildContext context,
    String name,
    int week,
    int day,
    int daysLeft,
    String trimester,
    String dueDate,
    WeekInfo info,
  ) async {
    final greeting = name.isEmpty ? '' : "$name's ";
    final text = '${greeting}Pregnancy Update\n'
        '━━━━━━━━━━━━━━━━━━\n'
        '📅 Week $week, Day $day ($trimester)\n'
        '👶 Baby is the size of a ${info.sizeComparison}\n'
        '📏 Length: ${info.lengthCm} cm | Weight: ${info.weightG}g\n'
        '⏳ $daysLeft days until due date ($dueDate)\n'
        '💫 ${info.headline}\n'
        '━━━━━━━━━━━━━━━━━━\n'
        'Sent from PregnancyTracker';
    await Share.share(text);
  }

  Future<void> _shareAppointments(
    BuildContext context,
    List<Appointment> appointments,
  ) async {
    final buf = StringBuffer('Upcoming Appointments\n━━━━━━━━━━━━━━━━━━\n');
    for (final a in appointments.take(5)) {
      final dt = DateFormat.yMMMd().add_jm().format(a.dateTime);
      buf.writeln('📋 ${a.title} — $dt');
      if (a.location.isNotEmpty) {
        buf.writeln('   📍 ${a.location}');
      }
    }
    buf.writeln('━━━━━━━━━━━━━━━━━━\nSent from PregnancyTracker');
    await Share.share(buf.toString());
  }

  Future<void> _shareBabyDev(
    BuildContext context,
    int week,
    WeekInfo info,
  ) async {
    final text = 'Baby Development — Week $week\n'
        '━━━━━━━━━━━━━━━━━━\n'
        '${info.headline}\n\n'
        '${info.detail}\n\n'
        '👶 Size: ${info.sizeComparison}\n'
        '📏 ${info.lengthCm} cm | ${info.weightG}g\n'
        '━━━━━━━━━━━━━━━━━━\n'
        'Sent from PregnancyTracker';
    await Share.share(text);
  }

  Future<void> _shareCountdown(
    BuildContext context,
    String name,
    int daysLeft,
    String dueDate,
    int week,
  ) async {
    final greeting = name.isEmpty ? 'Our' : "$name's";
    final weeksLeft = (daysLeft / 7).ceil();
    final text = '$greeting Baby Countdown\n'
        '━━━━━━━━━━━━━━━━━━\n'
        '⏳ $daysLeft days to go ($weeksLeft weeks)\n'
        '📅 Due date: $dueDate\n'
        '📊 Currently at week $week\n'
        '━━━━━━━━━━━━━━━━━━\n'
        'Sent from PregnancyTracker';
    await Share.share(text);
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.name,
    required this.week,
    required this.day,
    required this.trimester,
    required this.daysLeft,
    required this.progress,
    required this.dueDate,
    required this.babySize,
    required this.headline,
    required this.isDark,
  });

  final String name;
  final int week;
  final int day;
  final String trimester;
  final int daysLeft;
  final double progress;
  final String dueDate;
  final String babySize;
  final String headline;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.primaryDark.withValues(alpha: 0.3),
                  AppColors.secondary.withValues(alpha: 0.2),
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.secondary.withValues(alpha: 0.10),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (name.isNotEmpty)
            Text("$name's Journey",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoChip(
                  label: 'Week $week, Day $day', color: AppColors.primary),
              const SizedBox(width: 8),
              _InfoChip(label: trimester, color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark ? AppColors.surfaceDark : Colors.white54,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.child_care_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Baby is the size of a $babySize',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 18, color: AppColors.accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(headline,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 18, color: AppColors.secondary),
              const SizedBox(width: 6),
              Text('$daysLeft days until $dueDate',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          )),
    );
  }
}

class _ShareOptionTile extends StatelessWidget {
  const _ShareOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.25 : 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title:
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.share_rounded,
          color: onTap != null
              ? AppColors.primary
              : (isDark ? AppColors.textMutedDark : AppColors.textMuted),
        ),
        onTap: onTap,
      ),
    );
  }
}
