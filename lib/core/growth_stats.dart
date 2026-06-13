import 'package:flutter/foundation.dart';

import '../models/log_entry.dart';

/// Summary statistics for baby growth measurements.
@immutable
class GrowthSummary {
  const GrowthSummary({
    required this.totalMeasurements,
    required this.latestWeightKg,
    required this.latestHeightCm,
    required this.latestHeadCm,
    required this.weightGainKg,
    required this.heightGainCm,
    required this.headGainCm,
  });

  final int totalMeasurements;
  final double latestWeightKg;
  final double latestHeightCm;
  final double latestHeadCm;

  /// Difference between first and latest weight (0 if < 2 entries).
  final double weightGainKg;

  /// Difference between first and latest height (0 if < 2 entries).
  final double heightGainCm;

  /// Difference between first and latest head circ (0 if < 2 entries).
  final double headGainCm;
}

/// Computes a [GrowthSummary] from [entries] (expected newest-first). Pure.
GrowthSummary growthSummary(List<GrowthEntry> entries) {
  if (entries.isEmpty) {
    return const GrowthSummary(
      totalMeasurements: 0,
      latestWeightKg: 0,
      latestHeightCm: 0,
      latestHeadCm: 0,
      weightGainKg: 0,
      heightGainCm: 0,
      headGainCm: 0,
    );
  }

  final latest = entries.first;
  final oldest = entries.last;
  final hasGain = entries.length >= 2;

  double gain(double Function(GrowthEntry) pick) =>
      hasGain ? pick(latest) - pick(oldest) : 0;

  return GrowthSummary(
    totalMeasurements: entries.length,
    latestWeightKg: latest.weightKg,
    latestHeightCm: latest.heightCm,
    latestHeadCm: latest.headCm,
    weightGainKg: gain((e) => e.weightKg),
    heightGainCm: gain((e) => e.heightCm),
    headGainCm: gain((e) => e.headCm),
  );
}

/// WHO-approximate healthy ranges for newborns (0–12 months).
@immutable
class GrowthRange {
  const GrowthRange({
    required this.label,
    required this.weightMinKg,
    required this.weightMaxKg,
    required this.heightMinCm,
    required this.heightMaxCm,
    required this.headMinCm,
    required this.headMaxCm,
  });

  final String label;
  final double weightMinKg;
  final double weightMaxKg;
  final double heightMinCm;
  final double heightMaxCm;
  final double headMinCm;
  final double headMaxCm;
}

/// Simplified WHO-approximate ranges by age bracket.
const growthRanges = <GrowthRange>[
  GrowthRange(
    label: 'Birth',
    weightMinKg: 2.5,
    weightMaxKg: 4.5,
    heightMinCm: 46,
    heightMaxCm: 54,
    headMinCm: 33,
    headMaxCm: 37,
  ),
  GrowthRange(
    label: '1 month',
    weightMinKg: 3.2,
    weightMaxKg: 5.8,
    heightMinCm: 50,
    heightMaxCm: 57,
    headMinCm: 35,
    headMaxCm: 39,
  ),
  GrowthRange(
    label: '3 months',
    weightMinKg: 4.5,
    weightMaxKg: 7.5,
    heightMinCm: 56,
    heightMaxCm: 65,
    headMinCm: 38,
    headMaxCm: 42,
  ),
  GrowthRange(
    label: '6 months',
    weightMinKg: 6.0,
    weightMaxKg: 9.5,
    heightMinCm: 62,
    heightMaxCm: 72,
    headMinCm: 41,
    headMaxCm: 45,
  ),
  GrowthRange(
    label: '9 months',
    weightMinKg: 7.0,
    weightMaxKg: 10.5,
    heightMinCm: 67,
    heightMaxCm: 76,
    headMinCm: 43,
    headMaxCm: 47,
  ),
  GrowthRange(
    label: '12 months',
    weightMinKg: 7.5,
    weightMaxKg: 12.0,
    heightMinCm: 70,
    heightMaxCm: 81,
    headMinCm: 44,
    headMaxCm: 48,
  ),
];
