import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/baby_names_data.dart';
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

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _store.saveKickSessions(state);
  }
}

final kickSessionsProvider =
    StateNotifierProvider<KickSessionsNotifier, List<KickSession>>((ref) {
  return KickSessionsNotifier(ref.watch(localStoreProvider));
});

/// Completed breathing/Kegel sessions per pattern id.
class BreathingCountsNotifier extends StateNotifier<Map<String, int>> {
  BreathingCountsNotifier(this._store) : super(_store.loadBreathingCounts());

  final LocalStore _store;

  int countFor(String patternId) => state[patternId] ?? 0;

  int get total => state.values.fold(0, (a, b) => a + b);

  Future<void> increment(String patternId) async {
    state = {...state, patternId: countFor(patternId) + 1};
    await _store.saveBreathingCounts(state);
  }
}

final breathingCountsProvider =
    StateNotifierProvider<BreathingCountsNotifier, Map<String, int>>((ref) {
  return BreathingCountsNotifier(ref.watch(localStoreProvider));
});

/// Recorded contractions, newest first.
class ContractionsNotifier extends StateNotifier<List<Contraction>> {
  ContractionsNotifier(this._store)
      : super(_sorted(_store.loadContractions()));

  final LocalStore _store;

  static List<Contraction> _sorted(List<Contraction> list) {
    final copy = [...list]..sort((a, b) => b.start.compareTo(a.start));
    return copy;
  }

  Future<void> add(Contraction c) async {
    state = _sorted([...state, c]);
    await _store.saveContractions(state);
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _store.saveContractions(state);
  }

  Future<void> clearAll() async {
    state = [];
    await _store.saveContractions(state);
  }
}

