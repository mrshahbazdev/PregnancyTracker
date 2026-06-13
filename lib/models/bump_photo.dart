import 'package:flutter/foundation.dart';

/// A weekly bump photo entry stored with local file path.
@immutable
class BumpPhoto {
  const BumpPhoto({
    required this.id,
    required this.date,
    required this.week,
    required this.filePath,
    this.note = '',
  });

  final String id;
  final DateTime date;
  final int week;
  final String filePath;
  final String note;

  BumpPhoto copyWith({String? note}) => BumpPhoto(
        id: id,
        date: date,
        week: week,
        filePath: filePath,
        note: note ?? this.note,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'week': week,
        'filePath': filePath,
        'note': note,
      };

  factory BumpPhoto.fromJson(Map<String, dynamic> json) => BumpPhoto(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        week: json['week'] as int,
        filePath: json['filePath'] as String,
        note: json['note'] as String? ?? '',
      );
}
