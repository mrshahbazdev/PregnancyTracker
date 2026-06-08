import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/postpartum_stats.dart';
import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';

class PostpartumScreen extends ConsumerWidget {
  const PostpartumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(postpartumProvider);
    final stats = postpartumStats(entries);

    return Scaffold(
      appBar: AppBar(title: const Text('Postpartum Recovery')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log day'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: [
          if (entries.isNotEmpty) ...[
            _StatsCard(stats: stats),
            if (stats.hasHeavyBleeding) ...[
              const SizedBox(height: 12),
              const _CautionBanner(),
            ],
          ],
          const SizedBox(height: 16),
          if (entries.isEmpty)
            const _EmptyState()
          else
            ...entries.map((e) => _PostpartumTile(
                  entry: e,
                  onEdit: () => _openEditor(context, ref, existing: e),
                  onDelete: () =>
                      ref.read(postpartumProvider.notifier).remove(e.id),
                )),
        ],
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    PostpartumEntry? existing,
  }) async {
    final result = await showModalBottomSheet<PostpartumEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PostpartumEditor(existing: existing),
    );
    if (result == null) return;
    final notifier = ref.read(postpartumProvider.notifier);
    if (existing == null) {
      await notifier.add(result);
    } else {
      await notifier.update(result);
    }
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});
  final PostpartumStats stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondary.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _stat('${stats.days}', 'Days'),
            _stat(stats.avgMood == 0 ? '—' : stats.avgMood.toStringAsFixed(1),
                'Avg mood'),
            _stat(stats.avgPain.toStringAsFixed(1), 'Avg pain'),
            _stat(stats.avgFeeds.toStringAsFixed(1), 'Avg feeds'),
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
                  fontSize: 20,
                  color: AppColors.primaryDark)),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      );
}

class _CautionBanner extends StatelessWidget {
  const _CautionBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD23A3A).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFD23A3A)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You logged heavy bleeding. Soaking a pad in under an hour, large '
              'clots, or feeling faint? Contact your provider right away.',
              style: TextStyle(fontSize: 12.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostpartumTile extends StatelessWidget {
  const _PostpartumTile({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final PostpartumEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      'Bleeding: ${entry.bleeding.label}',
      if (entry.mood > 0) 'Mood ${entry.mood}/5',
      'Pain ${entry.pain}/10',
      if (entry.feeds > 0) '${entry.feeds} feeds',
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0x1A7C9CCB),
          child: Icon(Icons.healing_rounded, color: AppColors.secondary),
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

class _PostpartumEditor extends StatefulWidget {
  const _PostpartumEditor({this.existing});
  final PostpartumEntry? existing;

  @override
  State<_PostpartumEditor> createState() => _PostpartumEditorState();
}

class _PostpartumEditorState extends State<_PostpartumEditor> {
  late BleedingLevel _bleeding =
      widget.existing?.bleeding ?? BleedingLevel.none;
  late int _mood = widget.existing?.mood ?? 0;
  late double _pain = (widget.existing?.pain ?? 0).toDouble();
  late int _feeds = widget.existing?.feeds ?? 0;
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
        ? PostpartumEntry(
            id: const Uuid().v4(),
            date: DateTime.now(),
            bleeding: _bleeding,
            mood: _mood,
            pain: _pain.round(),
            feeds: _feeds,
            note: _note.text.trim(),
          )
        : existing.copyWith(
            bleeding: _bleeding,
            mood: _mood,
            pain: _pain.round(),
            feeds: _feeds,
            note: _note.text.trim(),
          );
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
            Text(widget.existing == null ? 'Log recovery day' : 'Edit day',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 16),
            const Text('Bleeding',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final b in BleedingLevel.values)
                  ChoiceChip(
                    label: Text(b.label),
                    selected: _bleeding == b,
                    onSelected: (_) => setState(() => _bleeding = b),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Mood',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    onPressed: () =>
                        setState(() => _mood = _mood == i ? 0 : i),
                    icon: Icon(
                      i <= _mood
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Pain',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${_pain.round()}/10',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark)),
              ],
            ),
            Slider(
              value: _pain,
              min: 0,
              max: 10,
              divisions: 10,
              label: '${_pain.round()}',
              onChanged: (v) => setState(() => _pain = v),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Baby feeds',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton.filledTonal(
                  onPressed:
                      _feeds == 0 ? null : () => setState(() => _feeds--),
                  icon: const Icon(Icons.remove_rounded),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('$_feeds',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                ),
                IconButton.filledTonal(
                  onPressed: () => setState(() => _feeds++),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'e.g. stitches sore, feeling tired',
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
          const Icon(Icons.healing_rounded,
              size: 56, color: AppColors.secondary),
          const SizedBox(height: 16),
          const Text('No recovery days logged',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'After birth, log bleeding, mood, pain and feeds to track your '
            'recovery and share it with your provider.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
