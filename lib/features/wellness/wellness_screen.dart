import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/wellness.dart';
import '../../state/app_state.dart';

class WellnessScreen extends ConsumerWidget {
  const WellnessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(wellnessProvider);
    final notifier = ref.read(wellnessProvider.notifier);
    final today = notifier.today();
    final streak = wellnessStreak(days, DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Wellness')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          _StreakCard(streak: streak),
          const SizedBox(height: 16),
          _WaterCard(
            glasses: today.water,
            onAdd: () => notifier.addWater(1),
            onRemove: () => notifier.addWater(-1),
          ),
          const SizedBox(height: 16),
          _VitaminCard(
            taken: today.vitamin,
            onChanged: notifier.setVitamin,
          ),
          const SizedBox(height: 16),
          _MoodCard(mood: today.mood, onPick: notifier.setMood),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final label = streak == 0
        ? 'Log something today to start your streak'
        : streak == 1
            ? 'You logged today — nice start!'
            : 'Keep it going, you\'re building a healthy habit';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.local_fire_department_rounded,
                  color: AppColors.primaryDark, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    streak == 1 ? '1 day streak' : '$streak day streak',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterCard extends StatelessWidget {
  const _WaterCard(
      {required this.glasses, required this.onAdd, required this.onRemove});

  final int glasses;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final progress = (glasses / kWaterGoal).clamp(0.0, 1.0);
    final reached = glasses >= kWaterGoal;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOut,
                        builder: (_, value, child) => CircularProgressIndicator(
                          value: value,
                          strokeWidth: 8,
                          backgroundColor:
                              AppColors.secondary.withValues(alpha: 0.18),
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.secondary),
                        ),
                      ),
                      const Icon(Icons.water_drop_rounded,
                          color: AppColors.secondary, size: 24),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Water',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(
                        reached
                            ? 'Goal reached — $glasses glasses 🎉'
                            : '$glasses of $kWaterGoal glasses',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _RoundIconButton(
                  icon: Icons.remove_rounded,
                  onTap: glasses > 0 ? onRemove : null,
                ),
                Expanded(
                  child: Center(
                    child: Text('$glasses',
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w800)),
                  ),
                ),
                _RoundIconButton(
                  icon: Icons.add_rounded,
                  filled: true,
                  onTap: onAdd,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton(
      {required this.icon, required this.onTap, this.filled = false});

  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: filled
          ? AppColors.secondary
          : AppColors.secondary.withValues(alpha: enabled ? 0.14 : 0.06),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: filled
                ? Colors.white
                : (enabled
                    ? AppColors.secondary
                    : AppColors.textMuted.withValues(alpha: 0.5)),
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _VitaminCard extends StatelessWidget {
  const _VitaminCard({required this.taken, required this.onChanged});

  final bool taken;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.medication_liquid_rounded,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prenatal vitamin',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  SizedBox(height: 2),
                  Text('Taken today?',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ),
            Switch(
              value: taken,
              activeThumbColor: AppColors.primary,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  const _MoodCard({required this.mood, required this.onPick});

  final int mood;
  final ValueChanged<int> onPick;

  static const _emojis = ['😞', '😕', '😐', '🙂', '😄'];
  static const _labels = ['Low', 'Meh', 'Okay', 'Good', 'Great'];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mood',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < _emojis.length; i++)
                  _MoodOption(
                    emoji: _emojis[i],
                    label: _labels[i],
                    selected: mood == i + 1,
                    onTap: () => onPick(i + 1),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodOption extends StatelessWidget {
  const _MoodOption(
      {required this.emoji,
      required this.label,
      required this.selected,
      required this.onTap});

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color:
                        selected ? AppColors.primaryDark : AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
