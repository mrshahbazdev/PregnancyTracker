import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/cravings_stats.dart';
import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';

class CravingsScreen extends ConsumerWidget {
  const CravingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(cravingsProvider);
    final summary = cravingsSummary(entries);

    return Scaffold(
      appBar: AppBar(title: const Text('Cravings & Aversions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: [
          if (entries.isNotEmpty) _SummaryCard(summary: summary),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            const _EmptyState()
          else
            ...entries.map((e) => _CravingTile(
                  entry: e,
                  onEdit: () => _openEditor(context, ref, existing: e),
                  onDelete: () =>
                      ref.read(cravingsProvider.notifier).remove(e.id),
                )),
        ],
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    CravingEntry? existing,
  }) async {
    final week = ref.read(profileProvider)?.currentWeek(DateTime.now());
    final result = await showModalBottomSheet<CravingEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CravingEditor(existing: existing, currentWeek: week),
    );
    if (result == null) return;
    final notifier = ref.read(cravingsProvider.notifier);
    if (existing == null) {
      await notifier.add(result);
    } else {
      await notifier.update(result);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});
  final CravingsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondary.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('${summary.cravings}', 'Cravings'),
                _stat('${summary.aversions}', 'Aversions'),
                _stat('${summary.total}', 'Total'),
              ],
            ),
            if (summary.topItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Most logged',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final item in summary.topItems)
                    Chip(
                      label: Text(item),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
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

class _CravingTile extends StatelessWidget {
  const _CravingTile({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final CravingEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isCraving = entry.kind == CravingKind.craving;
    final meta = <String>[
      DateFormat.yMMMEd().format(entry.date),
      if (entry.week != null) 'Week ${entry.week}',
      if (entry.intensity > 0) 'Intensity ${entry.intensity}/5',
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isCraving ? AppColors.primary : AppColors.secondary)
              .withValues(alpha: 0.15),
          child: Icon(
            isCraving
                ? Icons.favorite_rounded
                : Icons.thumb_down_alt_rounded,
            color: isCraving ? AppColors.primary : AppColors.secondary,
          ),
        ),
        title: Text(entry.item,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          meta.join(' · ') +
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

class _CravingEditor extends StatefulWidget {
  const _CravingEditor({this.existing, this.currentWeek});
  final CravingEntry? existing;
  final int? currentWeek;

  @override
  State<_CravingEditor> createState() => _CravingEditorState();
}

class _CravingEditorState extends State<_CravingEditor> {
  late final TextEditingController _item =
      TextEditingController(text: widget.existing?.item ?? '');
  late final TextEditingController _note =
      TextEditingController(text: widget.existing?.note ?? '');
  late CravingKind _kind = widget.existing?.kind ?? CravingKind.craving;
  late int _intensity = widget.existing?.intensity ?? 0;

  @override
  void dispose() {
    _item.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final item = _item.text.trim();
    if (item.isEmpty) return;
    final existing = widget.existing;
    final entry = existing == null
        ? CravingEntry(
            id: const Uuid().v4(),
            date: DateTime.now(),
            item: item,
            kind: _kind,
            intensity: _intensity,
            note: _note.text.trim(),
            week: widget.currentWeek,
          )
        : existing.copyWith(
            item: item,
            kind: _kind,
            intensity: _intensity,
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
            Text(widget.existing == null ? 'Log craving' : 'Edit entry',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 16),
            SegmentedButton<CravingKind>(
              segments: const [
                ButtonSegment(
                    value: CravingKind.craving,
                    icon: Icon(Icons.favorite_rounded),
                    label: Text('Craving')),
                ButtonSegment(
                    value: CravingKind.aversion,
                    icon: Icon(Icons.thumb_down_alt_rounded),
                    label: Text('Aversion')),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _item,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Food or drink',
                hintText: 'e.g. mango, pickles, coffee',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Intensity',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    onPressed: () => setState(
                        () => _intensity = _intensity == i ? 0 : i),
                    icon: Icon(
                      i <= _intensity
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'e.g. only in the mornings',
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
          const Icon(Icons.restaurant_rounded,
              size: 56, color: AppColors.secondary),
          const SizedBox(height: 16),
          const Text('No cravings logged yet',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Track the foods you crave or can\u2019t stand. Over time you\u2019ll '
            'see your most common cravings and aversions.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
