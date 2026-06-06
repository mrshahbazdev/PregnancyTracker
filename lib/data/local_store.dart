import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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
  static const _kMeasurements = 'measurements';
  static const _kMemories = 'memories';
  static const _kAppointments = 'appointments';

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
}
