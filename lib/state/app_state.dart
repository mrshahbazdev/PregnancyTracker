import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/checklist_data.dart';
import '../core/wellness.dart';
import '../data/local_store.dart';
import '../models/log_entry.dart';
import '../models/pregnancy_profile.dart';

/// Provides the [LocalStore]. Overridden with a concrete instance in main().
final localStoreProvider = Provider<LocalStore>((ref) {
  throw UnimplementedError('localStoreProvider must be overridden in main()');
});

/// The current pregnancy profile (null until onboarding is completed).
class ProfileNotifier extends StateNotifier<PregnancyProfile?> {
  ProfileNotifier(this._store) : super(_store.loadProfile());

  final LocalStore _store;

  Future<void> setProfile(PregnancyProfile profile) async {
    state = profile;
    await _store.saveProfile(profile);
  }

  Future<void> reset() async {
    state = null;
    await _store.clearProfile();
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, PregnancyProfile?>((ref) {
  return ProfileNotifier(ref.watch(localStoreProvider));
});

/// Symptom logs, newest first.
class SymptomLogsNotifier extends StateNotifier<List<SymptomLog>> {
  SymptomLogsNotifier(this._store) : super(_sorted(_store.loadSymptomLogs()));

  final LocalStore _store;

  static List<SymptomLog> _sorted(List<SymptomLog> list) {
    final copy = [...list]..sort((a, b) => b.date.compareTo(a.date));
    return copy;
  }

  Future<void> add(SymptomLog log) async {
    state = _sorted([...state, log]);
    await _store.saveSymptomLogs(state);
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _store.saveSymptomLogs(state);
  }
}

final symptomLogsProvider =
    StateNotifierProvider<SymptomLogsNotifier, List<SymptomLog>>((ref) {
  return SymptomLogsNotifier(ref.watch(localStoreProvider));
});

/// Kick sessions, newest first.
class KickSessionsNotifier extends StateNotifier<List<KickSession>> {
  KickSessionsNotifier(this._store)
      : super(_sorted(_store.loadKickSessions()));

  final LocalStore _store;

  static List<KickSession> _sorted(List<KickSession> list) {
    final copy = [...list]..sort((a, b) => b.start.compareTo(a.start));
    return copy;
  }

  Future<void> add(KickSession session) async {
    state = _sorted([...state, session]);
    await _store.saveKickSessions(state);
  }
}

final kickSessionsProvider =
    StateNotifierProvider<KickSessionsNotifier, List<KickSession>>((ref) {
  return KickSessionsNotifier(ref.watch(localStoreProvider));
});

/// Measurements, newest first.
class MeasurementsNotifier extends StateNotifier<List<Measurement>> {
  MeasurementsNotifier(this._store)
      : super(_sorted(_store.loadMeasurements()));

  final LocalStore _store;

  static List<Measurement> _sorted(List<Measurement> list) {
    final copy = [...list]..sort((a, b) => a.date.compareTo(b.date));
    return copy;
  }

  Future<void> add(Measurement m) async {
    state = _sorted([...state, m]);
    await _store.saveMeasurements(state);
  }
}

final measurementsProvider =
    StateNotifierProvider<MeasurementsNotifier, List<Measurement>>((ref) {
  return MeasurementsNotifier(ref.watch(localStoreProvider));
});

/// Time-capsule memories, newest first.
class MemoriesNotifier extends StateNotifier<List<MemoryEntry>> {
  MemoriesNotifier(this._store) : super(_sorted(_store.loadMemories()));

  final LocalStore _store;

  static List<MemoryEntry> _sorted(List<MemoryEntry> list) {
    final copy = [...list]..sort((a, b) => b.date.compareTo(a.date));
    return copy;
  }

  Future<void> add(MemoryEntry m) async {
    state = _sorted([...state, m]);
    await _store.saveMemories(state);
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _store.saveMemories(state);
  }
}

final memoriesProvider =
    StateNotifierProvider<MemoriesNotifier, List<MemoryEntry>>((ref) {
  return MemoriesNotifier(ref.watch(localStoreProvider));
});

/// Prenatal appointments, soonest first.
class AppointmentsNotifier extends StateNotifier<List<Appointment>> {
  AppointmentsNotifier(this._store) : super(_sorted(_store.loadAppointments()));

  final LocalStore _store;

  static List<Appointment> _sorted(List<Appointment> list) {
    final copy = [...list]..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return copy;
  }

  Future<void> add(Appointment a) async {
    state = _sorted([...state, a]);
    await _store.saveAppointments(state);
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _store.saveAppointments(state);
  }
}

final appointmentsProvider =
    StateNotifierProvider<AppointmentsNotifier, List<Appointment>>((ref) {
  return AppointmentsNotifier(ref.watch(localStoreProvider));
});

/// The next upcoming appointment, or null if none is scheduled.
final nextAppointmentProvider = Provider<Appointment?>((ref) {
  final now = DateTime.now();
  final upcoming = ref
      .watch(appointmentsProvider)
      .where((a) => a.dateTime.isAfter(now))
      .toList();
  return upcoming.isEmpty ? null : upcoming.first;
});

/// A checklist (keyed by [ChecklistKind]). Seeds presets on first use, then
/// persists user changes (toggles, custom items, deletions).
class ChecklistNotifier extends StateNotifier<List<ChecklistItem>> {
  ChecklistNotifier(this._store, this._kind)
      : super(_store.loadChecklist(_kind) ?? defaultChecklist(_kind));

  final LocalStore _store;
  final String _kind;

  Future<void> _persist() => _store.saveChecklist(_kind, state);

  Future<void> toggle(String id) async {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(done: !item.done) else item,
    ];
    await _persist();
  }

  Future<void> addCustom(String label, String category) async {
    final item = ChecklistItem(
      id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
      label: label,
      category: category,
      custom: true,
    );
    state = [...state, item];
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _persist();
  }

  Future<void> resetToDefaults() async {
    state = defaultChecklist(_kind);
    await _persist();
  }
}

final checklistProvider = StateNotifierProvider.family<ChecklistNotifier,
    List<ChecklistItem>, String>((ref, kind) {
  return ChecklistNotifier(ref.watch(localStoreProvider), kind);
});

/// The user's birth plan (answers + notes), persisted on every change.
class BirthPlanNotifier extends StateNotifier<BirthPlan> {
  BirthPlanNotifier(this._store) : super(_store.loadBirthPlan());

