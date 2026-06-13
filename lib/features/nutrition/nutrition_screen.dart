import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/nutrition_data.dart';
import '../../core/theme.dart';
import '../../models/nutrition_entry.dart';
import '../../state/app_state.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(nutritionProvider);
    final waterLogs = ref.watch(waterLogProvider);
    final profile = ref.watch(profileProvider);
    final now = DateTime.now();
    final week = profile?.currentWeek(now) ?? 0;
    final trimester = trimesterFromWeek(week);

    final todayEntries = entries.where((e) =>
        e.date.year == now.year &&
        e.date.month == now.month &&
        e.date.day == now.day).toList();

    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final todayWater = waterLogs
        .where((l) => l.dateKey == todayKey)
        .fold(0, (sum, l) => sum + l.glasses);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nutrition'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Today'),
              Tab(text: 'Nutrients'),
              Tab(text: 'Tips'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openMealEditor(context, ref),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Log Meal'),
        ),
        body: TabBarView(
          children: [
            _TodayTab(
              todayEntries: todayEntries,
              todayWater: todayWater,
              ref: ref,
              onEdit: (e) => _openMealEditor(context, ref, existing: e),
              onDelete: (id) =>
                  ref.read(nutritionProvider.notifier).remove(id),
            ),
            _NutrientsTab(),
            _TipsTab(trimester: trimester),
          ],
        ),
      ),
    );
  }

  Future<void> _openMealEditor(
    BuildContext context,
    WidgetRef ref, {
    NutritionEntry? existing,
  }) async {
    final week = ref.read(profileProvider)?.currentWeek(DateTime.now());
    final result = await showModalBottomSheet<NutritionEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MealEditor(existing: existing, currentWeek: week),
    );
    if (result == null) return;
    final notifier = ref.read(nutritionProvider.notifier);
    if (existing == null) {
      await notifier.add(result);
    } else {
      await notifier.update(result);
    }
  }
}

// ---- Today Tab ----

class _TodayTab extends StatelessWidget {
  const _TodayTab({
    required this.todayEntries,
    required this.todayWater,
    required this.ref,
    required this.onEdit,
    required this.onDelete,
  });

  final List<NutritionEntry> todayEntries;
  final int todayWater;
  final WidgetRef ref;
  final void Function(NutritionEntry) onEdit;
  final void Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      children: [
        _WaterCard(glasses: todayWater, ref: ref, isDark: isDark),
        const SizedBox(height: 16),
        _MealSummaryCard(entries: todayEntries),
        const SizedBox(height: 16),
        if (todayEntries.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.restaurant_menu_rounded,
                      size: 48,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    'No meals logged today',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap "Log Meal" to add your first meal',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...todayEntries.map((e) => _MealTile(
                entry: e,
                onEdit: () => onEdit(e),
                onDelete: () => onDelete(e.id),
              )),
      ],
    );
  }
}

class _WaterCard extends StatelessWidget {
  const _WaterCard({
    required this.glasses,
    required this.ref,
    required this.isDark,
  });

  final int glasses;
  final WidgetRef ref;
  final bool isDark;

  static const int _goal = 10;

