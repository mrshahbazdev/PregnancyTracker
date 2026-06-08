import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';

const _moodEmojis = ['😢', '😕', '😐', '🙂', '😄'];

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(journalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pregnancy Journal')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.edit_rounded),
        label: const Text('New entry'),
      ),
      body: entries.isEmpty
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
              children: [
                _SummaryCard(entries: entries),
                const SizedBox(height: 16),
                ...entries.map((e) => _JournalCard(
                      entry: e,
                      onTap: () => _openEditor(context, ref, existing: e),
                      onDelete: () =>
                          ref.read(journalProvider.notifier).remove(e.id),
                    )),
              ],
            ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    JournalEntry? existing,
  }) async {
    final profile = ref.read(profileProvider);
    final week = profile?.currentWeek(DateTime.now());
    final result = await showModalBottomSheet<JournalEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _JournalEditor(existing: existing, currentWeek: week),
    );
    if (result == null) return;
    final notifier = ref.read(journalProvider.notifier);
    if (existing == null) {
      await notifier.add(result);
    } else {
      await notifier.update(result);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.entries});
  final List<JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    final latest = entries.first;
    return Card(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.menu_book_rounded,
                color: AppColors.primary, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(
                      'Last written ${DateFormat.MMMd().format(latest.date)}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  final JournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (entry.mood > 0) ...[
                    Text(_moodEmojis[entry.mood - 1],
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(entry.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 20, color: AppColors.textMuted),
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(DateFormat.yMMMMd().format(entry.date),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                  if (entry.week != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Week ${entry.week}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
              ),
              if (entry.body.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(entry.body,
                    style: const TextStyle(
                        fontSize: 14, height: 1.4, color: AppColors.textDark)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalEditor extends StatefulWidget {
  const _JournalEditor({this.existing, this.currentWeek});
  final JournalEntry? existing;
  final int? currentWeek;

  @override
  State<_JournalEditor> createState() => _JournalEditorState();
}

class _JournalEditorState extends State<_JournalEditor> {
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _body =
      TextEditingController(text: widget.existing?.body ?? '');
  late int _mood = widget.existing?.mood ?? 0;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title first')),
      );
      return;
    }
    final existing = widget.existing;
    final entry = existing == null
        ? JournalEntry(
            id: const Uuid().v4(),
            date: DateTime.now(),
            title: title,
            body: _body.text.trim(),
            week: widget.currentWeek,
            mood: _mood,
          )
        : existing.copyWith(title: title, body: _body.text.trim(), mood: _mood);
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
          Text(widget.existing == null ? 'New journal entry' : 'Edit entry',
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'How are you feeling today?',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _body,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Write whatever is on your mind…',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Mood', style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 1; i <= 5; i++)
                GestureDetector(
                  onTap: () => setState(() => _mood = _mood == i ? 0 : i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _mood == i
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : Colors.transparent,
                    ),
                    child: Text(_moodEmojis[i - 1],
                        style: const TextStyle(fontSize: 26)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: const Text('Save entry'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_rounded,
                size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('Your journal is empty',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Capture how you\'re feeling week by week — a keepsake to look '
              'back on.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
