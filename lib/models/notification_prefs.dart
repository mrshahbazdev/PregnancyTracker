/// Notification preference settings.
class NotificationPrefs {
  const NotificationPrefs({
    this.wellnessEnabled = false,
    this.wellnessHour = 9,
    this.wellnessMinute = 0,
    this.weeklyEnabled = false,
    this.weeklyDay = DateTime.monday,
    this.weeklyHour = 10,
    this.appointmentEnabled = true,
  });

  final bool wellnessEnabled;
  final int wellnessHour;
  final int wellnessMinute;
  final bool weeklyEnabled;
  final int weeklyDay;
  final int weeklyHour;
  final bool appointmentEnabled;

  NotificationPrefs copyWith({
    bool? wellnessEnabled,
    int? wellnessHour,
    int? wellnessMinute,
    bool? weeklyEnabled,
    int? weeklyDay,
    int? weeklyHour,
    bool? appointmentEnabled,
  }) =>
      NotificationPrefs(
        wellnessEnabled: wellnessEnabled ?? this.wellnessEnabled,
        wellnessHour: wellnessHour ?? this.wellnessHour,
        wellnessMinute: wellnessMinute ?? this.wellnessMinute,
        weeklyEnabled: weeklyEnabled ?? this.weeklyEnabled,
        weeklyDay: weeklyDay ?? this.weeklyDay,
        weeklyHour: weeklyHour ?? this.weeklyHour,
        appointmentEnabled: appointmentEnabled ?? this.appointmentEnabled,
      );

  Map<String, dynamic> toJson() => {
        'wellnessEnabled': wellnessEnabled,
        'wellnessHour': wellnessHour,
        'wellnessMinute': wellnessMinute,
        'weeklyEnabled': weeklyEnabled,
        'weeklyDay': weeklyDay,
        'weeklyHour': weeklyHour,
        'appointmentEnabled': appointmentEnabled,
      };

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) =>
      NotificationPrefs(
        wellnessEnabled: json['wellnessEnabled'] as bool? ?? false,
        wellnessHour: json['wellnessHour'] as int? ?? 9,
        wellnessMinute: json['wellnessMinute'] as int? ?? 0,
        weeklyEnabled: json['weeklyEnabled'] as bool? ?? false,
        weeklyDay: json['weeklyDay'] as int? ?? DateTime.monday,
        weeklyHour: json['weeklyHour'] as int? ?? 10,
        appointmentEnabled: json['appointmentEnabled'] as bool? ?? true,
      );
}
