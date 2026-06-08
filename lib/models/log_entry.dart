import 'package:flutter/foundation.dart';

/// A daily symptom / mood log entry.
@immutable
class SymptomLog {
  const SymptomLog({
    required this.id,
    required this.date,
    required this.symptoms,
    required this.mood,
    this.note = '',
  });

  final String id;
  final DateTime date;
  final List<String> symptoms;

  /// Mood on a 1 (low) – 5 (great) scale, 0 means not set.
  final int mood;
  final String note;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'symptoms': symptoms,
        'mood': mood,
        'note': note,
      };

  factory SymptomLog.fromJson(Map<String, dynamic> json) => SymptomLog(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        symptoms: (json['symptoms'] as List<dynamic>).cast<String>(),
        mood: json['mood'] as int? ?? 0,
        note: json['note'] as String? ?? '',
      );
}

/// A recorded fetal kick-count session.
@immutable
class KickSession {
  const KickSession({
    required this.id,
    required this.start,
    required this.durationSeconds,
    required this.kicks,
  });

  final String id;
  final DateTime start;
  final int durationSeconds;
  final int kicks;

  Map<String, dynamic> toJson() => {
        'id': id,
        'start': start.toIso8601String(),
        'durationSeconds': durationSeconds,
        'kicks': kicks,
      };

  factory KickSession.fromJson(Map<String, dynamic> json) => KickSession(
        id: json['id'] as String,
        start: DateTime.parse(json['start'] as String),
        durationSeconds: json['durationSeconds'] as int,
        kicks: json['kicks'] as int,
      );
}

/// A single recorded contraction (start + end). Gaps between contractions are
/// derived from consecutive [start] times, so only the endpoints are stored.
@immutable
class Contraction {
  const Contraction({
    required this.id,
    required this.start,
    required this.end,
  });

  final String id;
  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);

  Map<String, dynamic> toJson() => {
        'id': id,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      };

  factory Contraction.fromJson(Map<String, dynamic> json) => Contraction(
        id: json['id'] as String,
        start: DateTime.parse(json['start'] as String),
        end: DateTime.parse(json['end'] as String),
      );
}

/// A measurement entry (weight in kg, systolic/diastolic BP).
@immutable
class Measurement {
  const Measurement({
    required this.id,
    required this.date,
    this.weightKg,
    this.systolic,
    this.diastolic,
  });

  final String id;
  final DateTime date;
  final double? weightKg;
  final int? systolic;
  final int? diastolic;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'weightKg': weightKg,
        'systolic': systolic,
        'diastolic': diastolic,
      };

  factory Measurement.fromJson(Map<String, dynamic> json) => Measurement(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        weightKg: (json['weightKg'] as num?)?.toDouble(),
        systolic: json['systolic'] as int?,
        diastolic: json['diastolic'] as int?,
      );
}

/// One day's wellness log: water glasses, prenatal vitamin, and mood.
/// Keyed by [dateKey] (yyyy-MM-dd) so there is exactly one entry per day.
@immutable
class WellnessDay {
  const WellnessDay({
    required this.dateKey,
    this.water = 0,
    this.vitamin = false,
    this.mood = 0,
  });

  final String dateKey;

  /// Glasses of water logged today.
  final int water;

  /// Whether the prenatal vitamin was taken.
  final bool vitamin;

  /// Mood on a 1 (low) – 5 (great) scale; 0 means not set.
  final int mood;

  bool get hasActivity => water > 0 || vitamin || mood > 0;

  WellnessDay copyWith({int? water, bool? vitamin, int? mood}) => WellnessDay(
        dateKey: dateKey,
        water: water ?? this.water,
        vitamin: vitamin ?? this.vitamin,
        mood: mood ?? this.mood,
      );

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'water': water,
        'vitamin': vitamin,
        'mood': mood,
      };

  factory WellnessDay.fromJson(Map<String, dynamic> json) => WellnessDay(
        dateKey: json['dateKey'] as String,
        water: json['water'] as int? ?? 0,
        vitamin: json['vitamin'] as bool? ?? false,
        mood: json['mood'] as int? ?? 0,
      );
}

/// The user's birth-plan answers (question id -> chosen option) plus free notes.
@immutable
class BirthPlan {
  const BirthPlan({this.answers = const {}, this.notes = ''});

  final Map<String, String> answers;
  final String notes;

  BirthPlan setAnswer(String questionId, String option) {
    final next = Map<String, String>.from(answers);
    next[questionId] = option;
    return BirthPlan(answers: next, notes: notes);
  }

  BirthPlan withNotes(String value) =>
      BirthPlan(answers: answers, notes: value);

  Map<String, dynamic> toJson() => {
        'answers': answers,
        'notes': notes,
      };

  factory BirthPlan.fromJson(Map<String, dynamic> json) => BirthPlan(
        answers: (json['answers'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, v as String)),
        notes: json['notes'] as String? ?? '',
      );
}

