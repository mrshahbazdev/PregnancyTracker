import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';
import '../insights/movement_insights_screen.dart';

class KickCounterScreen extends ConsumerStatefulWidget {
  const KickCounterScreen({super.key});

  @override
  ConsumerState<KickCounterScreen> createState() =>
      _KickCounterScreenState();
}

class _KickCounterScreenState extends ConsumerState<KickCounterScreen> {
  int _kicks = 0;
  DateTime? _start;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tap() {
    setState(() {
      _start ??= DateTime.now();
      _kicks++;
    });
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed = DateTime.now().difference(_start!));
    });
  }

  Future<void> _save() async {
    if (_start == null || _kicks == 0) return;
    final session = KickSession(
      id: const Uuid().v4(),
      start: _start!,
      durationSeconds: _elapsed.inSeconds,
      kicks: _kicks,
    );
    await ref.read(kickSessionsProvider.notifier).add(session);
    if (!mounted) return;
    setState(() {
      _kicks = 0;
      _start = null;
      _elapsed = Duration.zero;
      _timer?.cancel();
      _timer = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kick session saved')),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(kickSessionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kick Counter'),
        actions: [
          IconButton(
            tooltip: 'Movement insights',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const MovementInsightsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(_start == null ? 'Tap when you feel a kick' : _fmt(_elapsed),
              style: const TextStyle(
                  fontSize: 18, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _tap,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$_kicks',
                          style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                      const Text('kicks',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _start == null
                        ? null
                        : () => setState(() {
                              _kicks = 0;
                              _start = null;
                              _elapsed = Duration.zero;
                              _timer?.cancel();
                              _timer = null;
                            }),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _kicks == 0 ? null : _save,
                    child: const Text('Save session'),
                  ),
                ),
              ],
            ),
          ),
          if (sessions.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const Text('Recent sessions',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...sessions.take(5).map((s) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.sports_soccer_rounded,
                            color: AppColors.primary),
                        title: Text('${s.kicks} kicks'),
                        subtitle: Text(
                            '${DateFormat.MMMd().add_jm().format(s.start)} · ${_fmt(Duration(seconds: s.durationSeconds))}'),
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
