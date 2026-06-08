import 'package:flutter/foundation.dart';

import '../models/log_entry.dart';

/// Counts for a single day of newborn care.
@immutable
class BabyCareDaySummary {
  const BabyCareDaySummary({
    required this.feeds,
    required this.wetDiapers,
    required this.dirtyDiapers,
  });

  final int feeds;

  /// Wet diapers (wet + mixed count toward wet).
  final int wetDiapers;

  /// Dirty diapers (dirty + mixed count toward dirty).
  final int dirtyDiapers;
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Summary of [entries] for the calendar day of [day]. Pure for tests.
BabyCareDaySummary babyCareDaySummary(
    Iterable<BabyCareEntry> entries, DateTime day) {
  var feeds = 0;
  var wet = 0;
  var dirty = 0;
  for (final e in entries) {
    if (!_sameDay(e.time, day)) continue;
    if (e.kind == BabyCareKind.feed) {
      feeds++;
    } else {
      if (e.diaperType == DiaperType.wet ||
          e.diaperType == DiaperType.mixed) {
        wet++;
      }
      if (e.diaperType == DiaperType.dirty ||
          e.diaperType == DiaperType.mixed) {
        dirty++;
      }
    }
  }
  return BabyCareDaySummary(
      feeds: feeds, wetDiapers: wet, dirtyDiapers: dirty);
}
