import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/growth_stats.dart';
import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';

const _uuid = Uuid();

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(growthProvider);
    final summary = growthSummary(entries);

    return Scaffold(
      appBar: AppBar(title: const Text('Baby Growth')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.straighten_rounded,
                        size: 64,
                        color: AppColors.primary.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    const Text('No measurements yet',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap + to log your baby\'s weight, height\n& head circumference.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
              children: [
                _SummaryCard(summary: summary),
                const SizedBox(height: 16),
                _RangesCard(),
                const SizedBox(height: 20),
                const Text('History',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                ...entries.map((e) => _EntryTile(entry: e)),
              ],
            ),
    );
  }

  void _openEditor(BuildContext context, WidgetRef ref, GrowthEntry? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditorSheet(existing: existing, ref: ref),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});
  final GrowthSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text('Growth Summary',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${summary.totalMeasurements} measurement${summary.totalMeasurements == 1 ? '' : 's'}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatChip(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Weight',
                    value: summary.latestWeightKg > 0
                        ? '${summary.latestWeightKg.toStringAsFixed(2)} kg'
                        : '—',
                    gain: summary.weightGainKg,
                    unit: 'kg'),
                const SizedBox(width: 12),
                _StatChip(
                    icon: Icons.straighten_rounded,
                    label: 'Height',
                    value: summary.latestHeightCm > 0
                        ? '${summary.latestHeightCm.toStringAsFixed(1)} cm'
                        : '—',
                    gain: summary.heightGainCm,
                    unit: 'cm'),
                const SizedBox(width: 12),
                _StatChip(
                    icon: Icons.circle_outlined,
                    label: 'Head',
                    value: summary.latestHeadCm > 0
                        ? '${summary.latestHeadCm.toStringAsFixed(1)} cm'
                        : '—',
                    gain: summary.headGainCm,
                    unit: 'cm'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.gain,
    required this.unit,
  });

  final IconData icon;
  final String label;
  final String value;
  final double gain;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted)),
            if (gain != 0)
              Text(
                '${gain > 0 ? '+' : ''}${gain.toStringAsFixed(1)} $unit',
                style: TextStyle(
                  fontSize: 11,
                  color: gain > 0 ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WHO ranges reference card
// ---------------------------------------------------------------------------

class _RangesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppColors.secondary, size: 20),
                SizedBox(width: 8),
                Text('WHO Healthy Ranges',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Approximate healthy ranges for newborns. Always consult your paediatrician.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 36,
                dataRowMinHeight: 32,
                dataRowMaxHeight: 36,
                columnSpacing: 16,
                columns: const [
                  DataColumn(
                      label: Text('Age',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700))),
                  DataColumn(
                      label: Text('Weight (kg)',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700))),
                  DataColumn(
                      label: Text('Height (cm)',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700))),
                  DataColumn(
                      label: Text('Head (cm)',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700))),
                ],
                rows: growthRanges
                    .map((r) => DataRow(cells: [
                          DataCell(Text(r.label,
                              style: const TextStyle(fontSize: 12))),
                          DataCell(Text(
                              '${r.weightMinKg}–${r.weightMaxKg}',
                              style: const TextStyle(fontSize: 12))),
                          DataCell(Text(
                              '${r.heightMinCm.toInt()}–${r.heightMaxCm.toInt()}',
                              style: const TextStyle(fontSize: 12))),
                          DataCell(Text(
                              '${r.headMinCm.toInt()}–${r.headMaxCm.toInt()}',
                              style: const TextStyle(fontSize: 12))),
                        ]))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Entry tile
// ---------------------------------------------------------------------------

class _EntryTile extends ConsumerWidget {
  const _EntryTile({required this.entry});
  final GrowthEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFmt = DateFormat.yMMMd().format(entry.date);
    final parts = <String>[];
    if (entry.weightKg > 0) parts.add('${entry.weightKg.toStringAsFixed(2)} kg');
    if (entry.heightCm > 0) parts.add('${entry.heightCm.toStringAsFixed(1)} cm');
    if (entry.headCm > 0) parts.add('Head ${entry.headCm.toStringAsFixed(1)} cm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.straighten_rounded,
              color: AppColors.primary, size: 20),
        ),
        title: Text(parts.isNotEmpty ? parts.join('  ·  ') : 'No data',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(
          entry.note.isEmpty ? dateFmt : '$dateFmt — ${entry.note}',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (v) {
            if (v == 'edit') {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => _EditorSheet(existing: entry, ref: ref),
              );
            } else {
              ref.read(growthProvider.notifier).remove(entry.id);
            }
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom-sheet editor
// ---------------------------------------------------------------------------

class _EditorSheet extends StatefulWidget {
  const _EditorSheet({this.existing, required this.ref});
  final GrowthEntry? existing;
  final WidgetRef ref;

  @override
  State<_EditorSheet> createState() => _EditorSheetState();
}

class _EditorSheetState extends State<_EditorSheet> {
  late final TextEditingController _weightCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _headCtrl;
  late final TextEditingController _noteCtrl;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _weightCtrl =
        TextEditingController(text: e != null && e.weightKg > 0 ? e.weightKg.toString() : '');
    _heightCtrl =
        TextEditingController(text: e != null && e.heightCm > 0 ? e.heightCm.toString() : '');
    _headCtrl =
        TextEditingController(text: e != null && e.headCm > 0 ? e.headCm.toString() : '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _headCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final w = double.tryParse(_weightCtrl.text.trim()) ?? 0;
    final h = double.tryParse(_heightCtrl.text.trim()) ?? 0;
    final hd = double.tryParse(_headCtrl.text.trim()) ?? 0;
    if (w <= 0 && h <= 0 && hd <= 0) return;

    final entry = GrowthEntry(
      id: widget.existing?.id ?? _uuid.v4(),
      date: _date,
      weightKg: w,
      heightCm: h,
      headCm: hd,
      note: _noteCtrl.text.trim(),
    );

    final notifier = widget.ref.read(growthProvider.notifier);
    if (widget.existing != null) {
      notifier.update(entry);
    } else {
      notifier.add(entry);
    }

    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(isEdit ? 'Edit Measurement' : 'New Measurement',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),

            // Date picker
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(DateFormat.yMMMd().format(_date)),
              onPressed: _pickDate,
            ),
            const SizedBox(height: 16),

            // Weight
            TextField(
              controller: _weightCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                hintText: 'e.g. 3.25',
                prefixIcon: Icon(Icons.monitor_weight_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Height
            TextField(
              controller: _heightCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                hintText: 'e.g. 50.5',
                prefixIcon: Icon(Icons.straighten_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Head
            TextField(
              controller: _headCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Head circumference (cm)',
                hintText: 'e.g. 35.0',
                prefixIcon: Icon(Icons.circle_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Note
            TextField(
              controller: _noteCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: Icon(Icons.notes_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            FilledButton(
              onPressed: _save,
              child: Text(isEdit ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
