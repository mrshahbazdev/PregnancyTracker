import 'package:flutter/foundation.dart';

import '../models/pregnancy_profile.dart';

/// A notable pregnancy milestone, anchored to a gestational [week].
@immutable
class Milestone {
  const Milestone(this.week, this.title, this.detail);

  final int week;
  final String title;
  final String detail;
}

enum MilestoneStatus { done, current, upcoming }

/// Curated week-by-week milestones across the three trimesters.
const List<Milestone> kMilestones = [
  Milestone(5, 'Pregnancy confirmed',
      'A urine or blood test can confirm pregnancy around now.'),
  Milestone(8, 'First prenatal visit',
      'Typical timing for your first appointment and dating scan.'),
  Milestone(10, 'Heartbeat detectable',
      "Baby's heartbeat can often be heard with a Doppler."),
  Milestone(12, 'End of 1st trimester',
      'Miscarriage risk drops and many share their news.'),
  Milestone(13, 'Second trimester begins',
      'The "honeymoon" trimester — energy often returns.'),
  Milestone(16, 'Possible gender scan',
      "Anatomy can sometimes reveal baby's sex around now."),
  Milestone(20, 'Anomaly scan',
      'The detailed mid-pregnancy ultrasound checks development.'),
  Milestone(24, 'Viability milestone',
      'Babies born now have a real chance with intensive care.'),
  Milestone(26, 'Glucose screening',
      'Gestational diabetes test is usually done around weeks 24–28.'),
  Milestone(28, 'Third trimester begins',
      'Visits become more frequent; count kicks daily.'),
  Milestone(32, 'Growth check',
      "Scans/checks monitor baby's growth and position."),
  Milestone(36, 'Group B strep test',
      'GBS swab is typically taken around now; baby is nearly term.'),
  Milestone(37, 'Full term',
      'Baby is considered early-term — birth any time is healthy.'),
  Milestone(40, 'Due date',
      'Your estimated due date — only ~5% arrive exactly on it!'),
];

/// Date a [week] milestone falls on for the given profile (LMP + week*7 days).
DateTime milestoneDate(PregnancyProfile profile, int week) =>
    profile.lmpDate.add(Duration(days: week * 7));

/// Whole days from [now] until [date]; negative if already passed.
int daysUntil(DateTime now, DateTime date) {
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  return target.difference(today).inDays;
}

/// Status of a milestone relative to the current gestational [currentWeek].
MilestoneStatus milestoneStatus(int currentWeek, int milestoneWeek) {
  if (currentWeek > milestoneWeek) return MilestoneStatus.done;
  if (currentWeek == milestoneWeek) return MilestoneStatus.current;
  return MilestoneStatus.upcoming;
}

/// The next upcoming (or current) milestone, or null if all are done.
Milestone? nextMilestone(int currentWeek) {
  for (final m in kMilestones) {
    if (m.week >= currentWeek) return m;
  }
  return null;
}
