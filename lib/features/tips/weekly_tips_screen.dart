import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/weekly_tips.dart';
import '../../state/app_state.dart';

const int _kMinWeek = 4;
const int _kMaxWeek = 40;

class WeeklyTipsScreen extends ConsumerStatefulWidget {
  const WeeklyTipsScreen({super.key});

  @override
  ConsumerState<WeeklyTipsScreen> createState() => _WeeklyTipsScreenState();
}

class _WeeklyTipsScreenState extends ConsumerState<WeeklyTipsScreen> {
  int? _week;

  int get _currentWeek {
    final profile = ref.read(profileProvider);
    final w = profile?.currentWeek(DateTime.now()) ?? _kMinWeek;
    return w.clamp(_kMinWeek, _kMaxWeek);
  }

  int get _selectedWeek => _week ?? _currentWeek;

  void _setWeek(int week) =>
      setState(() => _week = week.clamp(_kMinWeek, _kMaxWeek));

  @override
  Widget build(BuildContext context) {
    final week = _selectedWeek;
    final tips = tipsForWeek(week);
    final isCurrent = week == _currentWeek;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Tips'),
        actions: [
          if (!isCurrent)
            TextButton(
              onPressed: () => setState(() => _week = null),
              child: const Text('This week'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _WeekSelector(
            week: week,
            trimester: tips.trimester,
            isCurrent: isCurrent,
            onPrev: week > _kMinWeek ? () => _setWeek(week - 1) : null,
            onNext: week < _kMaxWeek ? () => _setWeek(week + 1) : null,
            onChanged: (v) => _setWeek(v),
          ),
          const SizedBox(height: 16),
          _TipCard(
            icon: Icons.child_care_rounded,
            color: AppColors.primary,
            title: 'Your baby this week',
            heading: tips.babyHeadline,
            body: tips.babyDetail,
          ),
          const SizedBox(height: 16),
          _TipCard(
            icon: Icons.self_improvement_rounded,
            color: AppColors.secondary,
            title: 'Self-care for you',
            body: tips.selfCare,
          ),
          const SizedBox(height: 16),
          _TipCard(
            icon: Icons.restaurant_rounded,
            color: AppColors.primaryDark,
            title: 'Nutrition tip',
            body: tips.nutrition,
          ),
          const SizedBox(height: 16),
          _TipCard(
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.accent,
            title: 'What to do this week',
            body: tips.toDo,
          ),
          const SizedBox(height: 16),
          const _DisclaimerNote(),
        ],
      ),
    );
  }
}

class _WeekSelector extends StatelessWidget {
  const _WeekSelector({
    required this.week,
    required this.trimester,
    required this.isCurrent,
    required this.onPrev,
    required this.onNext,
    required this.onChanged,
  });

  final int week;
  final int trimester;
  final bool isCurrent;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onPrev,
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: AppColors.primaryDark,
                ),
                Column(
                  children: [
                    Text('Week $week',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w900)),
                    Text(
                      isCurrent
                          ? 'This week · Trimester $trimester'
                          : 'Trimester $trimester',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: AppColors.primaryDark,
                ),
              ],
            ),
            Slider(
              value: week.toDouble(),
              min: _kMinWeek.toDouble(),
              max: _kMaxWeek.toDouble(),
              divisions: _kMaxWeek - _kMinWeek,
              label: 'Week $week',
              activeColor: AppColors.primary,
              onChanged: (v) => onChanged(v.round()),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    this.heading,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? heading;
  final String body;

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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (heading != null) ...[
              Text(heading!,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color)),
              const SizedBox(height: 6),
            ],
            Text(body,
                style: const TextStyle(
                    fontSize: 14, height: 1.5, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerNote extends StatelessWidget {
  const _DisclaimerNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline_rounded,
            size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Educational guidance only — not medical advice. Always follow your '
            'healthcare provider for your personal care.',
            style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textMuted.withValues(alpha: 0.9)),
          ),
        ),
      ],
    );
  }
}
