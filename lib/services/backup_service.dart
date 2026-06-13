import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/bump_photo.dart';
import '../models/log_entry.dart';
import '../models/nutrition_entry.dart';
import '../models/pregnancy_profile.dart';
import '../data/local_store.dart';

/// Creates and restores JSON backups of all user data.
class BackupService {
  BackupService(this._store);

  final LocalStore _store;

  /// Export all user data as a single JSON file. Returns the file path.
  Future<String> exportBackup() async {
    final data = <String, dynamic>{
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': _store.loadProfile()?.toJson(),
      'symptomLogs': _store.loadSymptomLogs().map((e) => e.toJson()).toList(),
      'kickSessions':
          _store.loadKickSessions().map((e) => e.toJson()).toList(),
      'contractions':
          _store.loadContractions().map((e) => e.toJson()).toList(),
      'measurements':
          _store.loadMeasurements().map((e) => e.toJson()).toList(),
      'memories': _store.loadMemories().map((e) => e.toJson()).toList(),
      'journal': _store.loadJournal().map((e) => e.toJson()).toList(),
      'appointments':
          _store.loadAppointments().map((e) => e.toJson()).toList(),
      'birthPlan': _store.loadBirthPlan().toJson(),
      'wellnessDays':
          _store.loadWellnessDays().map((e) => e.toJson()).toList(),
      'sleep': _store.loadSleep().map((e) => e.toJson()).toList(),
      'cravings': _store.loadCravings().map((e) => e.toJson()).toList(),
      'postpartum': _store.loadPostpartum().map((e) => e.toJson()).toList(),
      'babyCare': _store.loadBabyCare().map((e) => e.toJson()).toList(),
      'growth': _store.loadGrowth().map((e) => e.toJson()).toList(),
      'vaccineDone': _store.loadVaccineDone(),
      'milestoneDates': _store.loadMilestoneDates(),
      'budget': _store.loadBudget().map((e) => e.toJson()).toList(),
      'contacts': _store.loadContacts().map((e) => e.toJson()).toList(),
      'breathingCounts': _store.loadBreathingCounts(),
      'weightGoal': _store.loadWeightGoal()?.toJson(),
      'favoriteNames': _store.loadFavoriteNames(),
      'customNames':
          _store.loadCustomNames().map((e) => e.toJson()).toList(),
      'favoriteAffirmations': _store.loadFavoriteAffirmations(),
      'bumpPhotos':
          _store.loadBumpPhotos().map((e) => e.toJson()).toList(),
      'nutritionEntries':
          _store.loadNutritionEntries().map((e) => e.toJson()).toList(),
      'waterLogs':
          _store.loadWaterLogs().map((e) => e.toJson()).toList(),
    };

    final dir = await getApplicationDocumentsDirectory();
    final timestamp =
        DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
    final filePath = p.join(dir.path, 'pregnancy_backup_$timestamp.json');
    final file = File(filePath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
    return filePath;
  }

  /// Import data from a backup JSON file. Returns true if successful.
  Future<bool> importBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return false;

      final raw = await file.readAsString();
      final data = jsonDecode(raw) as Map<String, dynamic>;

      final version = data['version'] as int?;
      if (version == null || version < 1) return false;

      // Profile — only restore if none exists
      if (data['profile'] != null && _store.loadProfile() == null) {
        await _store.saveProfile(
          PregnancyProfile.fromJson(data['profile'] as Map<String, dynamic>),
        );
      }

      // Typed list restores
      if (data['symptomLogs'] != null) {
        final items = _castList(data['symptomLogs'])
            .map(SymptomLog.fromJson)
            .toList();
        await _store.saveSymptomLogs(items);
      }
      if (data['kickSessions'] != null) {
        final items = _castList(data['kickSessions'])
            .map(KickSession.fromJson)
            .toList();
        await _store.saveKickSessions(items);
      }
      if (data['contractions'] != null) {
        final items = _castList(data['contractions'])
            .map(Contraction.fromJson)
            .toList();
        await _store.saveContractions(items);
      }
      if (data['measurements'] != null) {
        final items = _castList(data['measurements'])
            .map(Measurement.fromJson)
            .toList();
        await _store.saveMeasurements(items);
      }
      if (data['memories'] != null) {
        final items = _castList(data['memories'])
            .map(MemoryEntry.fromJson)
            .toList();
        await _store.saveMemories(items);
      }
      if (data['journal'] != null) {
        final items = _castList(data['journal'])
            .map(JournalEntry.fromJson)
            .toList();
        await _store.saveJournal(items);
      }
      if (data['appointments'] != null) {
        final items = _castList(data['appointments'])
            .map(Appointment.fromJson)
            .toList();
        await _store.saveAppointments(items);
      }
      if (data['wellnessDays'] != null) {
        final items = _castList(data['wellnessDays'])
            .map(WellnessDay.fromJson)
            .toList();
        await _store.saveWellnessDays(items);
      }
      if (data['sleep'] != null) {
        final items = _castList(data['sleep'])
            .map(SleepEntry.fromJson)
            .toList();
        await _store.saveSleep(items);
      }
      if (data['cravings'] != null) {
        final items = _castList(data['cravings'])
            .map(CravingEntry.fromJson)
            .toList();
        await _store.saveCravings(items);
      }
      if (data['postpartum'] != null) {
        final items = _castList(data['postpartum'])
            .map(PostpartumEntry.fromJson)
            .toList();
        await _store.savePostpartum(items);
      }
      if (data['babyCare'] != null) {
        final items = _castList(data['babyCare'])
            .map(BabyCareEntry.fromJson)
            .toList();
        await _store.saveBabyCare(items);
      }
      if (data['growth'] != null) {
        final items = _castList(data['growth'])
            .map(GrowthEntry.fromJson)
            .toList();
        await _store.saveGrowth(items);
      }
      if (data['budget'] != null) {
        final items = _castList(data['budget'])
            .map(BudgetItem.fromJson)
            .toList();
        await _store.saveBudget(items);
      }
      if (data['contacts'] != null) {
        final items = _castList(data['contacts'])
            .map(EmergencyContact.fromJson)
            .toList();
        await _store.saveContacts(items);
      }

      // Simple lists
      if (data['vaccineDone'] != null) {
        await _store.saveVaccineDone(
            (data['vaccineDone'] as List<dynamic>).cast<String>());
      }
      if (data['favoriteNames'] != null) {
        await _store.saveFavoriteNames(
            (data['favoriteNames'] as List<dynamic>).cast<String>());
      }
      if (data['favoriteAffirmations'] != null) {
        await _store.saveFavoriteAffirmations(
            (data['favoriteAffirmations'] as List<dynamic>).cast<String>());
      }

      // Maps
      if (data['milestoneDates'] != null) {
        await _store.saveMilestoneDates(
          (data['milestoneDates'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v as String)),
        );
      }
      if (data['breathingCounts'] != null) {
        await _store.saveBreathingCounts(
          (data['breathingCounts'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v as int)),
        );
      }

      // Birth plan
      if (data['birthPlan'] != null) {
        await _store.saveBirthPlan(
          BirthPlan.fromJson(data['birthPlan'] as Map<String, dynamic>),
        );
      }

      // Weight goal
      if (data['weightGoal'] != null) {
        await _store.saveWeightGoal(
          WeightGoalConfig.fromJson(
              data['weightGoal'] as Map<String, dynamic>),
        );
      }

      // Bump photos (metadata only — files need to exist on device)
      if (data['bumpPhotos'] != null) {
        final items = _castList(data['bumpPhotos'])
            .map(BumpPhoto.fromJson)
            .toList();
        await _store.saveBumpPhotos(items);
      }

      // Nutrition entries
      if (data['nutritionEntries'] != null) {
        final items = _castList(data['nutritionEntries'])
            .map(NutritionEntry.fromJson)
            .toList();
        await _store.saveNutritionEntries(items);
      }
      if (data['waterLogs'] != null) {
        final items = _castList(data['waterLogs'])
            .map(WaterLog.fromJson)
            .toList();
        await _store.saveWaterLogs(items);
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  static List<Map<String, dynamic>> _castList(dynamic json) =>
      (json as List<dynamic>).cast<Map<String, dynamic>>();
}
