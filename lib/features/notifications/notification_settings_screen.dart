import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../state/app_state.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);
    final notifier = ref.read(notificationPrefsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Stay on top of your pregnancy journey with gentle reminders.',
            style: TextStyle(color: mutedColor, height: 1.4),
          ),
          const SizedBox(height: 24),

          // Daily wellness
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(
                              alpha: isDark ? 0.25 : 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.spa_rounded,
                            color: AppColors.secondary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Daily wellness reminder',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                      Switch(
                        value: prefs.wellnessEnabled,
                        onChanged: (v) => notifier.toggleWellness(v),
                        activeTrackColor: AppColors.primary,
                      ),
                    ],
                  ),
                  if (prefs.wellnessEnabled) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: prefs.wellnessHour,
                            minute: prefs.wellnessMinute,
                          ),
                        );
                        if (time != null) {
                          await notifier.setWellnessTime(
                              time.hour, time.minute);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(
                              alpha: isDark ? 0.15 : 0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Remind at ${_formatTime(prefs.wellnessHour, prefs.wellnessMinute)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            const Icon(Icons.edit_rounded, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text('Log water, vitamin & mood',
                      style: TextStyle(color: mutedColor, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Weekly update
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(
                              alpha: isDark ? 0.25 : 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.child_care_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Weekly baby update',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                      Switch(
                        value: prefs.weeklyEnabled,
                        onChanged: (v) => notifier.toggleWeekly(v),
                        activeTrackColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('New development milestones each week',
                      style: TextStyle(color: mutedColor, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Appointment reminders
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(
                              alpha: isDark ? 0.25 : 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.event_rounded,
                            color: AppColors.primaryDark, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Appointment reminders',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                      Switch(
                        value: prefs.appointmentEnabled,
                        onChanged: (v) => notifier.toggleAppointment(v),
                        activeTrackColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Get reminded 1 hour before visits',
                      style: TextStyle(color: mutedColor, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int hour, int minute) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}