  @override
  Widget build(BuildContext context) {
    final progress = (glasses / _goal).clamp(0.0, 1.0);
    return Card(
      color: AppColors.secondary.withValues(alpha: isDark ? 0.18 : 0.10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop_rounded,
                    color: AppColors.secondary, size: 22),
                const SizedBox(width: 8),
                const Text('Water Intake',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(),
                Text('$glasses / $_goal glasses',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: isDark
                    ? AppColors.surfaceDark
                    : AppColors.secondary.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  glasses >= _goal ? Colors.green : AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: glasses > 0
                      ? () => ref
                          .read(waterLogProvider.notifier)
                          .setGlasses(glasses - 1)
                      : null,
                  icon: const Icon(Icons.remove),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        AppColors.secondary.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(width: 16),
                Text('$glasses',
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(width: 16),
                IconButton.filled(
                  onPressed: () => ref
                      .read(waterLogProvider.notifier)
                      .setGlasses(glasses + 1),
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        AppColors.secondary.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MealSummaryCard extends StatelessWidget {
  const _MealSummaryCard({required this.entries});
  final List<NutritionEntry> entries;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mealCounts = <MealType, int>{};
    for (final e in entries) {
      mealCounts[e.mealType] = (mealCounts[e.mealType] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Today's Meals",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: MealType.values.map((type) {
                final count = mealCounts[type] ?? 0;
                final hasEntry = count > 0;
                return Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: hasEntry
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : (isDark
                                ? AppColors.surfaceDark
                                : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(type.icon, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(type.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              hasEntry ? FontWeight.w700 : FontWeight.w500,
                          color: hasEntry
                              ? null
                              : (isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMuted),
                        )),
                    if (hasEntry)
                      Text('$count',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.primary)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  const _MealTile({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final NutritionEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.jm().format(entry.date);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child:
                Text(entry.mealType.icon, style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(entry.mealType.label,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          entry.foods.join(', '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(time,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textMutedDark
                      : AppColors.textMuted,
                )),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Nutrients Tab ----

class _NutrientsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        const Text('Key Pregnancy Nutrients',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(
          'Recommended daily intake during pregnancy',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textMutedDark
                : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        ...kPregnancyNutrients.map((n) => _NutrientCard(nutrient: n)),
      ],
    );
  }
}

class _NutrientCard extends StatelessWidget {
  const _NutrientCard({required this.nutrient});
  final NutrientInfo nutrient;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: nutrient.color.withValues(alpha: isDark ? 0.25 : 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      Icon(nutrient.icon, color: nutrient.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(nutrient.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: nutrient.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${nutrient.dailyAmount} ${nutrient.unit}/day',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: nutrient.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: nutrient.sources
                  .map((s) => Chip(
                        label: Text(s, style: const TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Tips Tab ----

class _TipsTab extends StatelessWidget {
  const _TipsTab({required this.trimester});
  final int trimester;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tip = kTrimesterTips[trimester]!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Card(
          color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.info_rounded,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Showing tips for your ${tip.title}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Recommended Foods',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.green)),
        const SizedBox(height: 10),
        ...tip.foods.map((f) => _TipRow(
              icon: Icons.check_circle_rounded,
              color: Colors.green,
              text: f,
            )),
        const SizedBox(height: 24),
        const Text('Foods to Avoid',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.redAccent)),
        const SizedBox(height: 10),
        ...tip.avoid.map((f) => _TipRow(
              icon: Icons.cancel_rounded,
              color: Colors.redAccent,
              text: f,
            )),
      ],
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

// ---- Meal Editor Bottom Sheet ----

class _MealEditor extends StatefulWidget {
  const _MealEditor({this.existing, this.currentWeek});
  final NutritionEntry? existing;
  final int? currentWeek;

  @override
  State<_MealEditor> createState() => _MealEditorState();
}

class _MealEditorState extends State<_MealEditor> {
  late MealType _mealType;
  late TextEditingController _foodsController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _mealType = widget.existing?.mealType ?? _defaultMealType();
    _foodsController =
        TextEditingController(text: widget.existing?.foods.join(', ') ?? '');
    _noteController =
        TextEditingController(text: widget.existing?.note ?? '');
  }

  MealType _defaultMealType() {
    final hour = DateTime.now().hour;
    if (hour < 11) return MealType.breakfast;
    if (hour < 15) return MealType.lunch;
    if (hour < 20) return MealType.dinner;
    return MealType.snack;
  }

  @override
  void dispose() {
    _foodsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final foods = _foodsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (foods.isEmpty) return;

    final entry = NutritionEntry(
      id: widget.existing?.id ?? const Uuid().v4(),
      date: widget.existing?.date ?? DateTime.now(),
      mealType: _mealType,
      foods: foods,
      note: _noteController.text.trim(),
      week: widget.currentWeek,
    );
    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
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
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.existing == null ? 'Log a Meal' : 'Edit Meal',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            const Text('Meal Type',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MealType.values.map((type) {
                return ChoiceChip(
                  label: Text('${type.icon} ${type.label}'),
                  selected: _mealType == type,
                  onSelected: (_) => setState(() => _mealType = type),
                  selectedColor:
                      AppColors.primary.withValues(alpha: 0.18),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Foods (comma-separated)',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _foodsController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'e.g. Oatmeal, banana, milk',
                filled: true,
                fillColor: isDark
                    ? AppColors.backgroundDark
                    : Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Note (optional)',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Any notes...',
                filled: true,
                fillColor: isDark
                    ? AppColors.backgroundDark
                    : Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: Text(
                    widget.existing == null ? 'Add Meal' : 'Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
