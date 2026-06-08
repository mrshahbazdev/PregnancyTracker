import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/baby_names_data.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';

class BabyNamesScreen extends ConsumerStatefulWidget {
  const BabyNamesScreen({super.key});

  @override
  ConsumerState<BabyNamesScreen> createState() => _BabyNamesScreenState();
}

class _BabyNamesScreenState extends ConsumerState<BabyNamesScreen> {
  String _query = '';
  String _gender = 'all'; // all | girl | boy | unisex

  List<BabyName> _filter(List<BabyName> names) {
    final q = _query.trim().toLowerCase();
    return names.where((n) {
      final matchesGender = _gender == 'all' || n.gender == _gender;
      final matchesQuery = q.isEmpty ||
          n.name.toLowerCase().contains(q) ||
          n.meaning.toLowerCase().contains(q) ||
          n.origin.toLowerCase().contains(q);
      return matchesGender && matchesQuery;
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(babyNamesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Baby Names'),
          bottom: const TabBar(
            labelColor: AppColors.primaryDark,
            indicatorColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            tabs: [
              Tab(text: 'Browse'),
              Tab(text: 'Shortlist'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addCustom,
          icon: const Icon(Icons.add),
          label: const Text('Add name'),
        ),
        body: TabBarView(
          children: [
            _BrowseTab(
              query: _query,
              gender: _gender,
              names: _filter(st.all),
              state: st,
              onQuery: (v) => setState(() => _query = v),
              onGender: (v) => setState(() => _gender = v),
            ),
            _ShortlistTab(
              names: _filter(st.all).where(st.isFavorite).toList(),
              state: st,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addCustom() async {
    final result = await showModalBottomSheet<BabyName>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _AddNameSheet(),
    );
    if (result == null) return;
    final added = await ref.read(babyNamesProvider.notifier).addCustom(result);
    if (!mounted) return;
    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That name is already in the list.')),
      );
    }
  }
}

class _BrowseTab extends ConsumerWidget {
  const _BrowseTab({
    required this.query,
    required this.gender,
    required this.names,
    required this.state,
    required this.onQuery,
    required this.onGender,
  });

  final String query;
  final String gender;
  final List<BabyName> names;
  final BabyNamesState state;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onGender;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: TextField(
            onChanged: onQuery,
            decoration: InputDecoration(
              hintText: 'Search names, meaning or origin',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              for (final g in const ['all', 'girl', 'boy', 'unisex'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(g == 'all' ? 'All' : _cap(g)),
                    selected: gender == g,
                    onSelected: (_) => onGender(g),
                    selectedColor: AppColors.primary.withValues(alpha: 0.18),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: names.isEmpty
              ? const _EmptyState(
                  icon: Icons.search_off_rounded,
                  text: 'No names match your search.')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                  itemCount: names.length,
                  itemBuilder: (_, i) =>
                      _NameCard(name: names[i], state: state),
                ),
        ),
      ],
    );
  }
}

class _ShortlistTab extends StatelessWidget {
  const _ShortlistTab({required this.names, required this.state});

  final List<BabyName> names;
  final BabyNamesState state;

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) {
      return const _EmptyState(
        icon: Icons.favorite_border_rounded,
        text: 'Tap the heart on any name to add it to your shortlist.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      itemCount: names.length,
      itemBuilder: (_, i) => _NameCard(name: names[i], state: state),
    );
  }
}

class _NameCard extends ConsumerWidget {
  const _NameCard({required this.name, required this.state});

  final BabyName name;
  final BabyNamesState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fav = state.isFavorite(name);
    final color = _genderColor(name.gender);
    final subtitle = [
      if (name.origin.isNotEmpty) name.origin,
      if (name.meaning.isNotEmpty) name.meaning,
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                name.name.isNotEmpty ? name.name[0].toUpperCase() : '?',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w900, color: color),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(name.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                      if (name.isCustom) ...[
                        const SizedBox(width: 6),
                        const _Pill(text: 'Yours'),
                      ],
                    ],
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 13)),
                  ],
                ],
              ),
            ),
            if (name.isCustom)
              IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.textMuted),
                onPressed: () =>
                    ref.read(babyNamesProvider.notifier).removeCustom(name),
              ),
            IconButton(
              tooltip: fav ? 'Remove from shortlist' : 'Add to shortlist',
              icon: Icon(
                fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: fav ? AppColors.primary : AppColors.textMuted,
              ),
              onPressed: () =>
                  ref.read(babyNamesProvider.notifier).toggleFavorite(name),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _AddNameSheet extends StatefulWidget {
  const _AddNameSheet();

  @override
  State<_AddNameSheet> createState() => _AddNameSheetState();
}

class _AddNameSheetState extends State<_AddNameSheet> {
  final _name = TextEditingController();
  final _meaning = TextEditingController();
  final _origin = TextEditingController();
  String _gender = 'unisex';

  @override
  void dispose() {
    _name.dispose();
    _meaning.dispose();
    _origin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add a name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _meaning,
            decoration: const InputDecoration(labelText: 'Meaning (optional)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _origin,
            decoration: const InputDecoration(labelText: 'Origin (optional)'),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              for (final g in kNameGenders)
                ChoiceChip(
                  label: Text(_cap(g)),
                  selected: _gender == g,
                  onSelected: (_) => setState(() => _gender = g),
                  selectedColor: AppColors.primary.withValues(alpha: 0.18),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final n = _name.text.trim();
                if (n.isEmpty) return;
                Navigator.of(context).pop(BabyName(
                  name: n,
                  gender: _gender,
                  meaning: _meaning.text.trim(),
                  origin: _origin.text.trim(),
                  isCustom: true,
                ));
              },
              child: const Text('Save name'),
            ),
          ),
        ],
      ),
    );
  }
}

String _cap(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

Color _genderColor(String gender) {
  switch (gender) {
    case 'girl':
      return AppColors.primary;
    case 'boy':
      return AppColors.secondary;
    default:
      return AppColors.primaryDark;
  }
}
