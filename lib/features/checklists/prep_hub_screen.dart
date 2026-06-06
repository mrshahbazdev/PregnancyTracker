import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/checklist_data.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import 'checklist_screen.dart';

class PrepHubScreen extends StatelessWidget {
  const PrepHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prep & Checklists')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: const [
          _ChecklistEntry(
            kind: ChecklistKind.todo,
            title: 'Pregnancy To-Do',
            subtitle: 'Key tasks across all three trimesters',
            icon: Icons.checklist_rtl_rounded,
            accent: AppColors.primary,
          ),
          SizedBox(height: 16),
          _ChecklistEntry(
            kind: ChecklistKind.hospitalBag,
            title: 'Hospital Bag',
            subtitle: 'Everything to pack for the big day',
            icon: Icons.luggage_rounded,
            accent: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}

class _ChecklistEntry extends ConsumerWidget {
  const _ChecklistEntry({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String kind;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(checklistProvider(kind));
    final done = items.where((e) => e.done).length;
    final total = items.length;
    final progress = total == 0 ? 0.0 : done / total;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                ChecklistScreen(kind: kind, title: title, accent: accent),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accent, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 13)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: accent.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(accent),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('$done of $total done',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
