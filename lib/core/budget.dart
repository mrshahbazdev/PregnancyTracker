import 'package:flutter/foundation.dart';

import '../models/log_entry.dart';

/// Aggregate totals for a set of [BudgetItem]s.
@immutable
class BudgetSummary {
  const BudgetSummary({
    required this.budgeted,
    required this.spent,
  });

  final double budgeted;
  final double spent;

  /// Remaining budget; negative means over budget.
  double get remaining => budgeted - spent;

  bool get overBudget => spent > budgeted;

  /// Fraction of the budget spent, clamped to [0, 1] for progress bars.
  double get progress =>
      budgeted <= 0 ? 0 : (spent / budgeted).clamp(0.0, 1.0);
}

BudgetSummary summarize(Iterable<BudgetItem> items) {
  var budgeted = 0.0;
  var spent = 0.0;
  for (final i in items) {
    budgeted += i.budgeted;
    spent += i.spent;
  }
  return BudgetSummary(budgeted: budgeted, spent: spent);
}

/// Per-category summaries, only for categories that have at least one item,
/// ordered by the [BudgetCategory] enum.
Map<BudgetCategory, BudgetSummary> summarizeByCategory(
    Iterable<BudgetItem> items) {
  final result = <BudgetCategory, BudgetSummary>{};
  for (final cat in BudgetCategory.values) {
    final inCat = items.where((i) => i.category == cat);
    if (inCat.isEmpty) continue;
    result[cat] = summarize(inCat);
  }
  return result;
}
