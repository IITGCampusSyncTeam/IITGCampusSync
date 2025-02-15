class CalendarEvent {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime reminderTime;

  CalendarEvent(
      {required this.id,
      required this.title,
      required this.startTime,
      required this.reminderTime});

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['_id'],
      title: json['title'],
      startTime: DateTime.parse(json['dateTime']),
      reminderTime: DateTime.parse(json['dateTime'])
          .subtract(const Duration(minutes: 15)),
    );
  }
}
