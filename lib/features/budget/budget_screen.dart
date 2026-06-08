import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/budget.dart';
import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';

String _money(double v) => v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2);

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(budgetProvider);
    final summary = summarize(items);
    final byCat = summarizeByCategory(items);

    return Scaffold(
      appBar: AppBar(title: const Text('Baby Budget')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add expense'),
      ),
      body: items.isEmpty
          ? const _EmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              children: [
                _SummaryCard(summary: summary),
                const SizedBox(height: 20),
                for (final entry in byCat.entries) ...[
                  _CategoryHeader(
                      category: entry.key, summary: entry.value),
                  ...items
                      .where((i) => i.category == entry.key)
                      .map((i) => _BudgetTile(
                            item: i,
                            onTogglePaid: () => ref
                                .read(budgetProvider.notifier)
                                .update(i.copyWith(paid: !i.paid)),
                            onEdit: () =>
                                _openEditor(context, ref, existing: i),
                            onDelete: () => ref
                                .read(budgetProvider.notifier)
                                .remove(i.id),
                          )),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    BudgetItem? existing,
  }) async {
    final result = await showModalBottomSheet<BudgetItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BudgetEditor(existing: existing),
    );
    if (result == null) return;
    final notifier = ref.read(budgetProvider.notifier);
    if (existing == null) {
      await notifier.add(result);
    } else {
      await notifier.update(result);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});
  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final remainingColor =
        summary.overBudget ? AppColors.primaryDark : Colors.green.shade600;
    return Card(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stat('Budget', _money(summary.budgeted), AppColors.textDark),
                _stat('Spent', _money(summary.spent), AppColors.primary),
                _stat(
                    summary.overBudget ? 'Over' : 'Left',
                    _money(summary.remaining.abs()),
                    remainingColor),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: summary.progress,
                minHeight: 10,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                color: summary.overBudget
                    ? AppColors.primaryDark
                    : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 20, color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted)),
        ],
      );
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category, required this.summary});
  final BudgetCategory category;
  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(category.label,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          Text('${_money(summary.spent)} / ${_money(summary.budgeted)}',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({
    required this.item,
    required this.onTogglePaid,
    required this.onEdit,
    required this.onDelete,
  });

  final BudgetItem item;
  final VoidCallback onTogglePaid;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            item.paid
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: item.paid ? Colors.green.shade600 : AppColors.textMuted,
          ),
          onPressed: onTogglePaid,
        ),
        title: Text(item.title,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
            'Spent ${_money(item.spent)} of ${_money(item.budgeted)}'
            '${item.paid ? ' · Paid' : ''}',
            style: const TextStyle(fontSize: 12)),
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

class _BudgetEditor extends StatefulWidget {
  const _BudgetEditor({this.existing});
  final BudgetItem? existing;

  @override
  State<_BudgetEditor> createState() => _BudgetEditorState();
}

class _BudgetEditorState extends State<_BudgetEditor> {
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _budgeted = TextEditingController(
      text: widget.existing == null ? '' : _money(widget.existing!.budgeted));
  late final TextEditingController _spent = TextEditingController(
      text: widget.existing == null ? '' : _money(widget.existing!.spent));
  late BudgetCategory _category =
      widget.existing?.category ?? BudgetCategory.gear;
  late bool _paid = widget.existing?.paid ?? false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _budgeted.dispose();
    _spent.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim();
    final budgeted = double.tryParse(_budgeted.text.trim());
    final spent = _spent.text.trim().isEmpty
        ? 0.0
        : double.tryParse(_spent.text.trim());
    if (title.isEmpty) {
      setState(() => _error = 'Add a name.');
      return;
    }
    if (budgeted == null || budgeted < 0) {
      setState(() => _error = 'Enter a valid budget amount.');
      return;
    }
    if (spent == null || spent < 0) {
      setState(() => _error = 'Enter a valid spent amount.');
      return;
    }
    final existing = widget.existing;
    final item = existing == null
        ? BudgetItem(
            id: const Uuid().v4(),
            title: title,
            category: _category,
            budgeted: budgeted,
            spent: spent,
            paid: _paid,
          )
        : existing.copyWith(
            title: title,
            category: _category,
            budgeted: budgeted,
            spent: spent,
            paid: _paid);
    Navigator.of(context).pop(item);
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
            Text(widget.existing == null ? 'New expense' : 'Edit expense',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Crib',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _budgeted,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(labelText: 'Budget'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _spent,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(labelText: 'Spent'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in BudgetCategory.values)
                  ChoiceChip(
                    label: Text(c.label),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Paid'),
              value: _paid,
              onChanged: (v) => setState(() => _paid = v),
            ),
            if (_error != null) ...[
              const SizedBox(height: 6),
              Text(_error!,
                  style:
                      TextStyle(color: AppColors.primaryDark, fontSize: 13)),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save expense'),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.savings_rounded,
                size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('Plan your baby budget',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Add expenses by category and track budgeted vs actual spend.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
