import 'package:frontend/models/user_model.dart';

import 'club_model.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String? venue;
  final Club? club; // Using Club object
  final User? createdBy; // Using User object
  final List<String> participants;
  final List<String> feedbacks;
  final List<String> notifications;
  final List<dynamic> tag; // Changed to dynamic to handle either tag objects or strings
  final String status;
  final List<RSVPItem> rsvp;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.venue,
    this.club,
    this.createdBy,
    this.participants = const [],
    this.feedbacks = const [],
    this.notifications = const [],
    this.tag = const [],
    this.status = 'drafted',
    this.rsvp = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'venue': venue,
      'club': club?.id,
      'createdBy': createdBy?.id,
      'participants': participants,
      'feedbacks': feedbacks,
      'notifications': notifications,
      'tag': tag,
      'status': status,
      'RSVP': rsvp.map((e) => e.toJson()).toList(),
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'])
          : DateTime.now(),
      venue: json['venue'] ?? '',
      club: json['club'] != null
          ? (json['club'] is Map ? Club.fromJson(json['club']) : null)
          : null,
      createdBy: json['createdBy'] != null
          ? (json['createdBy'] is Map ? User.fromJson(json['createdBy']) : null)
          : null,
      participants: parseStringList(json['participants']),
      feedbacks: List<String>.from(json['feedbacks'] ?? []),
      notifications: parseStringList(json['notifications']),
      tag: json['tag'] ??
          [], // Just pass the tag data as is, we'll handle it when displaying
      status: json['status'] ?? 'drafted',
      rsvp: json['RSVP'] != null
        ? (json['RSVP'] as List).map((e) => RSVPItem.fromJson(e)).toList()
        : [],
    );
  }

  // Helper method to extract tag titles
  List<String> getTagTitles() {
    List<String> tagTitles = [];

    for (var tagItem in tag) {
      // If the tag is a Map (object) with a title field
      if (tagItem is Map) {
        String title = tagItem['title'] ?? '';
        if (title.isNotEmpty) {
          tagTitles.add(title);
        }
      }
      // If the tag is already a String (fallback)
      else if (tagItem is String) {
        tagTitles.add(tagItem);
      }
    }

    return tagTitles.isEmpty ? ['Campus Event'] : tagTitles;
  }
}

class RSVPItem {
  final String userId;
  final String status;
  final DateTime timestamp;

  RSVPItem({required this.userId, required this.status, required this.timestamp});

  factory RSVPItem.fromJson(Map<String, dynamic> json) {
    return RSVPItem(
      userId: json['user']['_id'] ?? json['userId'] ?? '',
      status: json['status'] ?? 'yes',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