/// A single item in a checklist (hospital bag, to-do, etc.).
@immutable
class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.label,
    required this.category,
    this.done = false,
    this.custom = false,
  });

  final String id;
  final String label;

  /// Grouping header, e.g. "Mom", "Baby", "Documents". May be empty.
  final String category;
  final bool done;

  /// True if the user added this item (vs a preset), so it can be deleted.
  final bool custom;

  ChecklistItem copyWith({bool? done}) => ChecklistItem(
        id: id,
        label: label,
        category: category,
        done: done ?? this.done,
        custom: custom,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'category': category,
        'done': done,
        'custom': custom,
      };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        id: json['id'] as String,
        label: json['label'] as String,
        category: json['category'] as String? ?? '',
        done: json['done'] as bool? ?? false,
        custom: json['custom'] as bool? ?? false,
      );
}

/// A scheduled prenatal appointment.
@immutable
class Appointment {
  const Appointment({
    required this.id,
    required this.dateTime,
    required this.title,
    this.location = '',
    this.notes = '',
  });

  final String id;
  final DateTime dateTime;
  final String title;
  final String location;
  final String notes;

  bool get isPast => dateTime.isBefore(DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'title': title,
        'location': location,
        'notes': notes,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        title: json['title'] as String,
        location: json['location'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
      );
}

/// A memory captured for the "Time Capsule" digital baby book.
@immutable
class MemoryEntry {
  const MemoryEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.body,
  });

  final String id;
  final DateTime date;
  final String title;
  final String body;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'title': title,
        'body': body,
      };

  factory MemoryEntry.fromJson(Map<String, dynamic> json) => MemoryEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        title: json['title'] as String,
        body: json['body'] as String,
      );
}

/// A free-form pregnancy journal entry, tagged with the pregnancy week it was
/// written and an optional mood (1–5, 0 = unset).
@immutable
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.body,
    this.week,
    this.mood = 0,
  });

  final String id;
  final DateTime date;
  final String title;
  final String body;

  /// Pregnancy week at time of writing (null if unknown).
  final int? week;

  /// Mood on a 1 (low) – 5 (great) scale; 0 means not set.
  final int mood;

  JournalEntry copyWith({
    String? title,
    String? body,
    int? mood,
  }) =>
      JournalEntry(
        id: id,
        date: date,
        title: title ?? this.title,
        body: body ?? this.body,
        week: week,
        mood: mood ?? this.mood,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'title': title,
        'body': body,
        'week': week,
        'mood': mood,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        title: json['title'] as String,
        body: json['body'] as String,
        week: json['week'] as int?,
        mood: json['mood'] as int? ?? 0,
      );
}

/// User-entered baseline for the weight-gain goal: pre-pregnancy weight and
/// height. Stored once; combined with logged weights to track progress.
@immutable
class WeightGoalConfig {
  const WeightGoalConfig({
    required this.prePregnancyKg,
    required this.heightCm,
  });

  final double prePregnancyKg;
  final double heightCm;

  Map<String, dynamic> toJson() => {
        'prePregnancyKg': prePregnancyKg,
        'heightCm': heightCm,
      };

  factory WeightGoalConfig.fromJson(Map<String, dynamic> json) =>
      WeightGoalConfig(
        prePregnancyKg: (json['prePregnancyKg'] as num).toDouble(),
        heightCm: (json['heightCm'] as num).toDouble(),
      );
}

/// The kind of an emergency / important contact.
enum ContactKind { doctor, hospital, partner, family, ambulance, other }

extension ContactKindMeta on ContactKind {
  String get label => switch (this) {
        ContactKind.doctor => 'Doctor / OB',
        ContactKind.hospital => 'Hospital',
        ContactKind.partner => 'Partner',
        ContactKind.family => 'Family',
        ContactKind.ambulance => 'Ambulance',
        ContactKind.other => 'Other',
      };
}

/// A saved important/emergency contact with a phone number for quick dialing.
@immutable
class EmergencyContact {
  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.kind = ContactKind.other,
    this.note = '',
  });

  final String id;
  final String name;
  final String phone;
  final ContactKind kind;
  final String note;

  EmergencyContact copyWith({
    String? name,
    String? phone,
    ContactKind? kind,
    String? note,
  }) =>
      EmergencyContact(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        kind: kind ?? this.kind,
        note: note ?? this.note,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'kind': kind.name,
        'note': note,
      };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        kind: ContactKind.values.firstWhere(
          (k) => k.name == json['kind'],
          orElse: () => ContactKind.other,
        ),
        note: json['note'] as String? ?? '',
      );
}

/// Spending category for the baby budget planner.
enum BudgetCategory { nursery, gear, clothing, feeding, medical, postpartum, other }

