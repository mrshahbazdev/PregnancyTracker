import 'package:flutter/foundation.dart';

/// Pre-pregnancy BMI categories used by the IOM (Institute of Medicine)
/// gestational weight-gain guidelines for a single baby.
enum BmiCategory { underweight, normal, overweight, obese }

extension BmiCategoryLabel on BmiCategory {
  String get label => switch (this) {
        BmiCategory.underweight => 'Underweight',
        BmiCategory.normal => 'Normal weight',
        BmiCategory.overweight => 'Overweight',
        BmiCategory.obese => 'Obese',
      };
}

/// A low/high range in kilograms.
@immutable
class GainRange {
  const GainRange(this.lowKg, this.highKg);
  final double lowKg;
  final double highKg;
}

/// How the user's current gain compares to the recommended range for *now*.
enum GainStatus { below, onTrack, above }

extension GainStatusLabel on GainStatus {
  String get label => switch (this) {
        GainStatus.below => 'Below the suggested range',
        GainStatus.onTrack => 'On track',
        GainStatus.above => 'Above the suggested range',
      };
}

/// Body-mass index = weight (kg) / height (m)^2.
double bmi(double weightKg, double heightCm) {
  final m = heightCm / 100.0;
  return weightKg / (m * m);
}

BmiCategory bmiCategory(double bmiValue) {
  if (bmiValue < 18.5) return BmiCategory.underweight;
  if (bmiValue < 25.0) return BmiCategory.normal;
  if (bmiValue < 30.0) return BmiCategory.overweight;
  return BmiCategory.obese;
}

/// Recommended *total* pregnancy weight gain for a singleton, per IOM 2009.
GainRange recommendedTotalGain(BmiCategory cat) => switch (cat) {
      BmiCategory.underweight => const GainRange(12.5, 18.0),
      BmiCategory.normal => const GainRange(11.5, 16.0),
      BmiCategory.overweight => const GainRange(7.0, 11.5),
      BmiCategory.obese => const GainRange(5.0, 9.0),
    };

/// First-trimester gain is small and roughly fixed (≈0.5–2 kg by week 13);
/// the remaining gain accrues at a weekly rate in the 2nd & 3rd trimesters.
const GainRange _t1Gain = GainRange(0.5, 2.0);

/// Recommended weekly gain rate (kg/week) during T2/T3 per IOM 2009.
GainRange _weeklyRate(BmiCategory cat) => switch (cat) {
      BmiCategory.underweight => const GainRange(0.44, 0.58),
      BmiCategory.normal => const GainRange(0.35, 0.50),
      BmiCategory.overweight => const GainRange(0.23, 0.33),
      BmiCategory.obese => const GainRange(0.17, 0.27),
    };

/// Suggested cumulative gain range by [week] (0–40) for the given category.
GainRange recommendedGainByWeek(BmiCategory cat, int week) {
  final w = week.clamp(0, 40);
  if (w <= 13) {
    final f = w / 13.0;
    return GainRange(_t1Gain.lowKg * f, _t1Gain.highKg * f);
  }
  final extraWeeks = w - 13;
  final rate = _weeklyRate(cat);
  return GainRange(
    _t1Gain.lowKg + rate.lowKg * extraWeeks,
    _t1Gain.highKg + rate.highKg * extraWeeks,
  );
}

/// Compare an actual [gainKg] against the recommended range for a week.
GainStatus gainStatus(GainRange recommended, double gainKg) {
  if (gainKg < recommended.lowKg) return GainStatus.below;
  if (gainKg > recommended.highKg) return GainStatus.above;
  return GainStatus.onTrack;
}
