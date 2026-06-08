import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/affirmation_of_day.dart';
import '../../core/affirmations_data.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';

class AffirmationsScreen extends ConsumerStatefulWidget {
  const AffirmationsScreen({super.key});

  @override
  ConsumerState<AffirmationsScreen> createState() =>
      _AffirmationsScreenState();
}

class _AffirmationsScreenState extends ConsumerState<AffirmationsScreen> {
  bool _favoritesOnly = false;
  AffirmationCategory? _category;

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(affirmationFavoritesProvider);
    final notifier = ref.read(affirmationFavoritesProvider.notifier);
    final daily = affirmationOfDay(DateTime.now());

    final list = kAffirmations.where((a) {
      if (_category != null && a.category != _category) return false;
      if (_favoritesOnly && !favorites.contains(a.id)) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Affirmations')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _DailyCard(
            text: daily.text,
            categoryLabel: daily.category.label,
            isFavorite: favorites.contains(daily.id),
            onFavorite: () => notifier.toggle(daily.id),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Browse',
                  style:
                      TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const Spacer(),
              FilterChip(
                label: const Text('Favourites'),
                selected: _favoritesOnly,
                onSelected: (v) => setState(() => _favoritesOnly = v),
                avatar: Icon(
                  _favoritesOnly
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _category == null,
                    onSelected: (_) => setState(() => _category = null),
                    selectedColor:
                        AppColors.primary.withValues(alpha: 0.18),
                  ),
                ),
                for (final c in AffirmationCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c.label),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                      selectedColor:
                          AppColors.primary.withValues(alpha: 0.18),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('No affirmations here yet',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
            )
          else
            ...list.map((a) => _AffirmationTile(
                  text: a.text,
                  isFavorite: favorites.contains(a.id),
                  onFavorite: () => notifier.toggle(a.id),
                )),
        ],
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({
    required this.text,
    required this.categoryLabel,
    required this.isFavorite,
    required this.onFavorite,
  });

  final String text;
  final String categoryLabel;
  final bool isFavorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Today · $categoryLabel',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.3),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onFavorite,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              icon: Icon(isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded),
              label: Text(isFavorite ? 'Saved' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AffirmationTile extends StatelessWidget {
  const _AffirmationTile({
    required this.text,
    required this.isFavorite,
    required this.onFavorite,
  });

  final String text;
  final bool isFavorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w600, height: 1.3)),
        trailing: IconButton(
          onPressed: onFavorite,
          icon: Icon(
            isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
