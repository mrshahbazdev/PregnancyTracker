import 'package:flutter_test/flutter_test.dart';
import 'package:pregnancy_tracker/core/baby_data.dart';
import 'package:pregnancy_tracker/core/birth_plan_data.dart';
import 'package:pregnancy_tracker/core/checklist_data.dart';
import 'package:pregnancy_tracker/core/wellness.dart';
import 'package:pregnancy_tracker/core/weekly_tips.dart';
import 'package:pregnancy_tracker/core/baby_names_data.dart';
import 'package:pregnancy_tracker/core/health_trends.dart';
import 'package:pregnancy_tracker/core/contractions.dart';
import 'package:pregnancy_tracker/core/symptom_trends.dart';
import 'package:pregnancy_tracker/core/kick_trends.dart';
import 'package:pregnancy_tracker/core/breathing.dart';
import 'package:pregnancy_tracker/core/safety_data.dart';
import 'package:pregnancy_tracker/core/safety_search.dart';
import 'package:pregnancy_tracker/core/weight_goal.dart';
import 'package:pregnancy_tracker/core/contacts.dart';
import 'package:pregnancy_tracker/core/milestones.dart';
import 'package:pregnancy_tracker/core/budget.dart';
import 'package:pregnancy_tracker/core/sleep_stats.dart';
import 'package:pregnancy_tracker/features/insights/movement_insights.dart';
import 'package:pregnancy_tracker/models/log_entry.dart';
import 'package:pregnancy_tracker/models/pregnancy_profile.dart';
import 'package:pregnancy_tracker/state/app_state.dart';

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

  group('Baby names', () {
    test('key is case-insensitive and trimmed', () {
      const a = BabyName(name: '  Aria ', gender: 'girl');
      const b = BabyName(name: 'aria', gender: 'unisex');
      expect(a.key, b.key);
    });

    test('curated list has valid genders and unique keys', () {
      final keys = <String>{};
      for (final n in kBabyNames) {
        expect(kNameGenders.contains(n.gender), isTrue,
            reason: '${n.name} has gender ${n.gender}');
        expect(keys.add(n.key), isTrue, reason: 'duplicate ${n.name}');
      }
    });

    test('custom BabyName JSON round-trip', () {
      const n = BabyName(
        name: 'Zayn',
        gender: 'boy',
        origin: 'Arabic',
        meaning: 'Beauty, grace',
        isCustom: true,
      );
      final r = BabyName.fromJson(n.toJson());
      expect(r.name, n.name);
      expect(r.gender, n.gender);
      expect(r.origin, n.origin);
      expect(r.meaning, n.meaning);
      expect(r.isCustom, isTrue);
    });

    test('state combines curated + custom and reads favourites', () {
      const custom = BabyName(name: 'Kiaan', gender: 'boy', isCustom: true);
      final st = BabyNamesState(
        custom: const [custom],
        favorites: {'kiaan', kBabyNames.first.key},
      );
      expect(st.all.length, kBabyNames.length + 1);
      expect(st.isFavorite(custom), isTrue);
      expect(st.isFavorite(kBabyNames.first), isTrue);
      expect(
          st.isFavorite(const BabyName(name: 'Nope', gender: 'girl')), isFalse);
    });
  });

  group('Health trends', () {
    Measurement m(String date, {double? w, int? sys, int? dia}) => Measurement(
          id: date,
          date: DateTime.parse(date),
          weightKg: w,
          systolic: sys,
          diastolic: dia,
        );

    test('classifyBp thresholds', () {
      expect(classifyBp(118, 75).severity, BpSeverity.normal);
      expect(classifyBp(132, 78).severity, BpSeverity.elevated);
      expect(classifyBp(120, 82).severity, BpSeverity.elevated);
      expect(classifyBp(145, 85).severity, BpSeverity.high);
      expect(classifyBp(150, 95).severity, BpSeverity.high);
      expect(classifyBp(162, 100).severity, BpSeverity.severe);
      expect(classifyBp(130, 112).severity, BpSeverity.severe);
    });

    test('series are filtered and sorted oldest-first', () {
      final items = [
        m('2024-03-01', w: 60.0),
        m('2024-02-01', w: 58.0, sys: 118, dia: 76),
        m('2024-02-15', sys: 122, dia: 80),
      ];
      final w = weightSeries(items);
      expect(w.length, 2);
      expect(w.first.date.isBefore(w.last.date), isTrue);

      final b = bpSeries(items);
      expect(b.length, 2);
      expect(b.first.date.isBefore(b.last.date), isTrue);
    });

    test('weightChangeKg and latest helpers', () {
      final items = [
        m('2024-01-01', w: 55.0),
        m('2024-02-01', w: 57.5),
        m('2024-03-01', w: 60.0, sys: 120, dia: 80),
      ];
      expect(weightChangeKg(items), closeTo(5.0, 1e-9));
      expect(latestWeight(items)!.weightKg, 60.0);
      expect(latestBp(items)!.systolic, 120);
    });

    test('weightChangeKg null with fewer than two weights', () {
      expect(weightChangeKg([m('2024-01-01', w: 55.0)]), isNull);
      expect(weightChangeKg([m('2024-01-01', sys: 120, dia: 80)]), isNull);
      expect(latestBp([m('2024-01-01', w: 55.0)]), isNull);
    });
  });

  group('Contractions 5-1-1', () {
    final base = DateTime(2024, 5, 1, 10, 0);

    // Builds [count] contractions [intervalMin] apart, each [durSec] long,
    // ending at the anchor time so the most recent is at `base`.
    List<Contraction> series({
      required int count,
      required int intervalMin,
      required int durSec,
    }) {
      final list = <Contraction>[];
      for (var i = 0; i < count; i++) {
        final start = base.subtract(Duration(minutes: intervalMin * i));
        list.add(Contraction(
          id: '$i',
          start: start,
          end: start.add(Duration(seconds: durSec)),
        ));
      }
      return list;
    }

    test('empty input is safe', () {
      final s = analyzeContractions(const [], now: base);
      expect(s.recentCount, 0);
      expect(s.meets511, isFalse);
    });

    test('regular 5-min / 1-min over an hour meets 5-1-1', () {
      final s = analyzeContractions(
        series(count: 13, intervalMin: 5, durSec: 60),
        now: base,
      );
      expect(s.recentCount, greaterThanOrEqualTo(12));
      expect(s.avgInterval.inSeconds, closeTo(300, 1));
      expect(s.avgDuration.inSeconds, 60);
      expect(s.meets511, isTrue);
    });

    test('too far apart does not meet 5-1-1', () {
      final s = analyzeContractions(
        series(count: 6, intervalMin: 12, durSec: 60),
        now: base,
      );
      // 12-min spacing pushes most out of the 1-hour window.
      expect(s.meets511, isFalse);
    });

    test('short contractions do not meet 5-1-1', () {
      final s = analyzeContractions(
        series(count: 13, intervalMin: 5, durSec: 30),
        now: base,
      );
      expect(s.meets511, isFalse);
    });

    test('only a few contractions does not meet 5-1-1', () {
      final s = analyzeContractions(
        series(count: 3, intervalMin: 5, durSec: 60),
        now: base,
      );
      expect(s.recentCount, 3);
      expect(s.meets511, isFalse);
    });

    test('window excludes contractions older than an hour', () {
      final old = Contraction(
        id: 'old',
        start: base.subtract(const Duration(hours: 3)),
        end: base.subtract(const Duration(hours: 3)).add(const Duration(seconds: 60)),
      );
      final s = analyzeContractions([
        old,
        ...series(count: 13, intervalMin: 5, durSec: 60),
      ], now: base);
      // The 3-hour-old one is outside the window, so count stays bounded.
      expect(s.recentCount, lessThanOrEqualTo(13));
      expect(s.meets511, isTrue);
    });
  });

  group('Symptom & mood trends', () {
    SymptomLog log(String date,
            {List<String> symptoms = const [], int mood = 0}) =>
        SymptomLog(
          id: date,
          date: DateTime.parse(date),
          symptoms: symptoms,
          mood: mood,
        );

    final logs = [
      log('2024-01-01', symptoms: ['Nausea', 'Fatigue'], mood: 2),
      log('2024-01-02', symptoms: ['Nausea'], mood: 4),
      log('2024-01-02', symptoms: ['Fatigue', 'Headache'], mood: 0),
      log('2024-01-03', symptoms: ['Nausea'], mood: 3),
    ];

    test('symptomCounts ranks by frequency then name', () {
      final counts = symptomCounts(logs);
      expect(counts.first.name, 'Nausea');
      expect(counts.first.count, 3);
      expect(counts[1].name, 'Fatigue');
      expect(counts[1].count, 2);
      expect(counts.last.name, 'Headache');
      expect(counts.last.count, 1);
    });

    test('topSymptoms caps the list', () {
      expect(topSymptoms(logs, n: 2).length, 2);
      expect(topSymptoms(logs, n: 2).first.name, 'Nausea');
    });

    test('averageMood ignores unset moods', () {
      // moods 2, 4, 3 -> avg 3.0 (the mood:0 entry is skipped)
      expect(averageMood(logs), closeTo(3.0, 0.0001));
      expect(averageMood([log('2024-01-01')]), isNull);
    });

    test('moodLogs returns only mood-set, oldest first', () {
      final m = moodLogs(logs);
      expect(m.length, 3);
      expect(m.first.date.isBefore(m.last.date), isTrue);
      expect(m.every((l) => l.mood > 0), isTrue);
    });

    test('loggedDays counts distinct calendar days', () {
      expect(loggedDays(logs), 3);
      expect(loggedDays(const []), 0);
    });
  });

  group('Kick trends', () {
    KickSession ks(String date, {required int kicks, required int secs}) =>
        KickSession(
          id: date,
          start: DateTime.parse(date),
          durationSeconds: secs,
          kicks: kicks,
        );

    test('empty input yields safe defaults', () {
      final t = KickTrends.from(const []);
      expect(t.totalSessions, 0);
      expect(t.averageKicks, 0);
      expect(t.averageMinutesToTen, isNull);
      expect(t.bestKicks, 0);
      expect(t.lastSession, isNull);
    });

    test('aggregates count, average, best & last session', () {
      final sessions = [
        ks('2024-01-01T09:00:00', kicks: 10, secs: 600), // 10 min to 10
        ks('2024-01-02T09:00:00', kicks: 12, secs: 1200), // 20 min to 10
        ks('2024-01-03T09:00:00', kicks: 6, secs: 1800), // never reached 10
      ];
      final t = KickTrends.from(sessions);
      expect(t.totalSessions, 3);
      expect(t.averageKicks, closeTo((10 + 12 + 6) / 3, 0.0001));
      expect(t.bestKicks, 12);
      // Average over the two sessions that reached 10: (10 + 20) / 2 = 15 min.
      expect(t.averageMinutesToTen, closeTo(15.0, 0.0001));
      expect(t.lastSession!.id, '2024-01-03T09:00:00');
    });

    test('averageMinutesToTen null when no session reaches 10', () {
      final t = KickTrends.from([ks('2024-01-01', kicks: 5, secs: 600)]);
      expect(t.averageMinutesToTen, isNull);
    });

    test('kickSeries sorts oldest-first', () {
      final s = kickSeries([
        ks('2024-01-03', kicks: 8, secs: 100),
        ks('2024-01-01', kicks: 8, secs: 100),
        ks('2024-01-02', kicks: 8, secs: 100),
      ]);
      expect(s.first.id, '2024-01-01');
      expect(s.last.id, '2024-01-03');
    });

    test('minutesToTen requires 10 kicks and a duration', () {
      expect(minutesToTen(ks('2024-01-01', kicks: 10, secs: 300)),
          closeTo(5.0, 0.0001));
      expect(minutesToTen(ks('2024-01-01', kicks: 9, secs: 300)), isNull);
      expect(minutesToTen(ks('2024-01-01', kicks: 10, secs: 0)), isNull);
    });
  });

  group('Breathing patterns', () {
    const box = BreathingPattern(
      id: 'box',
      name: 'Box',
      description: '',
      cycles: 2,
      phases: [
        BreathPhase(BreathPhaseType.inhale, 4),
        BreathPhase(BreathPhaseType.hold, 4),
        BreathPhase(BreathPhaseType.exhale, 4),
        BreathPhase(BreathPhaseType.holdAfterExhale, 4),
      ],
    );

    test('cycle and total seconds', () {
      expect(box.cycleSeconds, 16);
      expect(box.totalSeconds, 32);
    });

    test('positionAt resolves phase within first cycle', () {
      final p0 = positionAt(box, 0);
      expect(p0.phase.type, BreathPhaseType.inhale);
      expect(p0.secondsIntoPhase, 0);
      expect(p0.secondsRemainingInPhase, 4);
      expect(p0.cycleIndex, 0);
      expect(p0.finished, isFalse);

      final p5 = positionAt(box, 5); // 1s into the hold phase
      expect(p5.phase.type, BreathPhaseType.hold);
      expect(p5.secondsIntoPhase, 1);
      expect(p5.secondsRemainingInPhase, 3);
    });

    test('positionAt advances cycle index', () {
      final p = positionAt(box, 16); // start of 2nd cycle
      expect(p.cycleIndex, 1);
      expect(p.phase.type, BreathPhaseType.inhale);
    });

    test('positionAt marks finished at/after total', () {
      expect(positionAt(box, 32).finished, isTrue);
      expect(positionAt(box, 99).finished, isTrue);
      expect(positionAt(box, 31).finished, isFalse);
    });

    test('curated patterns include kegel and labor', () {
      final ids = kBreathingPatterns.map((p) => p.id).toSet();
      expect(ids.containsAll({'box', '478', 'labor', 'kegel'}), isTrue);
    });
  });

  group('Safety checker', () {
    const items = [
      SafetyItem(
          name: 'Cooked salmon',
          category: SafetyCategory.food,
          rating: SafetyRating.safe,
          note: 'Low-mercury fish, omega-3.'),
      SafetyItem(
          name: 'Alcohol',
          category: SafetyCategory.drink,
          rating: SafetyRating.avoid,
          note: 'No safe amount.'),
      SafetyItem(
          name: 'Ibuprofen',
          category: SafetyCategory.medicine,
          rating: SafetyRating.avoid,
          note: 'Avoid, especially third trimester.'),
      SafetyItem(
          name: 'Coffee',
          category: SafetyCategory.drink,
          rating: SafetyRating.caution,
          note: 'Limit caffeine under 200 mg.'),
    ];

    test('empty query returns all, sorted by name', () {
      final r = searchSafety(items);
      expect(r.length, 4);
      expect(r.first.name, 'Alcohol');
      expect(r.last.name, 'Ibuprofen');
    });

    test('category filter narrows results', () {
      final drinks = searchSafety(items, category: SafetyCategory.drink);
      expect(drinks.map((e) => e.name).toSet(), {'Alcohol', 'Coffee'});
    });

    test('query matches name and note, case-insensitive', () {
      expect(searchSafety(items, query: 'SALMON').single.name, 'Cooked salmon');
      // "caffeine" only appears in the note for Coffee.
      expect(searchSafety(items, query: 'caffeine').single.name, 'Coffee');
    });

    test('category + query combine', () {
      final r = searchSafety(items,
          category: SafetyCategory.medicine, query: 'avoid');
      expect(r.single.name, 'Ibuprofen');
    });

    test('ratingBreakdown counts each rating', () {
      final b = ratingBreakdown(items);
      expect(b[SafetyRating.safe], 1);
      expect(b[SafetyRating.caution], 1);
      expect(b[SafetyRating.avoid], 2);
    });

    test('curated list spans all categories', () {
      final cats = kSafetyItems.map((e) => e.category).toSet();
      expect(cats, containsAll(SafetyCategory.values));
      expect(kSafetyItems.length, greaterThan(20));
    });
  });

  group('Journal entry', () {
    final entry = JournalEntry(
      id: 'j1',
      date: DateTime.parse('2024-05-10T08:30:00'),
      title: 'Felt the first kick!',
      body: 'A tiny flutter this morning.',
      week: 18,
      mood: 5,
    );

    test('round-trips through JSON', () {
      final copy = JournalEntry.fromJson(entry.toJson());
      expect(copy.id, entry.id);
      expect(copy.date, entry.date);
      expect(copy.title, entry.title);
      expect(copy.body, entry.body);
      expect(copy.week, 18);
      expect(copy.mood, 5);
    });

    test('defaults week to null and mood to 0 when absent', () {
      final j = JournalEntry.fromJson({
        'id': 'x',
        'date': '2024-01-01T00:00:00',
        'title': 't',
        'body': 'b',
      });
      expect(j.week, isNull);
      expect(j.mood, 0);
    });

    test('copyWith preserves id, date & week but updates fields', () {
      final updated = entry.copyWith(title: 'Edited', mood: 3);
      expect(updated.id, entry.id);
      expect(updated.date, entry.date);
      expect(updated.week, entry.week);
      expect(updated.title, 'Edited');
      expect(updated.mood, 3);
      expect(updated.body, entry.body); // unchanged
    });
  });

  group('Weight-gain goal', () {
    test('computes BMI and classifies categories', () {
      // 60 kg at 165 cm -> ~22.0 (normal)
      expect(bmi(60, 165), closeTo(22.04, 0.05));
      expect(bmiCategory(17.0), BmiCategory.underweight);
      expect(bmiCategory(22.0), BmiCategory.normal);
      expect(bmiCategory(27.0), BmiCategory.overweight);
      expect(bmiCategory(32.0), BmiCategory.obese);
    });

    test('recommends total gain per IOM category', () {
      expect(recommendedTotalGain(BmiCategory.normal).lowKg, 11.5);
      expect(recommendedTotalGain(BmiCategory.normal).highKg, 16.0);
      expect(recommendedTotalGain(BmiCategory.obese).highKg, 9.0);
    });

    test('by-week gain grows with gestational age', () {
      final early = recommendedGainByWeek(BmiCategory.normal, 8);
      final mid = recommendedGainByWeek(BmiCategory.normal, 20);
      final late = recommendedGainByWeek(BmiCategory.normal, 36);
      expect(early.highKg, lessThan(mid.highKg));
      expect(mid.highKg, lessThan(late.highKg));
      // T1 ramp: week 13 is the full first-trimester gain.
      expect(recommendedGainByWeek(BmiCategory.normal, 13).highKg,
          closeTo(2.0, 0.001));
    });

    test('classifies status against the recommended range', () {
      const range = GainRange(4.0, 6.0);
      expect(gainStatus(range, 3.0), GainStatus.below);
      expect(gainStatus(range, 5.0), GainStatus.onTrack);
      expect(gainStatus(range, 7.0), GainStatus.above);
    });

    test('WeightGoalConfig round-trips through JSON', () {
      const c = WeightGoalConfig(prePregnancyKg: 58.5, heightCm: 162);
      final copy = WeightGoalConfig.fromJson(c.toJson());
      expect(copy.prePregnancyKg, 58.5);
      expect(copy.heightCm, 162);
    });
  });

  group('Emergency contacts', () {
    test('sanitizePhone keeps digits and a leading +', () {
      expect(sanitizePhone('+92 (300) 123-4567'), '+923001234567');
      expect(sanitizePhone('0300 123 4567'), '03001234567');
      expect(sanitizePhone('1-800-FLOWERS'), '1800'); // letters dropped
    });

    test('telUri builds a tel: scheme and rejects empty numbers', () {
      final uri = telUri('+92 300 1234567');
      expect(uri, isNotNull);
      expect(uri!.scheme, 'tel');
      expect(uri.path, '+923001234567');
      expect(telUri('   '), isNull);
      expect(telUri('abc'), isNull);
    });

    test('EmergencyContact round-trips and copyWith updates fields', () {
      const c = EmergencyContact(
        id: 'c1',
        name: 'Dr. Ayesha',
        phone: '+923001234567',
        kind: ContactKind.doctor,
        note: 'Maternity ward',
      );
      final copy = EmergencyContact.fromJson(c.toJson());
      expect(copy.name, 'Dr. Ayesha');
      expect(copy.kind, ContactKind.doctor);
      expect(copy.note, 'Maternity ward');

      final updated = c.copyWith(name: 'Dr. A.', kind: ContactKind.hospital);
      expect(updated.id, 'c1');
      expect(updated.name, 'Dr. A.');
      expect(updated.kind, ContactKind.hospital);
      expect(updated.phone, c.phone); // unchanged
    });

    test('unknown kind falls back to other', () {
      final c = EmergencyContact.fromJson({
        'id': 'x',
        'name': 'n',
        'phone': '123',
        'kind': 'spaceship',
      });
      expect(c.kind, ContactKind.other);
      expect(c.note, '');
    });
  });

  group('Milestones', () {
    test('curated list is week-ordered and ends at the due date', () {
      for (var i = 1; i < kMilestones.length; i++) {
        expect(kMilestones[i].week,
            greaterThanOrEqualTo(kMilestones[i - 1].week));
      }
      expect(kMilestones.last.week, 40);
    });

    test('status reflects current gestational week', () {
      expect(milestoneStatus(20, 12), MilestoneStatus.done);
      expect(milestoneStatus(20, 20), MilestoneStatus.current);
      expect(milestoneStatus(20, 28), MilestoneStatus.upcoming);
    });

    test('milestoneDate is LMP + week*7 days', () {
      final profile = PregnancyProfile(
        name: 'A',
        dueDate: DateTime(2025, 1, 1),
        method: DueDateMethod.dueDate,
      );
      final d = milestoneDate(profile, 20);
      expect(d, profile.lmpDate.add(const Duration(days: 140)));
    });

    test('daysUntil ignores the time component', () {
      final now = DateTime(2025, 1, 1, 23, 59);
      expect(daysUntil(now, DateTime(2025, 1, 4, 0, 1)), 3);
      expect(daysUntil(now, DateTime(2024, 12, 30)), -2);
    });

    test('nextMilestone returns the first at/after the current week', () {
      expect(nextMilestone(20)!.week, 20);
      expect(nextMilestone(21)!.week, 24);
      expect(nextMilestone(41), isNull);
    });
  });

  group('Baby budget', () {
    final items = [
      const BudgetItem(
          id: '1',
          title: 'Crib',
          category: BudgetCategory.nursery,
          budgeted: 200,
          spent: 180,
          paid: true),
      const BudgetItem(
          id: '2',
          title: 'Stroller',
          category: BudgetCategory.gear,
          budgeted: 300,
          spent: 350),
      const BudgetItem(
          id: '3',
          title: 'Onesies',
          category: BudgetCategory.clothing,
          budgeted: 50,
          spent: 0),
    ];

    test('summarize totals budgeted and spent', () {
      final s = summarize(items);
      expect(s.budgeted, 550);
      expect(s.spent, 530);
      expect(s.remaining, 20);
      expect(s.overBudget, isFalse);
      expect(s.progress, closeTo(530 / 550, 0.001));
    });

    test('over-budget and zero-budget progress are handled', () {
      final over = summarize([items[1]]); // 350 spent / 300
      expect(over.overBudget, isTrue);
      expect(over.remaining, -50);
      expect(over.progress, 1.0); // clamped

      const empty = BudgetSummary(budgeted: 0, spent: 0);
      expect(empty.progress, 0);
    });

    test('summarizeByCategory only includes used categories', () {
      final byCat = summarizeByCategory(items);
      expect(byCat.keys, containsAll([
        BudgetCategory.nursery,
        BudgetCategory.gear,
        BudgetCategory.clothing,
      ]));
      expect(byCat.containsKey(BudgetCategory.medical), isFalse);
      expect(byCat[BudgetCategory.gear]!.spent, 350);
    });

    test('BudgetItem round-trips and copyWith toggles paid', () {
      final copy = BudgetItem.fromJson(items[0].toJson());
      expect(copy.title, 'Crib');
      expect(copy.category, BudgetCategory.nursery);
      expect(copy.paid, isTrue);

      final toggled = items[1].copyWith(paid: true, spent: 360);
      expect(toggled.paid, isTrue);
      expect(toggled.spent, 360);
      expect(toggled.budgeted, 300); // unchanged
    });
  });

  group('Sleep tracker', () {
    SleepEntry entry(String id, double hours, int quality,
            [SleepSide side = SleepSide.unset]) =>
        SleepEntry(
            id: id,
            date: DateTime(2025, 1, int.parse(id)),
            hours: hours,
            quality: quality,
            side: side);

    test('empty stats are zeroed', () {
      final s = sleepStats(const []);
      expect(s.nights, 0);
      expect(s.avgHours, 0);
      expect(s.avgQuality, 0);
    });

    test('averages hours over all nights, quality over rated nights', () {
      final s = sleepStats([
        entry('1', 8, 4),
        entry('2', 6, 0), // quality unset -> excluded from quality avg
        entry('3', 7, 2),
      ]);
      expect(s.nights, 3);
      expect(s.avgHours, closeTo(7, 0.001)); // (8+6+7)/3
      expect(s.avgQuality, closeTo(3, 0.001)); // (4+2)/2
    });

    test('SleepEntry round-trips and unknown side falls back to unset', () {
      final e = entry('5', 7.5, 5, SleepSide.left);
      final copy = SleepEntry.fromJson(e.toJson());
      expect(copy.hours, 7.5);
      expect(copy.quality, 5);
      expect(copy.side, SleepSide.left);

      final bad = SleepEntry.fromJson({
        'id': 'x',
        'date': DateTime(2025, 1, 1).toIso8601String(),
        'hours': 6,
        'side': 'sideways',
      });
      expect(bad.side, SleepSide.unset);
      expect(bad.quality, 0);
    });
  });
}
