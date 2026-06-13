import 'package:flutter/foundation.dart';

/// Meal category for nutrition logging.
enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeLabel on MealType {
  String get label => switch (this) {
        MealType.breakfast => 'Breakfast',
        MealType.lunch => 'Lunch',
        MealType.dinner => 'Dinner',
        MealType.snack => 'Snack',
      };

  String get icon => switch (this) {
        MealType.breakfast => '🌅',
        MealType.lunch => '☀️',
        MealType.dinner => '🌙',
        MealType.snack => '🍎',
      };
}

/// A logged meal entry.
@immutable
class NutritionEntry {
  const NutritionEntry({
    required this.id,
    required this.date,
    required this.mealType,
    required this.foods,
    this.note = '',
    this.week,
  });

  final String id;
  final DateTime date;
  final MealType mealType;
  final List<String> foods;
  final String note;
  final int? week;

  NutritionEntry copyWith({
    MealType? mealType,
    List<String>? foods,
    String? note,
  }) =>
      NutritionEntry(
        id: id,
        date: date,
        mealType: mealType ?? this.mealType,
        foods: foods ?? this.foods,
        note: note ?? this.note,
        week: week,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'mealType': mealType.name,
        'foods': foods,
        'note': note,
        'week': week,
      };

  factory NutritionEntry.fromJson(Map<String, dynamic> json) =>
      NutritionEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        mealType: MealType.values.firstWhere(
          (m) => m.name == json['mealType'],
          orElse: () => MealType.snack,
        ),
        foods: (json['foods'] as List<dynamic>).cast<String>(),
        note: json['note'] as String? ?? '',
        week: json['week'] as int?,
      );
}

/// Daily water intake log.
@immutable
class WaterLog {
  const WaterLog({
    required this.date,
    this.glasses = 0,
  });

  final DateTime date;
  final int glasses;

  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  WaterLog copyWith({int? glasses}) => WaterLog(
        date: date,
        glasses: glasses ?? this.glasses,
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'glasses': glasses,
      };

  factory WaterLog.fromJson(Map<String, dynamic> json) => WaterLog(
        date: DateTime.parse(json['date'] as String),
        glasses: json['glasses'] as int? ?? 0,
      );
}