final contractionsProvider =
    StateNotifierProvider<ContractionsNotifier, List<Contraction>>((ref) {
  return ContractionsNotifier(ref.watch(localStoreProvider));
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

/// Pregnancy journal entries, newest first.
class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  JournalNotifier(this._store) : super(_sorted(_store.loadJournal()));

  final LocalStore _store;

  static List<JournalEntry> _sorted(List<JournalEntry> list) {
    final copy = [...list]..sort((a, b) => b.date.compareTo(a.date));
    return copy;
  }

  Future<void> add(JournalEntry e) async {
    state = _sorted([...state, e]);
    await _store.saveJournal(state);
  }

  Future<void> update(JournalEntry e) async {
    state = _sorted([
      for (final j in state) if (j.id == e.id) e else j,
    ]);
    await _store.saveJournal(state);
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _store.saveJournal(state);
  }
}

final journalProvider =
    StateNotifierProvider<JournalNotifier, List<JournalEntry>>((ref) {
  return JournalNotifier(ref.watch(localStoreProvider));
});

/// Weight-gain goal baseline (pre-pregnancy weight + height); null until set.
class WeightGoalNotifier extends StateNotifier<WeightGoalConfig?> {
  WeightGoalNotifier(this._store) : super(_store.loadWeightGoal());

  final LocalStore _store;

  Future<void> set(WeightGoalConfig config) async {
    state = config;
    await _store.saveWeightGoal(config);
  }

  Future<void> clear() async {
    state = null;
    await _store.clearWeightGoal();
  }
}

final weightGoalProvider =
    StateNotifierProvider<WeightGoalNotifier, WeightGoalConfig?>((ref) {
  return WeightGoalNotifier(ref.watch(localStoreProvider));
});

/// Saved emergency / important contacts (insertion order preserved).
class ContactsNotifier extends StateNotifier<List<EmergencyContact>> {
  ContactsNotifier(this._store) : super(_store.loadContacts());

  final LocalStore _store;

  Future<void> add(EmergencyContact c) async {
    state = [...state, c];
    await _store.saveContacts(state);
  }

  Future<void> update(EmergencyContact c) async {
    state = [
      for (final e in state) if (e.id == c.id) c else e,
    ];
    await _store.saveContacts(state);
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _store.saveContacts(state);
  }
}

final contactsProvider =
    StateNotifierProvider<ContactsNotifier, List<EmergencyContact>>((ref) {
  return ContactsNotifier(ref.watch(localStoreProvider));
});

/// Baby budget items (insertion order preserved).
class BudgetNotifier extends StateNotifier<List<BudgetItem>> {
  BudgetNotifier(this._store) : super(_store.loadBudget());

  final LocalStore _store;

  Future<void> add(BudgetItem item) async {
    state = [...state, item];
    await _store.saveBudget(state);
  }

  Future<void> update(BudgetItem item) async {
    state = [
      for (final e in state) if (e.id == item.id) item else e,
    ];
    await _store.saveBudget(state);
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _store.saveBudget(state);
  }
}

final budgetProvider =
    StateNotifierProvider<BudgetNotifier, List<BudgetItem>>((ref) {
  return BudgetNotifier(ref.watch(localStoreProvider));
});

/// Nightly sleep logs, newest first.
class SleepNotifier extends StateNotifier<List<SleepEntry>> {
  SleepNotifier(this._store) : super(_sorted(_store.loadSleep()));

  final LocalStore _store;

  static List<SleepEntry> _sorted(List<SleepEntry> list) {
    final copy = [...list]..sort((a, b) => b.date.compareTo(a.date));
    return copy;
  }

  Future<void> add(SleepEntry e) async {
    state = _sorted([...state, e]);
    await _store.saveSleep(state);
  }

  Future<void> update(SleepEntry e) async {
    state = _sorted([
      for (final s in state) if (s.id == e.id) e else s,
    ]);
    await _store.saveSleep(state);
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _store.saveSleep(state);
  }
}

final sleepProvider =
    StateNotifierProvider<SleepNotifier, List<SleepEntry>>((ref) {
  return SleepNotifier(ref.watch(localStoreProvider));
});

/// Cravings & aversions, newest first.
class CravingsNotifier extends StateNotifier<List<CravingEntry>> {
  CravingsNotifier(this._store) : super(_sorted(_store.loadCravings()));

  final LocalStore _store;

  static List<CravingEntry> _sorted(List<CravingEntry> list) {
    final copy = [...list]..sort((a, b) => b.date.compareTo(a.date));
    return copy;
  }

  Future<void> add(CravingEntry e) async {
    state = _sorted([...state, e]);
    await _store.saveCravings(state);
  }

  Future<void> update(CravingEntry e) async {
    state = _sorted([
      for (final c in state) if (c.id == e.id) e else c,
    ]);
    await _store.saveCravings(state);
  }

  Future<void> remove(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _store.saveCravings(state);
  }
}

final cravingsProvider =
    StateNotifierProvider<CravingsNotifier, List<CravingEntry>>((ref) {
  return CravingsNotifier(ref.watch(localStoreProvider));
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

/// Baby-name shortlist: user-added custom names plus the set of favourited
/// name keys (curated or custom). Persisted on every change.
class BabyNamesState {
  const BabyNamesState({this.custom = const [], this.favorites = const {}});

  final List<BabyName> custom;
  final Set<String> favorites;

  /// Curated names first, then user-added ones (newest custom last).
  List<BabyName> get all => [...kBabyNames, ...custom];

  bool isFavorite(BabyName n) => favorites.contains(n.key);

  BabyNamesState copyWith({List<BabyName>? custom, Set<String>? favorites}) =>
      BabyNamesState(
        custom: custom ?? this.custom,
        favorites: favorites ?? this.favorites,
      );
}

class BabyNamesNotifier extends StateNotifier<BabyNamesState> {
  BabyNamesNotifier(this._store)
      : super(BabyNamesState(
          custom: _store.loadCustomNames(),
          favorites: _store.loadFavoriteNames().toSet(),
        ));

  final LocalStore _store;

  Future<void> toggleFavorite(BabyName n) async {
    final next = {...state.favorites};
    if (!next.add(n.key)) next.remove(n.key);
    state = state.copyWith(favorites: next);
    await _store.saveFavoriteNames(next.toList());
  }

  /// Adds a custom name if it isn't already in the list. Returns false if a
  /// name with the same key already exists (curated or custom).
  Future<bool> addCustom(BabyName n) async {
    final exists = state.all.any((e) => e.key == n.key);
    if (n.name.trim().isEmpty || exists) return false;
    final next = [...state.custom, n];
    state = state.copyWith(custom: next);
    await _store.saveCustomNames(next);
    return true;
  }

  Future<void> removeCustom(BabyName n) async {
    final next = state.custom.where((e) => e.key != n.key).toList();
    final favs = {...state.favorites}..remove(n.key);
    state = state.copyWith(custom: next, favorites: favs);
    await _store.saveCustomNames(next);
    await _store.saveFavoriteNames(favs.toList());
  }
}

final babyNamesProvider =
    StateNotifierProvider<BabyNamesNotifier, BabyNamesState>((ref) {
  return BabyNamesNotifier(ref.watch(localStoreProvider));
});
