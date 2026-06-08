import 'package:flutter_test/flutter_test.dart';
import 'package:pregnancy_tracker/core/baby_data.dart';
import 'package:pregnancy_tracker/core/birth_plan_data.dart';
import 'package:pregnancy_tracker/core/checklist_data.dart';
import 'package:pregnancy_tracker/core/wellness.dart';
import 'package:pregnancy_tracker/core/weekly_tips.dart';
import 'package:pregnancy_tracker/features/insights/movement_insights.dart';
import 'package:pregnancy_tracker/models/log_entry.dart';
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

  group('MovementInsights', () {
    final now = DateTime(2026, 3, 10, 12);

    KickSession session(DateTime start, int kicks, {int seconds = 600}) =>
        KickSession(
          id: start.toIso8601String(),
          start: start,
          durationSeconds: seconds,
          kicks: kicks,
        );

    test('no sessions -> learning', () {
      final insights = MovementInsights.from([], now);
      expect(insights.status, MovementStatus.learning);
      expect(insights.totalSessions, 0);
    });

    test('fewer than minBaseline past days -> learning', () {
      final sessions = [
        session(now.subtract(const Duration(days: 1)), 10),
        session(now.subtract(const Duration(days: 2)), 12),
      ];
      final insights = MovementInsights.from(sessions, now);
      expect(insights.status, MovementStatus.learning);
      expect(insights.baselineSessions, 2);
    });

    test('baseline established, today consistent -> normal', () {
      final sessions = [
        session(now.subtract(const Duration(days: 1)), 10),
        session(now.subtract(const Duration(days: 2)), 10),
        session(now.subtract(const Duration(days: 3)), 10),
        session(now.add(const Duration(hours: -1)), 10), // today
      ];
      final insights = MovementInsights.from(sessions, now);
      expect(insights.status, MovementStatus.normal);
      expect(insights.averageKicks, closeTo(10, 0.001));
      expect(insights.todayBestKicks, 10);
      expect(insights.averageMinutesToTen, closeTo(10, 0.001));
    });

    test('today far below baseline -> watch', () {
      final sessions = [
        session(now.subtract(const Duration(days: 1)), 12),
        session(now.subtract(const Duration(days: 2)), 12),
        session(now.subtract(const Duration(days: 3)), 12),
        session(now.add(const Duration(hours: -1)), 3), // today, low
      ];
      final insights = MovementInsights.from(sessions, now);
      expect(insights.status, MovementStatus.watch);
      expect(insights.todayBestKicks, 3);
    });

    test('baseline established but nothing logged today -> normal nudge', () {
      final sessions = [
        session(now.subtract(const Duration(days: 1)), 10),
        session(now.subtract(const Duration(days: 2)), 10),
        session(now.subtract(const Duration(days: 3)), 10),
      ];
      final insights = MovementInsights.from(sessions, now);
      expect(insights.status, MovementStatus.normal);
      expect(insights.todayBestKicks, isNull);
    });
  });

  group('Checklists', () {
    test('hospital bag and to-do have unique non-empty preset ids', () {
      for (final kind in [ChecklistKind.hospitalBag, ChecklistKind.todo]) {
        final items = defaultChecklist(kind);
        expect(items, isNotEmpty);
        final ids = items.map((e) => e.id).toSet();
        expect(ids.length, items.length, reason: 'duplicate ids in $kind');
        for (final item in items) {
          expect(item.label, isNotEmpty);
          expect(item.category, isNotEmpty);
          expect(item.done, isFalse);
        }
      }
    });

    test('unknown checklist kind returns empty', () {
      expect(defaultChecklist('nope'), isEmpty);
    });

    test('ChecklistItem.copyWith toggles done only', () {
      const item = ChecklistItem(
          id: 'x', label: 'Item', category: 'Mom', custom: true);
      final toggled = item.copyWith(done: true);
      expect(toggled.done, isTrue);
      expect(toggled.id, item.id);
      expect(toggled.label, item.label);
      expect(toggled.category, item.category);
      expect(toggled.custom, isTrue);
    });

    test('ChecklistItem serializes round-trip', () {
      const item = ChecklistItem(
          id: 'x', label: 'Item', category: 'Baby', done: true, custom: true);
      final restored = ChecklistItem.fromJson(item.toJson());
      expect(restored.id, item.id);
      expect(restored.label, item.label);
      expect(restored.category, item.category);
      expect(restored.done, item.done);
      expect(restored.custom, item.custom);
    });
  });

  group('Birth plan', () {
    test('question ids are unique and options non-empty', () {
      final ids = kBirthPlanQuestions.map((q) => q.id).toSet();
      expect(ids.length, kBirthPlanQuestions.length);
      for (final q in kBirthPlanQuestions) {
        expect(q.prompt, isNotEmpty);
        expect(q.section, isNotEmpty);
        expect(q.options, isNotEmpty);
      }
    });

    test('answered count and JSON round-trip', () {
      var plan = const BirthPlan();
      expect(birthPlanAnsweredCount(plan), 0);
      plan = plan.setAnswer('pain_approach', 'Epidural').withNotes('No peanuts');
      expect(birthPlanAnsweredCount(plan), 1);
      expect(plan.answers['pain_approach'], 'Epidural');

      final restored = BirthPlan.fromJson(plan.toJson());
      expect(restored.answers, plan.answers);
      expect(restored.notes, 'No peanuts');
    });

    test('buildBirthPlanText includes set answers and notes only', () {
      final plan = const BirthPlan()
          .setAnswer('pain_approach', 'Epidural')
          .withNotes('Dim lights please');
      final text = buildBirthPlanText(plan);
      expect(text, contains('Pain management'));
      expect(text, contains('Preferred pain relief: Epidural'));
      expect(text, contains('Dim lights please'));
      // Unanswered sections are omitted.
      expect(text, isNot(contains('Labor environment')));
    });

    test('empty plan produces no section headers', () {
      final text = buildBirthPlanText(const BirthPlan());
      expect(text.trim(), 'My Birth Plan');
    });
  });

  group('Daily wellness', () {
    test('dateKey is zero-padded yyyy-MM-dd', () {
      expect(wellnessDateKey(DateTime(2026, 6, 3)), '2026-06-03');
      expect(wellnessDateKey(DateTime(2026, 12, 25)), '2026-12-25');
    });

    test('WellnessDay hasActivity and copyWith', () {
      const empty = WellnessDay(dateKey: '2026-06-06');
      expect(empty.hasActivity, isFalse);
      expect(empty.copyWith(water: 1).hasActivity, isTrue);
      expect(empty.copyWith(vitamin: true).hasActivity, isTrue);
      expect(empty.copyWith(mood: 3).hasActivity, isTrue);
      final updated = empty.copyWith(water: 2);
      expect(updated.dateKey, empty.dateKey);
      expect(updated.water, 2);
    });

    test('WellnessDay JSON round-trip', () {
      const day =
          WellnessDay(dateKey: '2026-06-06', water: 5, vitamin: true, mood: 4);
      final restored = WellnessDay.fromJson(day.toJson());
      expect(restored.dateKey, day.dateKey);
      expect(restored.water, 5);
      expect(restored.vitamin, isTrue);
      expect(restored.mood, 4);
    });

    test('streak counts consecutive active days ending today', () {
      final today = DateTime(2026, 6, 6);
      String key(int back) =>
          wellnessDateKey(today.subtract(Duration(days: back)));
      final days = [
        WellnessDay(dateKey: key(0), water: 3),
        WellnessDay(dateKey: key(1), vitamin: true),
        WellnessDay(dateKey: key(2), mood: 4),
        // gap at day 3
        WellnessDay(dateKey: key(4), water: 1),
      ];
      expect(wellnessStreak(days, today), 3);
    });

    test('streak still holds when today not yet logged', () {
      final today = DateTime(2026, 6, 6);
      String key(int back) =>
          wellnessDateKey(today.subtract(Duration(days: back)));
      final days = [
        WellnessDay(dateKey: key(1), vitamin: true),
        WellnessDay(dateKey: key(2), water: 2),
      ];
      expect(wellnessStreak(days, today), 2);
    });

    test('empty log has zero streak; inactive entries do not count', () {
      expect(wellnessStreak(const [], DateTime(2026, 6, 6)), 0);
      final days = [
        WellnessDay(dateKey: wellnessDateKey(DateTime(2026, 6, 6))),
      ];
      expect(wellnessStreak(days, DateTime(2026, 6, 6)), 0);
    });
  });

  group('Appointment', () {
    test('serializes round-trip', () {
      final appt = Appointment(
        id: 'a1',
        dateTime: DateTime(2026, 5, 1, 9, 30),
        title: 'Anomaly scan',
        location: 'City Hospital',
        notes: 'Bring records',
      );
      final restored = Appointment.fromJson(appt.toJson());
      expect(restored.id, appt.id);
      expect(restored.dateTime, appt.dateTime);
      expect(restored.title, appt.title);
      expect(restored.location, appt.location);
      expect(restored.notes, appt.notes);
    });
  });

  group('Weekly tips', () {
    test('trimester boundaries', () {
      expect(trimesterForWeek(1), 1);
      expect(trimesterForWeek(13), 1);
      expect(trimesterForWeek(14), 2);
      expect(trimesterForWeek(27), 2);
      expect(trimesterForWeek(28), 3);
      expect(trimesterForWeek(40), 3);
    });

    test('tipsForWeek returns non-empty guidance and matching week', () {
      for (final w in [4, 8, 20, 28, 40]) {
        final t = tipsForWeek(w);
        expect(t.week, w);
        expect(t.babyHeadline, isNotEmpty);
        expect(t.babyDetail, isNotEmpty);
        expect(t.selfCare, isNotEmpty);
        expect(t.toDo, isNotEmpty);
        expect(t.nutrition, isNotEmpty);
      }
    });

    test('milestone weeks override the generic to-do', () {
      expect(tipsForWeek(20).toDo, contains('anomaly'));
      expect(tipsForWeek(24).toDo, contains('Glucose'));
      expect(tipsForWeek(36).toDo, contains('GBS'));
    });

    test('baby development matches the week data', () {
      final t = tipsForWeek(12);
      expect(t.babyHeadline, weekInfoFor(12).headline);
    });
  });
}
