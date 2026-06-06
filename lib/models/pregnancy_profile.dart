import 'package:flutter/foundation.dart';

/// How the due date was determined.
enum DueDateMethod { lastPeriod, dueDate, conception, ivf }

extension DueDateMethodLabel on DueDateMethod {
  String get label => switch (this) {
        DueDateMethod.lastPeriod => 'Last period (LMP)',
        DueDateMethod.dueDate => 'Known due date',
        DueDateMethod.conception => 'Conception date',
        DueDateMethod.ivf => 'IVF transfer',
      };
}

/// The user's pregnancy profile. Due date is the single source of truth from
/// which gestational age (week/day) is derived.
@immutable
class PregnancyProfile {
  const PregnancyProfile({
    required this.name,
    required this.dueDate,
    required this.method,
  });

  final String name;
  final DateTime dueDate;
  final DueDateMethod method;

  /// A full-term pregnancy is counted as 280 days (40 weeks) from LMP.
  static const int totalDays = 280;

  DateTime get conceptionDate => dueDate.subtract(const Duration(days: 266));
  DateTime get lmpDate => dueDate.subtract(const Duration(days: totalDays));

  /// Days elapsed since the start of the pregnancy (LMP), clamped to [0, 280].
  int daysElapsedFrom(DateTime now) {
    final days = now.difference(lmpDate).inDays;
    if (days < 0) return 0;
    if (days > totalDays) return totalDays;
    return days;
  }

  int currentWeek(DateTime now) => (daysElapsedFrom(now) ~/ 7).clamp(0, 40);

  int currentDayOfWeek(DateTime now) => daysElapsedFrom(now) % 7;

  int daysRemaining(DateTime now) {
    final remaining = dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  double progress(DateTime now) =>
      (daysElapsedFrom(now) / totalDays).clamp(0.0, 1.0);

  String trimester(DateTime now) {
    final w = currentWeek(now);
    if (w < 13) return '1st trimester';
    if (w < 27) return '2nd trimester';
    return '3rd trimester';
  }

  PregnancyProfile copyWith({
    String? name,
    DateTime? dueDate,
    DueDateMethod? method,
  }) {
    return PregnancyProfile(
      name: name ?? this.name,
      dueDate: dueDate ?? this.dueDate,
      method: method ?? this.method,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'dueDate': dueDate.toIso8601String(),
        'method': method.name,
      };

  factory PregnancyProfile.fromJson(Map<String, dynamic> json) {
    return PregnancyProfile(
      name: json['name'] as String? ?? '',
      dueDate: DateTime.parse(json['dueDate'] as String),
      method: DueDateMethod.values.firstWhere(
        (m) => m.name == json['method'],
        orElse: () => DueDateMethod.dueDate,
      ),
    );
  }
}
