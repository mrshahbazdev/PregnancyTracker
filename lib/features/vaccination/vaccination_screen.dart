import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/vaccination_data.dart';
import '../../state/app_state.dart';

class VaccinationScreen extends ConsumerWidget {
  const VaccinationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doneSet = ref.watch(vaccineDoneProvider);
    final total = vaccineSchedule.length;
    final completed = doneSet.length;
    final upcoming = total - completed;
    final progress = total > 0 ? completed / total : 0.0;

    final brackets = vaccineAgeBrackets;

    return Scaffold(
      appBar: AppBar(title: const Text('Vaccination Schedule')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _SummaryCard(
              total: total,
              completed: completed,
              upcoming: upcoming,
              progress: progress),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Based on WHO/CDC recommendations. Always confirm with your paediatrician.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          ...brackets.map((age) {
            final vaccines =
                vaccineSchedule.where((v) => v.ageLabel == age).toList();
            return _AgeBracket(age: age, vaccines: vaccines);
          }),
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
    required this.completed,
    required this.upcoming,
    required this.progress,
  });

  final int total;
  final int completed;
  final int upcoming;
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
                          AppColors.primary.withValues(alpha: 0.15),
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                        fontSize: 16,
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
                  const Text('Immunization Progress',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _MiniStat(
                          label: 'Total', value: '$total', color: AppColors.textMuted),
                      const SizedBox(width: 16),
                      _MiniStat(
                          label: 'Done',
                          value: '$completed',
                          color: Colors.green),
                      const SizedBox(width: 16),
                      _MiniStat(
                          label: 'Upcoming',
                          value: '$upcoming',
                          color: AppColors.secondary),
                    ],
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

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Age bracket group
// ---------------------------------------------------------------------------

class _AgeBracket extends StatelessWidget {
  const _AgeBracket({required this.age, required this.vaccines});
  final String age;
  final List<VaccineInfo> vaccines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(age,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark)),
        ),
        const SizedBox(height: 8),
        ...vaccines.map((v) => _VaccineTile(vaccine: v)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual vaccine tile
// ---------------------------------------------------------------------------

class _VaccineTile extends ConsumerWidget {
  const _VaccineTile({required this.vaccine});
  final VaccineInfo vaccine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = ref.watch(vaccineDoneProvider).contains(vaccine.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: done
                ? Colors.green.withValues(alpha: 0.12)
                : AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            done ? Icons.check_circle_rounded : Icons.vaccines_rounded,
            color: done ? Colors.green : AppColors.secondary,
            size: 22,
          ),
        ),
        title: Text(vaccine.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: done ? TextDecoration.lineThrough : null,
              color: done ? AppColors.textMuted : null,
            )),
        subtitle: Text(vaccine.description,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        trailing: Checkbox(
          value: done,
          activeColor: Colors.green,
          onChanged: (_) =>
              ref.read(vaccineDoneProvider.notifier).toggle(vaccine.id),
        ),
        onTap: () =>
            ref.read(vaccineDoneProvider.notifier).toggle(vaccine.id),
      ),
    );
  }
}
