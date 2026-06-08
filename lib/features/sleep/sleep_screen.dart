import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/sleep_stats.dart';
import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';

class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(sleepProvider);
    final stats = sleepStats(entries);

    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Tracker')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log sleep'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: [
          if (entries.isNotEmpty) _StatsCard(stats: stats),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            const _EmptyState()
          else
            ...entries.map((e) => _SleepTile(
                  entry: e,
                  onEdit: () => _openEditor(context, ref, existing: e),
                  onDelete: () =>
                      ref.read(sleepProvider.notifier).remove(e.id),
                )),
        ],
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    SleepEntry? existing,
  }) async {
    final result = await showModalBottomSheet<SleepEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SleepEditor(existing: existing),
    );
    if (result == null) return;
    final notifier = ref.read(sleepProvider.notifier);
    if (existing == null) {
      await notifier.add(result);
    } else {
      await notifier.update(result);
    }
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});
  final SleepStats stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondary.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _stat('${stats.avgHours.toStringAsFixed(1)}h', 'Avg sleep'),
            _stat(
                stats.avgQuality == 0
                    ? '—'
                    : stats.avgQuality.toStringAsFixed(1),
                'Avg quality'),
            _stat('${stats.nights}', 'Nights'),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: AppColors.primaryDark)),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      );
}

class _SleepTile extends StatelessWidget {
  const _SleepTile({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final SleepEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      '${entry.hours.toStringAsFixed(1)} h',
      if (entry.quality > 0) 'Quality ${entry.quality}/5',
      if (entry.side != SleepSide.unset) entry.side.label,
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0x1A7C9CCB),
          child: Icon(Icons.bedtime_rounded, color: AppColors.secondary),
        ),
        title: Text(DateFormat.yMMMEd().format(entry.date),
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          parts.join(' · ') +
              (entry.note.trim().isEmpty ? '' : '\n${entry.note}'),
          style: const TextStyle(fontSize: 12),
        ),
        isThreeLine: entry.note.trim().isNotEmpty,
        trailing: PopupMenuButton<String>(
          onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

class _SleepEditor extends StatefulWidget {
  const _SleepEditor({this.existing});
  final SleepEntry? existing;

  @override
  State<_SleepEditor> createState() => _SleepEditorState();
}

class _SleepEditorState extends State<_SleepEditor> {
  late double _hours = widget.existing?.hours ?? 8;
  late int _quality = widget.existing?.quality ?? 0;
  late SleepSide _side = widget.existing?.side ?? SleepSide.unset;
  late final TextEditingController _note =
      TextEditingController(text: widget.existing?.note ?? '');

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final existing = widget.existing;
    final entry = existing == null
        ? SleepEntry(
            id: const Uuid().v4(),
            date: DateTime.now(),
            hours: _hours,
            quality: _quality,
            side: _side,
            note: _note.text.trim(),
          )
        : existing.copyWith(
            hours: _hours,
            quality: _quality,
            side: _side,
            note: _note.text.trim());
    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.existing == null ? 'Log sleep' : 'Edit sleep',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Hours slept',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${_hours.toStringAsFixed(1)} h',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark)),
              ],
            ),
            Slider(
              value: _hours,
              min: 0,
              max: 14,
              divisions: 28,
              label: '${_hours.toStringAsFixed(1)} h',
              onChanged: (v) => setState(() => _hours = v),
            ),
            const SizedBox(height: 8),
            const Text('Quality',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    onPressed: () => setState(
                        () => _quality = _quality == i ? 0 : i),
                    icon: Icon(
                      i <= _quality
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Sleeping side',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final s in SleepSide.values)
                  if (s != SleepSide.unset)
                    ChoiceChip(
                      label: Text(s.label),
                      selected: _side == s,
                      onSelected: (_) => setState(
                          () => _side = _side == s ? SleepSide.unset : s),
                    ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'e.g. woke up twice, back ache',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.bedtime_rounded,
              size: 56, color: AppColors.secondary),
          const SizedBox(height: 16),
          const Text('No sleep logged yet',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Log how you slept each night to spot patterns. Resting on your '
            'left side is recommended later in pregnancy.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
