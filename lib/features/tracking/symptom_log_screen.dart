import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';

const _commonSymptoms = [
  'Nausea',
  'Fatigue',
  'Headache',
  'Back pain',
  'Cravings',
  'Heartburn',
  'Swelling',
  'Cramps',
  'Dizziness',
  'Insomnia',
];

const _moods = ['😢', '😕', '😐', '🙂', '😄'];

class SymptomLogScreen extends ConsumerStatefulWidget {
  const SymptomLogScreen({super.key});

  @override
  ConsumerState<SymptomLogScreen> createState() => _SymptomLogScreenState();
}

class _SymptomLogScreenState extends ConsumerState<SymptomLogScreen> {
  final Set<String> _selected = {};
  int _mood = 0;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selected.isEmpty && _mood == 0 && _noteController.text.isEmpty) {
      return;
    }
    final log = SymptomLog(
      id: const Uuid().v4(),
      date: DateTime.now(),
      symptoms: _selected.toList(),
      mood: _mood,
      note: _noteController.text.trim(),
    );
    await ref.read(symptomLogsProvider.notifier).add(log);
    if (!mounted) return;
    setState(() {
      _selected.clear();
      _mood = 0;
      _noteController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(symptomLogsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Symptoms & Mood')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('How are you feeling?',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_moods.length, (i) {
              final selected = _mood == i + 1;
              return GestureDetector(
                onTap: () => setState(() => _mood = i + 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(_moods[i],
                      style: TextStyle(fontSize: selected ? 36 : 30)),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          const Text('Symptoms',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonSymptoms.map((s) {
              final selected = _selected.contains(s);
              return FilterChip(
                label: Text(s),
                selected: selected,
                onSelected: (v) => setState(() {
                  if (v) {
                    _selected.add(s);
                  } else {
                    _selected.remove(s);
                  }
                }),
                selectedColor: AppColors.primary.withValues(alpha: 0.18),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Notes (optional)',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('Save entry')),
          const SizedBox(height: 28),
          if (logs.isNotEmpty) ...[
            const Text('History',
                style:
                    TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 12),
            ...logs.map((log) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Text(
                      log.mood > 0 ? _moods[log.mood - 1] : '📝',
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(log.symptoms.isEmpty
                        ? 'Note'
                        : log.symptoms.join(', ')),
                    subtitle: Text(
                      '${DateFormat.MMMd().add_jm().format(log.date)}'
                      '${log.note.isNotEmpty ? '\n${log.note}' : ''}',
                    ),
                    isThreeLine: log.note.isNotEmpty,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => ref
                          .read(symptomLogsProvider.notifier)
                          .remove(log.id),
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
