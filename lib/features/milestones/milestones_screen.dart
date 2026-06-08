import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/milestones.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';

class MilestonesScreen extends ConsumerWidget {
  const MilestonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Milestones & Countdown')),
      body: profile == null
          ? const Center(child: Text('Complete onboarding first'))
          : Builder(builder: (context) {
              final now = DateTime.now();
              final week = profile.currentWeek(now);
              final daysLeft = profile.daysRemaining(now);
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _CountdownCard(
                    daysLeft: daysLeft,
                    dueDate: profile.dueDate,
                    week: week,
                  ),
                  const SizedBox(height: 20),
                  for (var i = 0; i < kMilestones.length; i++)
                    _MilestoneTile(
                      milestone: kMilestones[i],
                      status:
                          milestoneStatus(week, kMilestones[i].week),
                      date: milestoneDate(profile, kMilestones[i].week),
                      now: now,
                      isLast: i == kMilestones.length - 1,
                    ),
                ],
              );
            }),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({
    required this.daysLeft,
    required this.dueDate,
    required this.week,
  });

  final int daysLeft;
  final DateTime dueDate;
  final int week;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('$daysLeft',
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 48,
                    color: AppColors.primaryDark,
                    height: 1.0)),
            const Text('days to your due date',
                style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Text(
              'Week $week · Due ${DateFormat.yMMMMd().format(dueDate)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({
    required this.milestone,
    required this.status,
    required this.date,
    required this.now,
    required this.isLast,
  });

  final Milestone milestone;
  final MilestoneStatus status;
  final DateTime date;
  final DateTime now;
  final bool isLast;

  Color get _color => switch (status) {
        MilestoneStatus.done => Colors.green.shade600,
        MilestoneStatus.current => AppColors.primary,
        MilestoneStatus.upcoming => AppColors.textMuted,
      };

  IconData get _icon => switch (status) {
        MilestoneStatus.done => Icons.check_circle_rounded,
        MilestoneStatus.current => Icons.radio_button_checked_rounded,
        MilestoneStatus.upcoming => Icons.radio_button_unchecked_rounded,
      };

  String get _timing {
    final days = daysUntil(now, date);
    return switch (status) {
      MilestoneStatus.done => 'Passed',
      MilestoneStatus.current => 'This week',
      MilestoneStatus.upcoming =>
        days <= 0 ? 'Soon' : 'In $days day${days == 1 ? '' : 's'}',
    };
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(_icon, color: _color, size: 26),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.textMuted.withValues(alpha: 0.25),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: status == MilestoneStatus.current
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 8,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(milestone.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_timing,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: _color,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('Week ${milestone.week} · '
                        '${DateFormat.MMMd().format(date)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    Text(milestone.detail,
                        style: const TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: AppColors.textDark)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
