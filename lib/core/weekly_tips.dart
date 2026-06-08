import 'package:flutter/foundation.dart';

import 'baby_data.dart';

/// Curated week-by-week guidance for the mother. Educational only — not medical
/// advice. Baby development is reused from [kBabyData]; the self-care, to-do and
/// nutrition tips are chosen from trimester pools (with a few milestone weeks
/// overriding the to-do) so each week feels relevant without a 40-row table.
@immutable
class WeeklyTips {
  const WeeklyTips({
    required this.week,
    required this.trimester,
    required this.babyHeadline,
    required this.babyDetail,
    required this.selfCare,
    required this.toDo,
    required this.nutrition,
  });

  final int week;

  /// 1, 2 or 3.
  final int trimester;
  final String babyHeadline;
  final String babyDetail;
  final String selfCare;
  final String toDo;
  final String nutrition;
}

int trimesterForWeek(int week) {
  if (week <= 13) return 1;
  if (week <= 27) return 2;
  return 3;
}

const Map<int, List<String>> _selfCareByTrimester = {
  1: [
    'Rest when you can — first-trimester fatigue is real and normal.',
    'Eat small, frequent snacks to ease nausea; keep crackers by the bed.',
    'Stay hydrated and avoid strong smells that trigger queasiness.',
    'Be gentle with yourself emotionally; mood swings are common now.',
  ],
  2: [
    'Start gentle exercise like walking or prenatal yoga most days.',
    'Sleep on your side; a pillow between the knees helps comfort.',
    'Moisturise your bump to soothe stretching, itchy skin.',
    'Do daily pelvic-floor (Kegel) exercises to prepare your body.',
  ],
  3: [
    'Rest often and elevate your feet to reduce swelling.',
    'Practise slow breathing and relaxation for labor.',
    'Watch for swelling in face/hands and report it to your provider.',
    'Time naps earlier in the day so night sleep stays easier.',
  ],
};

const Map<int, List<String>> _nutritionByTrimester = {
  1: [
    'Keep taking folic acid — it protects the baby\'s spine and brain.',
    'Choose iron-rich foods (lentils, spinach) with vitamin C to absorb them.',
    'Bland carbs like toast or rice can settle a queasy stomach.',
    'Avoid raw/undercooked meat, unpasteurised dairy and high-mercury fish.',
  ],
  2: [
    'Add calcium (dairy, fortified plant milk) for growing bones.',
    'Include omega-3 (salmon, walnuts) to support brain development.',
    'Fibre and water help prevent constipation as appetite returns.',
    'Protein at each meal supports your baby\'s rapid growth.',
  ],
  3: [
    'Smaller, frequent meals ease heartburn as space gets tight.',
    'Keep up iron and calcium for the final growth and your reserves.',
    'Stay hydrated — it supports amniotic fluid and reduces cramps.',
    'Vitamin-K and healthy fats round out third-trimester nutrition.',
  ],
};

const Map<int, List<String>> _toDoByTrimester = {
  1: [
    'Book your first prenatal (booking) appointment if you haven\'t.',
    'Start or continue a daily prenatal vitamin.',
    'Note questions for your provider in the app as they come up.',
    'Review medicines and foods to avoid during pregnancy.',
  ],
  2: [
    'Use this energetic stretch to plan bigger tasks and travel.',
    'Start thinking about your baby registry and essentials.',
    'Begin light bump photos for your time capsule.',
    'Look into antenatal/childbirth classes in your area.',
  ],
  3: [
    'Pack your hospital bag and keep it by the door.',
    'Install and check the car seat ahead of time.',
    'Finalise your birth plan and share it with your team.',
    'Confirm who to call and your route to the hospital.',
  ],
};

/// Milestone weeks where the to-do is more specific than the trimester pool.
const Map<int, String> _toDoMilestones = {
  8: 'Schedule your dating ultrasound if not already done.',
  12: 'Around now: first-trimester screening / NT scan.',
  16: 'Ask about quad/serum screening if offered.',
  20: 'Book your 20-week anomaly (anatomy) scan.',
  24: 'Glucose screening is usually offered between weeks 24–28.',
  28: 'Ask about Tdap vaccine and anti-D if you are Rh-negative.',
  32: 'Start counting fetal movements and note the pattern daily.',
  36: 'GBS swab is usually done around now; confirm baby\'s position.',
  37: 'Baby is early-term — keep your hospital bag and plan ready.',
  40: 'Discuss next steps with your provider if baby is overdue.',
};

String _pick(List<String> pool, int week) => pool[week % pool.length];

/// Assemble guidance for [week]. Out-of-range weeks are clamped to 4–40 for the
/// baby figures; tips use the natural trimester for [week].
WeeklyTips tipsForWeek(int week) {
  final t = trimesterForWeek(week);
  final info = weekInfoFor(week);
  return WeeklyTips(
    week: week,
    trimester: t,
    babyHeadline: info.headline,
    babyDetail: info.detail,
    selfCare: _pick(_selfCareByTrimester[t]!, week),
    toDo: _toDoMilestones[week] ?? _pick(_toDoByTrimester[t]!, week),
    nutrition: _pick(_nutritionByTrimester[t]!, week),
  );
}
