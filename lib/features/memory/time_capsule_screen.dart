import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';

/// Time Capsule: parents write notes/letters to their baby that are collected
/// into a keepsake to share after birth.
class TimeCapsuleScreen extends ConsumerWidget {
  const TimeCapsuleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(memoriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Time Capsule')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addMemory(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('New memory'),
      ),
      body: memories.isEmpty
          ? const _Empty()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: memories.length,
              itemBuilder: (context, i) {
                final m = memories[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Text('💌',
                        style: TextStyle(fontSize: 28)),
                    title: Text(m.title,
                        style:
                            const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(m.body),
                        const SizedBox(height: 8),
                        Text(DateFormat.yMMMMd().format(m.date),
                            style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => ref
                          .read(memoriesProvider.notifier)
                          .remove(m.id),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _addMemory(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('A note for your baby',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. The day we heard your heartbeat',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Your message',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save to capsule'),
              ),
            ),
          ],
        ),
      ),
    );

    if (saved == true &&
        (titleController.text.trim().isNotEmpty ||
            bodyController.text.trim().isNotEmpty)) {
      await ref.read(memoriesProvider.notifier).add(MemoryEntry(
            id: const Uuid().v4(),
            date: DateTime.now(),
            title: titleController.text.trim().isEmpty
                ? 'Untitled memory'
                : titleController.text.trim(),
            body: bodyController.text.trim(),
          ));
    }
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('💌', style: TextStyle(fontSize: 56)),
            SizedBox(height: 16),
            Text('Your keepsake awaits',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text(
              'Capture letters and memories during your pregnancy to share with your baby one day.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
