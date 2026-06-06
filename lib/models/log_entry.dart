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
