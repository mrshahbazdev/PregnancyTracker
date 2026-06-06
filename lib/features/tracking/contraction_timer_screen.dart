import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';

class _Contraction {
  _Contraction(this.start, this.end, this.gapFromPrev);
  final DateTime start;
  final DateTime end;
  final Duration? gapFromPrev;
  Duration get duration => end.difference(start);
}

class ContractionTimerScreen extends StatefulWidget {
  const ContractionTimerScreen({super.key});

  @override
  State<ContractionTimerScreen> createState() =>
      _ContractionTimerScreenState();
}

class _ContractionTimerScreenState extends State<ContractionTimerScreen> {
  final List<_Contraction> _contractions = [];
  DateTime? _activeStart;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_activeStart == null) {
      setState(() => _activeStart = DateTime.now());
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed = DateTime.now().difference(_activeStart!));
      });
    } else {
      final end = DateTime.now();
      final gap = _contractions.isEmpty
          ? null
          : _activeStart!.difference(_contractions.last.start);
      setState(() {
        _contractions.insert(0, _Contraction(_activeStart!, end, gap));
        _activeStart = null;
        _elapsed = Duration.zero;
        _timer?.cancel();
        _timer = null;
      });
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Simple 5-1-1 guidance: contractions ~5 min apart, lasting ~60s,
  /// over the last hour. Educational only.
  bool get _shouldConsiderHospital {
    final recent = _contractions.take(6).toList();
    if (recent.length < 4) return false;
    final withGap = recent.where((c) => c.gapFromPrev != null).toList();
    if (withGap.length < 3) return false;
    final avgGap = withGap
            .map((c) => c.gapFromPrev!.inSeconds)
            .reduce((a, b) => a + b) /
        withGap.length;
    final avgDur = recent
            .map((c) => c.duration.inSeconds)
            .reduce((a, b) => a + b) /
        recent.length;
    return avgGap <= 300 && avgDur >= 45;
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeStart != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Contraction Timer')),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Text(active ? _fmt(_elapsed) : 'Ready',
              style: const TextStyle(
                  fontSize: 44, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(active ? 'Contraction in progress' : 'Tap start when one begins',
              style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _toggle,
            style: FilledButton.styleFrom(
              backgroundColor:
                  active ? AppColors.secondary : AppColors.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 56, vertical: 18),
            ),
            child: Text(active ? 'Stop' : 'Start',
                style: const TextStyle(fontSize: 18)),
          ),
          if (_shouldConsiderHospital)
            Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                      'Your contractions look regular and close together. '
                      'Consider contacting your provider or hospital.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          Expanded(
            child: _contractions.isEmpty
                ? const Center(
                    child: Text('No contractions recorded yet',
                        style: TextStyle(color: AppColors.textMuted)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _contractions.length,
                    itemBuilder: (context, i) {
                      final c = _contractions[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          child: Text('${_contractions.length - i}',
                              style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold)),
                        ),
                        title: Text('Lasted ${_fmt(c.duration)}'),
                        subtitle: Text(
                          '${DateFormat.jm().format(c.start)}'
                          '${c.gapFromPrev != null ? ' · ${_fmt(c.gapFromPrev!)} apart' : ''}',
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
