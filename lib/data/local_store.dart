import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/baby_names_data.dart';
import '../models/log_entry.dart';
import '../models/pregnancy_profile.dart';

/// Lightweight JSON-backed persistence using SharedPreferences. This keeps the
/// MVP offline-first and dependency-light; it can be swapped for a full local
/// database (Drift/Isar) and cloud sync later without touching the UI layer.
class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  static const _kProfile = 'profile';
  static const _kSymptoms = 'symptom_logs';
  static const _kKicks = 'kick_sessions';
  static const _kContractions = 'contractions';
  static const _kMeasurements = 'measurements';
  static const _kMemories = 'memories';
  static const _kAppointments = 'appointments';
  static const _kBirthPlan = 'birth_plan';
  static const _kWellness = 'wellness_days';
  static const _kNameFavorites = 'babynames_favorites';
  static const _kNameCustom = 'babynames_custom';
  static const _kBreathingCounts = 'breathing_counts';

  static Future<LocalStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStore(prefs);
  }

  // ---- Profile ----
  PregnancyProfile? loadProfile() {
    final raw = _prefs.getString(_kProfile);
    if (raw == null) return null;
    return PregnancyProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveProfile(PregnancyProfile profile) =>
      _prefs.setString(_kProfile, jsonEncode(profile.toJson()));

  Future<void> clearProfile() => _prefs.remove(_kProfile);

  // ---- Generic list helpers ----
  List<Map<String, dynamic>> _readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  Future<void> _writeList(String key, List<Map<String, dynamic>> list) =>
      _prefs.setString(key, jsonEncode(list));

  // ---- Symptom logs ----
  List<SymptomLog> loadSymptomLogs() =>
      _readList(_kSymptoms).map(SymptomLog.fromJson).toList();

  Future<void> saveSymptomLogs(List<SymptomLog> logs) =>
      _writeList(_kSymptoms, logs.map((e) => e.toJson()).toList());

  // ---- Kick sessions ----
  List<KickSession> loadKickSessions() =>
      _readList(_kKicks).map(KickSession.fromJson).toList();

  Future<void> saveKickSessions(List<KickSession> sessions) =>
      _writeList(_kKicks, sessions.map((e) => e.toJson()).toList());

  // ---- Breathing exercise completion counts (pattern id -> count) ----
  Map<String, int> loadBreathingCounts() {
    final raw = _prefs.getString(_kBreathingCounts);
    if (raw == null) return {};
    return (jsonDecode(raw) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v as int));
  }

  Future<void> saveBreathingCounts(Map<String, int> counts) =>
      _prefs.setString(_kBreathingCounts, jsonEncode(counts));

  // ---- Contractions ----
  List<Contraction> loadContractions() =>
      _readList(_kContractions).map(Contraction.fromJson).toList();

  Future<void> saveContractions(List<Contraction> items) =>
      _writeList(_kContractions, items.map((e) => e.toJson()).toList());

  // ---- Measurements ----
  List<Measurement> loadMeasurements() =>
      _readList(_kMeasurements).map(Measurement.fromJson).toList();

  Future<void> saveMeasurements(List<Measurement> items) =>
      _writeList(_kMeasurements, items.map((e) => e.toJson()).toList());

  // ---- Memories (Time Capsule) ----
  List<MemoryEntry> loadMemories() =>
      _readList(_kMemories).map(MemoryEntry.fromJson).toList();

  Future<void> saveMemories(List<MemoryEntry> items) =>
      _writeList(_kMemories, items.map((e) => e.toJson()).toList());

  // ---- Appointments ----
  List<Appointment> loadAppointments() =>
      _readList(_kAppointments).map(Appointment.fromJson).toList();

  Future<void> saveAppointments(List<Appointment> items) =>
      _writeList(_kAppointments, items.map((e) => e.toJson()).toList());

  // ---- Checklists (keyed by kind) ----
  static String _checklistKey(String kind) => 'checklist_$kind';

  /// Returns saved checklist items for [kind], or null if never saved (so the
  /// caller can seed presets).
  List<ChecklistItem>? loadChecklist(String kind) {
    final raw = _prefs.getString(_checklistKey(kind));
    if (raw == null) return null;
    return _readList(_checklistKey(kind))
        .map(ChecklistItem.fromJson)
        .toList();
  }

  Future<void> saveChecklist(String kind, List<ChecklistItem> items) =>
      _writeList(_checklistKey(kind), items.map((e) => e.toJson()).toList());

  // ---- Birth plan ----
  BirthPlan loadBirthPlan() {
    final raw = _prefs.getString(_kBirthPlan);
    if (raw == null) return const BirthPlan();
    return BirthPlan.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveBirthPlan(BirthPlan plan) =>
      _prefs.setString(_kBirthPlan, jsonEncode(plan.toJson()));

  // ---- Daily wellness ----
  List<WellnessDay> loadWellnessDays() =>
      _readList(_kWellness).map(WellnessDay.fromJson).toList();

  Future<void> saveWellnessDays(List<WellnessDay> days) =>
      _writeList(_kWellness, days.map((e) => e.toJson()).toList());

  // ---- Baby names ----
  List<String> loadFavoriteNames() =>
      _prefs.getStringList(_kNameFavorites) ?? const [];

  Future<void> saveFavoriteNames(List<String> keys) =>
      _prefs.setStringList(_kNameFavorites, keys);

  List<BabyName> loadCustomNames() =>
      _readList(_kNameCustom).map(BabyName.fromJson).toList();

  Future<void> saveCustomNames(List<BabyName> names) =>
      _writeList(_kNameCustom, names.map((e) => e.toJson()).toList());
}
