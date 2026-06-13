import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/contractions.dart';
import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';

class ContractionTimerScreen extends ConsumerStatefulWidget {
  const ContractionTimerScreen({super.key});

  @override
  ConsumerState<ContractionTimerScreen> createState() =>
      _ContractionTimerScreenState();
}

class _ContractionTimerScreenState
    extends ConsumerState<ContractionTimerScreen> {
  DateTime? _activeStart;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _toggle() async {
    HapticFeedback.mediumImpact();
    if (_activeStart == null) {
      setState(() => _activeStart = DateTime.now());
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed = DateTime.now().difference(_activeStart!));
      });
    } else {
      final c = Contraction(
        id: const Uuid().v4(),
        start: _activeStart!,
        end: DateTime.now(),
      );
      _timer?.cancel();
      setState(() {
        _activeStart = null;
        _elapsed = Duration.zero;
        _timer = null;
      });
      await ref.read(contractionsProvider.notifier).add(c);
    }
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all contractions?'),
        content: const Text('This removes all recorded contractions.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(contractionsProvider.notifier).clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final contractions = ref.watch(contractionsProvider);
    final stats = analyzeContractions(contractions, now: DateTime.now());
    final active = _activeStart != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contraction Timer'),
        actions: [
          if (contractions.isNotEmpty)
            IconButton(
              tooltip: 'Clear all',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _confirmClear,
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(active ? _fmt(_elapsed) : 'Ready',
              style:
                  const TextStyle(fontSize: 44, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            active ? 'Contraction in progress' : 'Tap start when one begins',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: _toggle,
            style: FilledButton.styleFrom(
              backgroundColor: active ? AppColors.secondary : AppColors.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 56, vertical: 18),
            ),
            child: Text(active ? 'Stop' : 'Start',
                style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 18),
          if (stats.recentCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _StatsCard(stats: stats, fmt: _fmt),
            ),
          if (stats.meets511)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _HospitalAlert(),
            ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          Expanded(
            child: contractions.isEmpty
                ? const Center(
                    child: Text('No contractions recorded yet',
                        style: TextStyle(color: AppColors.textMuted)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: contractions.length,
                    itemBuilder: (context, i) {
                      final c = contractions[i];
                      // Gap to the previous (older) contraction's start.
                      final older = i + 1 < contractions.length
                          ? contractions[i + 1]
                          : null;
                      final gap = older == null
                          ? null
                          : c.start.difference(older.start);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.15),
                            child: Text('${contractions.length - i}',
                                style: const TextStyle(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.bold)),
                          ),
                          title: Text('Lasted ${_fmt(c.duration)}'),
                          subtitle: Text(
                            '${DateFormat.jm().format(c.start)}'
                            '${gap != null ? ' · ${_fmt(gap)} apart' : ''}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: AppColors.textMuted),
                            onPressed: () => ref
                                .read(contractionsProvider.notifier)
                                .remove(c.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats, required this.fmt});

  final ContractionStats stats;
  final String Function(Duration) fmt;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _stat('Last hour', '${stats.recentCount}'),
            _stat('Avg length', fmt(stats.avgDuration)),
            _stat('Avg apart',
                stats.avgInterval == Duration.zero ? '—' : fmt(stats.avgInterval)),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      );
}

class _HospitalAlert extends StatelessWidget {
  const _HospitalAlert();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.local_hospital_rounded, color: Colors.red),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your contractions match the 5-1-1 pattern (about 5 min apart, '
              '~1 min long, for an hour). Consider contacting your provider '
              'or hospital.',
              style: TextStyle(fontWeight: FontWeight.w600, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
