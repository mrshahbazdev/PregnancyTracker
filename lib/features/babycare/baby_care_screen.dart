import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/baby_care_stats.dart';
import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';

class BabyCareScreen extends ConsumerWidget {
  const BabyCareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(babyCareProvider);
    final today = babyCareDaySummary(entries, DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Feeding & Diapers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref, kind: BabyCareKind.feed),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: [
          _TodayCard(summary: today),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _openEditor(context, ref, kind: BabyCareKind.feed),
                  icon: const Icon(Icons.local_drink_rounded),
                  label: const Text('Feed'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _openEditor(context, ref, kind: BabyCareKind.diaper),
                  icon: const Icon(Icons.baby_changing_station_rounded),
                  label: const Text('Diaper'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            const _EmptyState()
          else
            ...entries.map((e) => _CareTile(
                  entry: e,
                  onEdit: () =>
                      _openEditor(context, ref, kind: e.kind, existing: e),
                  onDelete: () =>
                      ref.read(babyCareProvider.notifier).remove(e.id),
                )),
        ],
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    required BabyCareKind kind,
    BabyCareEntry? existing,
  }) async {
    final result = await showModalBottomSheet<BabyCareEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CareEditor(kind: kind, existing: existing),
    );
    if (result == null) return;
    final notifier = ref.read(babyCareProvider.notifier);
    if (existing == null) {
      await notifier.add(result);
    } else {
      await notifier.update(result);
    }
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.summary});
  final BabyCareDaySummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondary.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('${summary.feeds}', 'Feeds'),
                _stat('${summary.wetDiapers}', 'Wet'),
                _stat('${summary.dirtyDiapers}', 'Dirty'),
              ],
            ),
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

class _CareTile extends StatelessWidget {
  const _CareTile({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final BabyCareEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isFeed = entry.kind == BabyCareKind.feed;
    final String title;
    if (isFeed) {
      title = entry.amountMl > 0
          ? '${entry.feedType.label} · ${entry.amountMl.round()} ml'
          : entry.feedType.label;
    } else {
      title = '${entry.diaperType.label} diaper';
    }
    final meta = DateFormat('EEE, MMM d · h:mm a').format(entry.time);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isFeed ? AppColors.primary : AppColors.secondary)
              .withValues(alpha: 0.15),
          child: Icon(
            isFeed
                ? Icons.local_drink_rounded
                : Icons.baby_changing_station_rounded,
            color: isFeed ? AppColors.primary : AppColors.secondary,
          ),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          meta + (entry.note.trim().isEmpty ? '' : '\n${entry.note}'),
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

class _CareEditor extends StatefulWidget {
  const _CareEditor({required this.kind, this.existing});
  final BabyCareKind kind;
  final BabyCareEntry? existing;

  @override
  State<_CareEditor> createState() => _CareEditorState();
}

class _CareEditorState extends State<_CareEditor> {
  late FeedType _feedType = widget.existing?.feedType ??
      (widget.kind == BabyCareKind.feed ? FeedType.breast : FeedType.unset);
  late DiaperType _diaperType = widget.existing?.diaperType ?? DiaperType.wet;
  late final TextEditingController _amount = TextEditingController(
      text: (widget.existing?.amountMl ?? 0) > 0
          ? widget.existing!.amountMl.round().toString()
          : '');
  late final TextEditingController _note =
      TextEditingController(text: widget.existing?.note ?? '');

  bool get _isFeed => widget.kind == BabyCareKind.feed;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final existing = widget.existing;
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    final entry = existing == null
        ? BabyCareEntry(
            id: const Uuid().v4(),
            time: DateTime.now(),
            kind: widget.kind,
            feedType: _isFeed ? _feedType : FeedType.unset,
            amountMl: _isFeed ? amount : 0,
            diaperType: _diaperType,
            note: _note.text.trim(),
          )
        : existing.copyWith(
            feedType: _isFeed ? _feedType : FeedType.unset,
            amountMl: _isFeed ? amount : 0,
            diaperType: _diaperType,
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
            Text(
                widget.existing != null
                    ? 'Edit ${_isFeed ? 'feed' : 'diaper'}'
                    : 'Log ${_isFeed ? 'feed' : 'diaper'}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 16),
            if (_isFeed) ...[
              const Text('Feed type',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (final f in [FeedType.breast, FeedType.bottle])
                    ChoiceChip(
                      label: Text(f.label),
                      selected: _feedType == f,
                      onSelected: (_) => setState(() => _feedType = f),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: false),
                decoration: const InputDecoration(
                  labelText: 'Amount (ml, optional)',
                  hintText: 'e.g. 90',
                ),
              ),
            ] else ...[
              const Text('Diaper',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (final d in DiaperType.values)
                    ChoiceChip(
                      label: Text(d.label),
                      selected: _diaperType == d,
                      onSelected: (_) => setState(() => _diaperType = d),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
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
          const Icon(Icons.child_friendly_rounded,
              size: 56, color: AppColors.secondary),
          const SizedBox(height: 16),
          const Text('No logs yet',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Track your newborn\u2019s feeds and diaper changes to spot daily '
            'patterns and share them at check-ups.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
