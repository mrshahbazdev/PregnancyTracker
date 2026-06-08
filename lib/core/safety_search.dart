import 'safety_data.dart';

/// Filter [items] by an optional [category] and a free-text [query] (matched
/// against name + note, case-insensitive), returned sorted by name. Pure for
/// tests.
List<SafetyItem> searchSafety(
  List<SafetyItem> items, {
  SafetyCategory? category,
  String query = '',
}) {
  final q = query.trim().toLowerCase();
  final filtered = items.where((it) {
    if (category != null && it.category != category) return false;
    if (q.isEmpty) return true;
    return it.key.contains(q) || it.note.toLowerCase().contains(q);
  }).toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return filtered;
}

/// How many items fall under each rating (handy for a summary header).
Map<SafetyRating, int> ratingBreakdown(List<SafetyItem> items) {
  final map = {
    SafetyRating.safe: 0,
    SafetyRating.caution: 0,
    SafetyRating.avoid: 0,
  };
  for (final it in items) {
    map[it.rating] = (map[it.rating] ?? 0) + 1;
  }
  return map;
}
