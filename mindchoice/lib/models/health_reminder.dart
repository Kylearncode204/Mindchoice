enum ReminderType {
  water,
  exercise,
  posture,
  eyeRest
}

class HealthReminder {
  final int id;
  final String title;
  final String description;
  final ReminderType type;
  final String time;
  final bool isEnabled;

  HealthReminder({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.time,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'time': time,
      'isEnabled': isEnabled ? 1 : 0,
    };
  }

  factory HealthReminder.fromMap(Map<String, dynamic> map) {
    return HealthReminder(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: ReminderType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
      time: map['time'],
      isEnabled: map['isEnabled'] == 1,
    );
  }
} 