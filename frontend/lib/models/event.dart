import 'package:frontend/models/user_model.dart';

import 'club_model.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String? banner;
  final String? venue;
  final Club? club; // Using Club object
  final User? createdBy; // Using User object
  final List<String> participants;
  final List<String> feedbacks;
  final List<String> notifications;
  final List<dynamic>
      tag; // Changed to dynamic to handle either tag objects or strings
  final String status;
  final String? date; 
  final List<Map<String, dynamic>> itinerary;
  final List<String> prerequisites; 
  final List<Map<String, dynamic>> speakers; 
  final List<Map<String, dynamic>> resources;
  final List<Map<String, dynamic>> venueDetails; 
  final List<Map<String, dynamic>> links;
  final List<Map> pocs;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.banner,
    this.venue,
    this.club,
    this.createdBy,
    this.participants = const [],
    this.feedbacks = const [],
    this.notifications = const [],
    this.tag = const [],
    this.status = 'drafted',
    this.prerequisites = const [],
    this.itinerary = const [],
    this.date,
    this.speakers = const [],
    this.resources = const [],
    this.links = const [],
    this.pocs = const [],
    this.venueDetails = const []
  });

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'venue': venue,
      'banner': banner,
      'club': club?.id,
      'createdBy': createdBy?.id,
      'participants': participants,
      'feedbacks': feedbacks,
      'notifications': notifications,
      'tag': tag,
      'status': status,
      'itinerary': itinerary,
      'date': date,
      'speakers': speakers,
      'resources': resources,
      'venueDetails': venueDetails,
      'links': links,
      'pocs' : pocs,
      'prerequisites' : prerequisites,

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
      banner: json['banner'],
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
      itinerary: List<Map<String, dynamic>>.from(json['itinerary'] ?? []), 
      prerequisites: List<String>.from(json['prerequisites'] ?? []), 
      speakers: List<Map<String, dynamic>>.from(json['speakers'] ?? []), 
      resources: List<Map<String, dynamic>>.from(json['resources'] ?? []), 
      venueDetails: List<Map<String, dynamic>>.from(json['venueDetails'] ?? []), 
      links: List<Map<String, dynamic>>.from(json['links'] ?? []), 
      pocs: json['pocs'] != null
    ? (json['pocs'] as List)
        .where((e) => e is Map)
        .map((e) => Map<String, dynamic>.from(e))
        .toList()
    : [],
      date: json['date'], 

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
