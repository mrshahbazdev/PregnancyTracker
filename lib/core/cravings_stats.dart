import 'package:flutter/foundation.dart';

import '../models/log_entry.dart';

/// Aggregate counts over a set of [CravingEntry]s.
@immutable
class CravingsSummary {
  const CravingsSummary({
    required this.cravings,
    required this.aversions,
    required this.topItems,
  });

  final int cravings;
  final int aversions;

  /// Most-logged item names (any kind), most frequent first.
  final List<String> topItems;

  int get total => cravings + aversions;
}

/// Normalize an item name for grouping (case-insensitive, trimmed).
String _key(String item) => item.trim().toLowerCase();

CravingsSummary cravingsSummary(Iterable<CravingEntry> entries,
    {int topN = 3}) {
  var cravings = 0;
  var aversions = 0;
  final counts = <String, int>{};
  final display = <String, String>{};

  for (final e in entries) {
    if (e.kind == CravingKind.craving) {
      cravings++;
    } else {
      aversions++;
    }
    final k = _key(e.item);
    if (k.isEmpty) continue;
    counts[k] = (counts[k] ?? 0) + 1;
    display.putIfAbsent(k, () => e.item.trim());
  }

  final sorted = counts.keys.toList()
    ..sort((a, b) {
      final byCount = counts[b]!.compareTo(counts[a]!);
      return byCount != 0 ? byCount : a.compareTo(b);
    });

  return CravingsSummary(
    cravings: cravings,
    aversions: aversions,
    topItems: [for (final k in sorted.take(topN)) display[k]!],
  );
}