  final LocalStore _store;

  Future<void> setAnswer(String questionId, String option) async {
    state = state.setAnswer(questionId, option);
    await _store.saveBirthPlan(state);
  }

  Future<void> setNotes(String value) async {
    state = state.withNotes(value);
    await _store.saveBirthPlan(state);
  }
}

final birthPlanProvider =
    StateNotifierProvider<BirthPlanNotifier, BirthPlan>((ref) {
  return BirthPlanNotifier(ref.watch(localStoreProvider));
});

/// Daily wellness log (water, vitamin, mood) — one [WellnessDay] per date,
/// persisted on every change.
class WellnessNotifier extends StateNotifier<List<WellnessDay>> {
  WellnessNotifier(this._store) : super(_store.loadWellnessDays());

  final LocalStore _store;

  /// Today's entry, creating an empty one (not yet persisted) if absent.
  WellnessDay today() {
    final key = wellnessDateKey(DateTime.now());
    for (final d in state) {
      if (d.dateKey == key) return d;
    }
    return WellnessDay(dateKey: key);
  }

  Future<void> _upsert(WellnessDay day) async {
    final next = [
      for (final d in state)
        if (d.dateKey != day.dateKey) d,
      day,
    ];
    state = next;
    await _store.saveWellnessDays(next);
  }

  Future<void> addWater(int delta) async {
    final t = today();
    final next = (t.water + delta).clamp(0, 30);
    await _upsert(t.copyWith(water: next));
  }

  Future<void> setVitamin(bool taken) => _upsert(today().copyWith(vitamin: taken));

  Future<void> setMood(int mood) => _upsert(today().copyWith(mood: mood));
}

final wellnessProvider =
    StateNotifierProvider<WellnessNotifier, List<WellnessDay>>((ref) {
  return WellnessNotifier(ref.watch(localStoreProvider));
});
