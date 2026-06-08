import 'package:flutter/foundation.dart';

import '../models/log_entry.dart';

/// Educational blood-pressure classification (NOT a diagnosis). Ordered by
/// [severity] so the UI can colour/sort consistently.
enum BpSeverity { normal, elevated, high, severe }

@immutable
class BpClass {
  const BpClass(this.severity, this.label, this.advice);

  final BpSeverity severity;
  final String label;
  final String advice;
}

/// Classify a reading using common thresholds. Higher of the two readings wins.
BpClass classifyBp(int systolic, int diastolic) {
  if (systolic >= 160 || diastolic >= 110) {
    return const BpClass(BpSeverity.severe, 'Severe range',
        'This is high — contact your provider or seek care promptly.');
  }
  if (systolic >= 140 || diastolic >= 90) {
    return const BpClass(BpSeverity.high, 'High',
        'Above the typical range — let your provider know.');
  }
  if (systolic >= 130 || diastolic >= 80) {
    return const BpClass(BpSeverity.elevated, 'Elevated',
        'Slightly raised — keep monitoring and mention it at your next visit.');
  }
  return const BpClass(BpSeverity.normal, 'Normal',
      'Within the typical range. Keep up the regular checks.');
}

/// Readings that include a weight, oldest first.
List<Measurement> weightSeries(List<Measurement> items) {
  final list = items.where((m) => m.weightKg != null).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  return list;
}

/// Readings that include both systolic and diastolic, oldest first.
List<Measurement> bpSeries(List<Measurement> items) {
  final list = items
      .where((m) => m.systolic != null && m.diastolic != null)
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  return list;
}

/// Total weight change (kg) from the first to the most recent weight reading,
/// or null if fewer than two weight readings exist. Positive = gain.
double? weightChangeKg(List<Measurement> items) {
  final w = weightSeries(items);
  if (w.length < 2) return null;
  return w.last.weightKg! - w.first.weightKg!;
}

/// Most recent reading that has a weight, or null.
Measurement? latestWeight(List<Measurement> items) {
  final w = weightSeries(items);
  return w.isEmpty ? null : w.last;
}

/// Most recent reading that has a blood pressure, or null.
Measurement? latestBp(List<Measurement> items) {
  final b = bpSeries(items);
  return b.isEmpty ? null : b.last;
}
