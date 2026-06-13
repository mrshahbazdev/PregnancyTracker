import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/milestone_tracker_data.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';

class BabyMilestonesScreen extends ConsumerWidget {
  const BabyMilestonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dates = ref.watch(milestoneDatesProvider);
    final total = babyMilestones.length;
    final achieved = dates.length;
    final progress = total > 0 ? achieved / total : 0.0;

    // Group milestones by age
    final ageGroups = <int, List<BabyMilestone>>{};
    for (final m in babyMilestones) {
      ageGroups.putIfAbsent(m.typicalAgeMonths, () => []).add(m);
    }
    final sortedAges = ageGroups.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Baby Milestones')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _SummaryCard(
              total: total, achieved: achieved, progress: progress),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Every baby develops at their own pace. These are typical ages — variations are normal.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          ...sortedAges.map((age) => _AgeGroup(
                age: age,
                milestones: ageGroups[age]!,
              )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.achieved,
    required this.progress,
  });

  final int total;
  final int achieved;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 7,
                      backgroundColor:
                          AppColors.secondary.withValues(alpha: 0.15),
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.secondary),
                    ),
                  ),
                  Text(
                    '$achieved',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Milestones Achieved',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    '$achieved of $total milestones',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor:
                          AppColors.secondary.withValues(alpha: 0.15),
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.secondary),
                    ),
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

// ---------------------------------------------------------------------------
// Age group
// ---------------------------------------------------------------------------

class _AgeGroup extends StatelessWidget {
  const _AgeGroup({required this.age, required this.milestones});
  final int age;
  final List<BabyMilestone> milestones;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(ageLabel(age),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark)),
        ),
        const SizedBox(height: 8),
        ...milestones.map((m) => _MilestoneTile(milestone: m)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual milestone tile
// ---------------------------------------------------------------------------

class _MilestoneTile extends ConsumerWidget {
  const _MilestoneTile({required this.milestone});
  final BabyMilestone milestone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dates = ref.watch(milestoneDatesProvider);
    final achieved = dates.containsKey(milestone.id);
    final dateStr = dates[milestone.id];
    final formattedDate = dateStr != null
        ? DateFormat.yMMMd().format(DateTime.parse(dateStr))
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: achieved
                ? Colors.green.withValues(alpha: 0.12)
                : AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: achieved
                ? const Icon(Icons.emoji_events_rounded,
                    color: Colors.amber, size: 22)
                : Text(milestone.category.icon,
                    style: const TextStyle(fontSize: 18)),
          ),
        ),
        title: Text(
          milestone.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: achieved ? AppColors.textMuted : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(milestone.description,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            if (formattedDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text('Achieved $formattedDate',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
        trailing: achieved
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                tooltip: 'Unmark',
                onPressed: () => ref
                    .read(milestoneDatesProvider.notifier)
                    .unmark(milestone.id),
              )
            : null,
        onTap: achieved
            ? null
            : () => _pickDate(context, ref),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      ref.read(milestoneDatesProvider.notifier).markAchieved(milestone.id, picked);
    }
  }
}
