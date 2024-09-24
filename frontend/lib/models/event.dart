class Event {
  String title;
  String description;
  DateTime dateTime;
  String club; // Assuming this is a String representing Club ID
  String createdBy; // Assuming this is a String representing User ID
  List<String> participants;
  List<String> feedbacks;
  List<String> notifications;

  Event({
    required this.title,
    required this.description,
    required this.dateTime,
    required this.club,
    required this.createdBy,
    this.participants = const [],
    this.feedbacks = const [],
    this.notifications = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'club': club,
      'createdBy': createdBy,
      'participants': participants,
      'feedbacks': feedbacks,
      'notifications': notifications,
    };
  }

  static Event fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
      club: json['club'],
      createdBy: json['createdBy'],
      participants: List<String>.from(json['participants']),
      feedbacks: List<String>.from(json['feedbacks']),
      notifications: List<String>.from(json['notifications']),
    );
  }
}
