import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/breathing.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';

class BreathingPlayerScreen extends ConsumerStatefulWidget {
  const BreathingPlayerScreen({super.key, required this.pattern});

  final BreathingPattern pattern;

  @override
  ConsumerState<BreathingPlayerScreen> createState() =>
      _BreathingPlayerScreenState();
}

class _BreathingPlayerScreenState
    extends ConsumerState<BreathingPlayerScreen> {
  Timer? _timer;
  int _elapsed = 0;
  bool _running = false;
  bool _completed = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _running = true;
      _completed = false;
      _elapsed = 0;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed++);
      if (_elapsed >= widget.pattern.totalSeconds) {
        _finish();
      }
    });
  }

  void _stop() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _elapsed = 0;
    });
  }

  Future<void> _finish() async {
    _timer?.cancel();
    setState(() {
      _running = false;
      _completed = true;
    });
    await ref.read(breathingCountsProvider.notifier).increment(widget.pattern.id);
  }

  /// Target scale of the breathing circle for the current phase (0..1 eased).
  double _circleScale(BreathPosition pos) {
    final frac = pos.phase.seconds == 0
        ? 1.0
        : pos.secondsIntoPhase / pos.phase.seconds;
    switch (pos.phase.type) {
      case BreathPhaseType.inhale:
      case BreathPhaseType.squeeze:
        return 0.55 + 0.45 * frac; // grow
      case BreathPhaseType.exhale:
      case BreathPhaseType.relax:
        return 1.0 - 0.45 * frac; // shrink
      case BreathPhaseType.hold:
        return 1.0; // stay big
      case BreathPhaseType.holdAfterExhale:
        return 0.55; // stay small
    }
  }

  @override
  Widget build(BuildContext context) {
    final pattern = widget.pattern;
    final pos = positionAt(pattern, _elapsed);
    final scale = _running ? _circleScale(pos) : 0.7;
    final remaining = pattern.totalSeconds - _elapsed;

    return Scaffold(
      appBar: AppBar(title: Text(pattern.name)),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            _completed
                ? 'Great job!'
                : _running
                    ? 'Cycle ${pos.cycleIndex + 1} of ${pattern.cycles}'
                    : pattern.description,
            style: const TextStyle(fontSize: 15, color: AppColors.textMuted),
          ),
          Expanded(
            child: Center(
              child: AnimatedScale(
                scale: scale,
                duration: const Duration(milliseconds: 950),
                curve: Curves.easeInOut,
                child: Container(
                  width: 240,
                  height: 240,
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
                        blurRadius: 40,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _completed
                              ? '✓'
                              : _running
                                  ? pos.phase.label
                                  : 'Ready',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800),
                        ),
                        if (_running && !_completed) ...[
                          const SizedBox(height: 6),
                          Text('${pos.secondsRemainingInPhase}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_running && !_completed)
            Text('${remaining}s left',
                style: const TextStyle(color: AppColors.textMuted)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: _completed
                  ? FilledButton(
                      onPressed: _start,
                      child: const Text('Do it again'),
                    )
                  : _running
                      ? OutlinedButton(
                          onPressed: _stop,
                          child: const Text('Stop'),
                        )
                      : FilledButton(
                          onPressed: _start,
                          child: const Text('Start'),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
