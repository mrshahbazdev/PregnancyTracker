import 'package:flutter_test/flutter_test.dart';
import 'package:pregnancy_tracker/core/baby_data.dart';
import 'package:pregnancy_tracker/models/pregnancy_profile.dart';

void main() {
  group('PregnancyProfile gestational math', () {
    test('due date today means ~40 weeks', () {
      final now = DateTime(2026, 1, 1);
      final profile = PregnancyProfile(
        name: 'Test',
        dueDate: now,
        method: DueDateMethod.dueDate,
      );
      expect(profile.currentWeek(now), 40);
      expect(profile.daysRemaining(now), 0);
      expect(profile.progress(now), closeTo(1.0, 0.001));
    });

    test('LMP-based start means week 0 at conception window', () {
      final lmp = DateTime(2026, 1, 1);
      final dueDate = lmp.add(const Duration(days: 280));
      final profile = PregnancyProfile(
        name: 'Test',
        dueDate: dueDate,
        method: DueDateMethod.lastPeriod,
      );
      expect(profile.currentWeek(lmp), 0);
      // 20 weeks (140 days) later should be week 20.
      final midway = lmp.add(const Duration(days: 140));
      expect(profile.currentWeek(midway), 20);
      expect(profile.trimester(midway), '2nd trimester');
    });

    test('week is clamped between 0 and 40', () {
      final dueDate = DateTime(2026, 6, 1);
      final profile = PregnancyProfile(
        name: 'Test',
        dueDate: dueDate,
        method: DueDateMethod.dueDate,
      );
      final wayBefore = dueDate.subtract(const Duration(days: 400));
      final wayAfter = dueDate.add(const Duration(days: 30));
      expect(profile.currentWeek(wayBefore), 0);
      expect(profile.currentWeek(wayAfter), 40);
    });
  });

  group('Baby data', () {
    test('every week 4-40 has development info', () {
      for (var w = 4; w <= 40; w++) {
        final info = weekInfoFor(w);
        expect(info.headline, isNotEmpty);
        expect(info.detail, isNotEmpty);
        expect(info.sizeComparison, isNotEmpty);
      }
    });

    test('weekInfoFor clamps out-of-range weeks', () {
      expect(weekInfoFor(2).week, 4);
      expect(weekInfoFor(99).week, 40);
    });
  });
}
