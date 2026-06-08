import 'package:flutter/foundation.dart';

/// A single phase within a breathing/relaxation cycle.
enum BreathPhaseType { inhale, hold, exhale, holdAfterExhale, squeeze, relax }

@immutable
class BreathPhase {
  const BreathPhase(this.type, this.seconds);
  final BreathPhaseType type;
  final int seconds;

  String get label {
    switch (type) {
      case BreathPhaseType.inhale:
        return 'Breathe in';
      case BreathPhaseType.hold:
      case BreathPhaseType.holdAfterExhale:
        return 'Hold';
      case BreathPhaseType.exhale:
        return 'Breathe out';
      case BreathPhaseType.squeeze:
        return 'Squeeze';
      case BreathPhaseType.relax:
        return 'Relax';
    }
  }
}

/// A guided exercise made of repeating phases.
@immutable
class BreathingPattern {
  const BreathingPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.phases,
    required this.cycles,
  });

  final String id;
  final String name;
  final String description;
  final List<BreathPhase> phases;

  /// Recommended number of cycles for one session.
  final int cycles;

  /// Length of a single cycle.
  int get cycleSeconds =>
      phases.fold(0, (sum, p) => sum + p.seconds);

  /// Total length of the full session.
  int get totalSeconds => cycleSeconds * cycles;
}

/// Where we are in a pattern at a given elapsed time.
@immutable
class BreathPosition {
  const BreathPosition({
    required this.phase,
    required this.secondsIntoPhase,
    required this.secondsRemainingInPhase,
    required this.cycleIndex,
    required this.finished,
  });

  final BreathPhase phase;
  final int secondsIntoPhase;
  final int secondsRemainingInPhase;
  final int cycleIndex;
  final bool finished;
}

/// Curated, offline patterns. 4-7-8 and box breathing are common calming
/// techniques; "labor" is a simple slow in/out used in labor breathing classes.
const List<BreathingPattern> kBreathingPatterns = [
  BreathingPattern(
    id: 'box',
    name: 'Box breathing',
    description: 'Equal 4-4-4-4 — calms the nervous system.',
    cycles: 6,
    phases: [
      BreathPhase(BreathPhaseType.inhale, 4),
      BreathPhase(BreathPhaseType.hold, 4),
      BreathPhase(BreathPhaseType.exhale, 4),
      BreathPhase(BreathPhaseType.holdAfterExhale, 4),
    ],
  ),
  BreathingPattern(
    id: '478',
    name: '4-7-8 calm',
    description: 'Inhale 4, hold 7, exhale 8 — great before sleep.',
    cycles: 4,
    phases: [
      BreathPhase(BreathPhaseType.inhale, 4),
      BreathPhase(BreathPhaseType.hold, 7),
      BreathPhase(BreathPhaseType.exhale, 8),
    ],
  ),
  BreathingPattern(
    id: 'labor',
    name: 'Labor breathing',
    description: 'Slow in 4, out 6 — steady focus through contractions.',
    cycles: 8,
    phases: [
      BreathPhase(BreathPhaseType.inhale, 4),
      BreathPhase(BreathPhaseType.exhale, 6),
    ],
  ),
  BreathingPattern(
    id: 'kegel',
    name: 'Kegel exercise',
    description: 'Squeeze 5, relax 5 — strengthens pelvic floor.',
    cycles: 10,
    phases: [
      BreathPhase(BreathPhaseType.squeeze, 5),
      BreathPhase(BreathPhaseType.relax, 5),
    ],
  ),
];

/// Resolve the position within [pattern] at [elapsedSeconds]. Pure for tests.
BreathPosition positionAt(BreathingPattern pattern, int elapsedSeconds) {
  final total = pattern.totalSeconds;
  final cycleLen = pattern.cycleSeconds;
  if (elapsedSeconds >= total) {
    final last = pattern.phases.last;
    return BreathPosition(
      phase: last,
      secondsIntoPhase: last.seconds,
      secondsRemainingInPhase: 0,
      cycleIndex: pattern.cycles - 1,
      finished: true,
    );
  }

  final clamped = elapsedSeconds < 0 ? 0 : elapsedSeconds;
  final cycleIndex = clamped ~/ cycleLen;
  var into = clamped % cycleLen;

  for (final phase in pattern.phases) {
    if (into < phase.seconds) {
      return BreathPosition(
        phase: phase,
        secondsIntoPhase: into,
        secondsRemainingInPhase: phase.seconds - into,
        cycleIndex: cycleIndex,
        finished: false,
      );
    }
    into -= phase.seconds;
  }

  // Shouldn't happen, but fall back to the first phase.
  return BreathPosition(
    phase: pattern.phases.first,
    secondsIntoPhase: 0,
    secondsRemainingInPhase: pattern.phases.first.seconds,
    cycleIndex: cycleIndex,
    finished: false,
  );
}
