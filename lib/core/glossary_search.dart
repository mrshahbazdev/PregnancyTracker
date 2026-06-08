import 'glossary_data.dart';

/// Filter [terms] by an optional [category] and a free-text [query] (matched
/// against term + definition, case-insensitive), returned sorted by term.
/// Pure for tests.
List<GlossaryTerm> searchGlossary(
  List<GlossaryTerm> terms, {
  GlossaryCategory? category,
  String query = '',
}) {
  final q = query.trim().toLowerCase();
  final filtered = terms.where((t) {
    if (category != null && t.category != category) return false;
    if (q.isEmpty) return true;
    return t.key.contains(q) || t.definition.toLowerCase().contains(q);
  }).toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return filtered;
}
