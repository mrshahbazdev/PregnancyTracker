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