extension BudgetCategoryLabel on BudgetCategory {
  String get label => switch (this) {
        BudgetCategory.nursery => 'Nursery',
        BudgetCategory.gear => 'Baby gear',
        BudgetCategory.clothing => 'Clothing',
        BudgetCategory.feeding => 'Feeding',
        BudgetCategory.medical => 'Medical',
        BudgetCategory.postpartum => 'Postpartum',
        BudgetCategory.other => 'Other',
      };
}

/// A single planned baby/pregnancy expense, with budgeted vs actual spend.
@immutable
class BudgetItem {
  const BudgetItem({
    required this.id,
    required this.title,
    required this.category,
    required this.budgeted,
    this.spent = 0,
    this.paid = false,
  });

  final String id;
  final String title;
  final BudgetCategory category;
  final double budgeted;
  final double spent;
  final bool paid;

  BudgetItem copyWith({
    String? title,
    BudgetCategory? category,
    double? budgeted,
    double? spent,
    bool? paid,
  }) =>
      BudgetItem(
        id: id,
        title: title ?? this.title,
        category: category ?? this.category,
        budgeted: budgeted ?? this.budgeted,
        spent: spent ?? this.spent,
        paid: paid ?? this.paid,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category.name,
        'budgeted': budgeted,
        'spent': spent,
        'paid': paid,
      };

  factory BudgetItem.fromJson(Map<String, dynamic> json) => BudgetItem(
        id: json['id'] as String,
        title: json['title'] as String,
        category: BudgetCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => BudgetCategory.other,
        ),
        budgeted: (json['budgeted'] as num).toDouble(),
        spent: (json['spent'] as num?)?.toDouble() ?? 0,
        paid: json['paid'] as bool? ?? false,
      );
}

/// Primary sleeping position for a night. Left side is recommended in the
/// third trimester for blood flow.
enum SleepSide { left, right, back, unset }

extension SleepSideLabel on SleepSide {
  String get label => switch (this) {
        SleepSide.left => 'Left side',
        SleepSide.right => 'Right side',
        SleepSide.back => 'On back',
        SleepSide.unset => 'Not set',
      };
}

/// A single night's sleep log.
@immutable
class SleepEntry {
  const SleepEntry({
    required this.id,
    required this.date,
    required this.hours,
    this.quality = 0,
    this.side = SleepSide.unset,
    this.note = '',
  });

  final String id;
  final DateTime date;

  /// Hours slept.
  final double hours;

  /// Quality on a 1 (poor) – 5 (great) scale; 0 means unset.
  final int quality;
  final SleepSide side;
  final String note;

  SleepEntry copyWith({
    double? hours,
    int? quality,
    SleepSide? side,
    String? note,
  }) =>
      SleepEntry(
        id: id,
        date: date,
        hours: hours ?? this.hours,
        quality: quality ?? this.quality,
        side: side ?? this.side,
        note: note ?? this.note,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'hours': hours,
        'quality': quality,
        'side': side.name,
        'note': note,
      };

  factory SleepEntry.fromJson(Map<String, dynamic> json) => SleepEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        hours: (json['hours'] as num).toDouble(),
        quality: json['quality'] as int? ?? 0,
        side: SleepSide.values.firstWhere(
          (s) => s.name == json['side'],
          orElse: () => SleepSide.unset,
        ),
        note: json['note'] as String? ?? '',
      );
}

/// Whether a logged food item is a craving or an aversion.
enum CravingKind { craving, aversion }

extension CravingKindLabel on CravingKind {
  String get label =>
      this == CravingKind.craving ? 'Craving' : 'Aversion';
}

/// A logged pregnancy craving or aversion for a food/drink.
@immutable
class CravingEntry {
  const CravingEntry({
    required this.id,
    required this.date,
    required this.item,
    required this.kind,
    this.intensity = 0,
    this.note = '',
    this.week,
  });

  final String id;
  final DateTime date;
  final String item;
  final CravingKind kind;

  /// Strength on a 1 (mild) – 5 (intense) scale; 0 means unset.
  final int intensity;
  final String note;

  /// Pregnancy week at time of logging (null if unknown).
  final int? week;

  CravingEntry copyWith({
    String? item,
    CravingKind? kind,
    int? intensity,
    String? note,
  }) =>
      CravingEntry(
        id: id,
        date: date,
        item: item ?? this.item,
        kind: kind ?? this.kind,
        intensity: intensity ?? this.intensity,
        note: note ?? this.note,
        week: week,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'item': item,
        'kind': kind.name,
        'intensity': intensity,
        'note': note,
        'week': week,
      };

  factory CravingEntry.fromJson(Map<String, dynamic> json) => CravingEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        item: json['item'] as String,
        kind: CravingKind.values.firstWhere(
          (k) => k.name == json['kind'],
          orElse: () => CravingKind.craving,
        ),
        intensity: json['intensity'] as int? ?? 0,
        note: json['note'] as String? ?? '',
        week: json['week'] as int?,
      );
}
