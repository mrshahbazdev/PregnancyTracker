import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';

class ChecklistScreen extends ConsumerWidget {
  const ChecklistScreen({
    super.key,
    required this.kind,
    required this.title,
    required this.accent,
  });

  final String kind;
  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(checklistProvider(kind));
    final done = items.where((e) => e.done).length;
    final total = items.length;
    final progress = total == 0 ? 0.0 : done / total;

    // Preserve insertion order of categories.
    final categories = <String>[];
    for (final item in items) {
      if (!categories.contains(item.category)) categories.add(item.category);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'reset') {
                ref.read(checklistProvider(kind).notifier).resetToDefaults();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'reset', child: Text('Reset to defaults')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accent,
        onPressed: () => _addItem(context, ref, categories),
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
        children: [
          _ProgressHeader(
              progress: progress, done: done, total: total, accent: accent),
          const SizedBox(height: 20),
          for (final category in categories) ...[
            if (category.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 0, 8),
                child: Text(category,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            Card(
              child: Column(
                children: [
                  for (final item
                      in items.where((e) => e.category == category))
                    _ChecklistTile(
                      item: item,
                      accent: accent,
                      onToggle: () => ref
                          .read(checklistProvider(kind).notifier)
                          .toggle(item.id),
                      onDelete: item.custom
                          ? () => ref
                              .read(checklistProvider(kind).notifier)
                              .remove(item.id)
                          : null,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Future<void> _addItem(
      BuildContext context, WidgetRef ref, List<String> categories) async {
    final controller = TextEditingController();
    String category = categories.isNotEmpty ? categories.first : '';
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'What do you want to add?',
                  border: OutlineInputBorder(),
                ),
              ),
              if (categories.where((c) => c.isNotEmpty).isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(
                    labelText: 'Section',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final c in categories.where((c) => c.isNotEmpty))
                      DropdownMenuItem(value: c, child: Text(c)),
                  ],
                  onChanged: (v) => setState(() => category = v ?? category),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    if (result == true && controller.text.trim().isNotEmpty) {
      await ref
          .read(checklistProvider(kind).notifier)
          .addCustom(controller.text.trim(), category);
    }
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.progress,
    required this.done,
    required this.total,
    required this.accent,
  });

  final double progress;
  final int done;
  final int total;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 76,
              height: 76,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      builder: (_, value, child) => CircularProgressIndicator(
                        value: value,
                        strokeWidth: 8,
                        backgroundColor: accent.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(accent),
                      ),
                    ),
                  ),
                  Text('${(progress * 100).round()}%',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: accent)),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress >= 1.0 ? 'All done! 🎉' : '$done of $total done',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    progress >= 1.0
                        ? 'You\'re fully prepared.'
                        : 'Tap items as you complete them.',
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

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.item,
    required this.accent,
    required this.onToggle,
    this.onDelete,
  });

  final ChecklistItem item;
  final Color accent;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: item.done ? accent : Colors.transparent,
                border: Border.all(
                    color: item.done
                        ? accent
                        : AppColors.textMuted.withValues(alpha: 0.5),
                    width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.done
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 15,
                  decoration:
                      item.done ? TextDecoration.lineThrough : null,
                  color: item.done ? AppColors.textMuted : AppColors.textDark,
                ),
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.close,
                    size: 18, color: AppColors.textMuted),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
