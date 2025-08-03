import 'package:frontend/models/event.dart';
import 'package:frontend/models/userModel.dart';
import 'package:frontend/models/club_model.dart';

class Tag {
  final String id;
  final String title;
  final List<String> events;
  final DateTime createdAt;
  final List<String> users;
  final List<String> clubs;

  Tag({
    required this.id,
    required this.title,
    this.events = const [],
    required this.createdAt,
    this.users = const [],
    this.clubs = const [],
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      events: parseStringList(json['events']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      users: parseStringList(json['users']),
      clubs: parseStringList(json['clubs']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'events': events,
      'createdAt': createdAt.toIso8601String(),
      'users': users,
      'clubs': clubs,
    };
  }
}

