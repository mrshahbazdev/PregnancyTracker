import 'package:flutter/material.dart';

import '../../core/safety_data.dart';
import '../../core/safety_search.dart';
import '../../core/theme.dart';

class SafetyCheckerScreen extends StatefulWidget {
  const SafetyCheckerScreen({super.key});

  @override
  State<SafetyCheckerScreen> createState() => _SafetyCheckerScreenState();
}

class _SafetyCheckerScreenState extends State<SafetyCheckerScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  SafetyCategory? _category;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = searchSafety(kSafetyItems,
        category: _category, query: _query);

    return Scaffold(
      appBar: AppBar(title: const Text('Food & Medicine Safety')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search foods, drinks, medicines…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                _CategoryChip(
                  label: 'All',
                  selected: _category == null,
                  onTap: () => setState(() => _category = null),
                ),
                _CategoryChip(
                  label: 'Food',
                  selected: _category == SafetyCategory.food,
                  onTap: () =>
                      setState(() => _category = SafetyCategory.food),
                ),
                _CategoryChip(
                  label: 'Drink',
                  selected: _category == SafetyCategory.drink,
                  onTap: () =>
                      setState(() => _category = SafetyCategory.drink),
                ),
                _CategoryChip(
                  label: 'Medicine',
                  selected: _category == SafetyCategory.medicine,
                  onTap: () =>
                      setState(() => _category = SafetyCategory.medicine),
                ),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Text('No matches found',
                        style: TextStyle(color: AppColors.textMuted)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: results.length + 1,
                    itemBuilder: (context, i) {
                      if (i == results.length) return const _Disclaimer();
                      return _SafetyCard(item: results[i]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

Color _ratingColor(SafetyRating r) {
  switch (r) {
    case SafetyRating.safe:
      return const Color(0xFF4CAF82);
    case SafetyRating.caution:
      return const Color(0xFFE0A030);
    case SafetyRating.avoid:
      return const Color(0xFFD23A3A);
  }
}

String _ratingLabel(SafetyRating r) {
  switch (r) {
    case SafetyRating.safe:
      return 'Safe';
    case SafetyRating.caution:
      return 'Caution';
    case SafetyRating.avoid:
      return 'Avoid';
  }
}

IconData _ratingIcon(SafetyRating r) {
  switch (r) {
    case SafetyRating.safe:
      return Icons.check_circle_rounded;
    case SafetyRating.caution:
      return Icons.warning_amber_rounded;
    case SafetyRating.avoid:
      return Icons.cancel_rounded;
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withValues(alpha: 0.18),
      ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard({required this.item});
  final SafetyItem item;

  @override
  Widget build(BuildContext context) {
    final color = _ratingColor(item.rating);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_ratingIcon(item.rating), color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_ratingLabel(item.rating),
                            style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.note,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        'General guidance only — not medical advice. Recommendations can vary, '
        'so always confirm foods and especially medicines with your provider '
        'or pharmacist.',
        style: TextStyle(
            fontSize: 12, color: AppColors.textMuted, height: 1.4),
      ),
    );
  }
}
