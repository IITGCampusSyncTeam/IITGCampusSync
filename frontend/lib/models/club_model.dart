import 'package:frontend/models/merch_model.dart';
import 'package:frontend/models/userModel.dart';

// Helper function that handles different types of lists
List<String> parseStringList(dynamic jsonList) {
  if (jsonList == null) return [];

  if (jsonList is List) {
    return jsonList
        .map((item) {
      if (item is String) return item;
      if (item is Map && item.containsKey('_id')) return item['_id'].toString();
      return item.toString(); // fallback
    })
        .toList()
        .cast<String>();
  }
  return [];
}

// club_model.dart
class ClubMember {
  final String userId;
  final String responsibility;
  final User? user; // Added to store the populated user data

  ClubMember({
    required this.userId,
    required this.responsibility,
    this.user,
  });

  factory ClubMember.fromJson(Map<String, dynamic> json) {
    return ClubMember(
      userId: json['userId'] is Map
          ? json['userId']['_id'] ?? ''
          : json['userId'] ?? '',
      responsibility: json['responsibility'] ?? '',
      user: json['userId'] is Map
          ? User.fromJson(json['userId'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'responsibility': responsibility,
    };
  }
}

class Club {
  final String id;
  final String name;
  final String description;
  final List<String> heads;
  final String secretary;
  final List<ClubMember> members;
  final List<String> events;
  final String images;
  final String websiteLink;
  final List<String> tag;
  final List<Merch> merch;
  final List<String> followers;
  final List<String> files;

  Club({
    required this.id,
    required this.name,
    required this.description,
    required this.heads,
    required this.secretary,
    required this.members,
    required this.events,
    required this.images,
    required this.websiteLink,
    required this.tag,
    required this.merch,
    required this.followers,
    required this.files,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown Club',
      description: json['description'] ?? 'No description available',
      heads: parseStringList(json['heads']),
      secretary: json['secretary'] is Map
          ? json['secretary']['_id'] ?? ''
          : json['secretary'] ?? '',
      members: (json['members'] as List?)
          ?.map((member) => ClubMember.fromJson(member))
          .toList() ??
          [],
      events: parseStringList(json['events']),
      images: json['images'] ?? '',
      websiteLink: json['websiteLink'] ?? '',
      tag: parseStringList(json['tag']),
      merch: (json['merch'] as List?)
          ?.map((item) => Merch.fromJson(item))
          .toList() ??
          [],
      followers: parseStringList(json['followers']),
      files: parseStringList(json['files']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'heads': heads,
      'secretary': secretary,
      'members': members.map((member) => member.toJson()).toList(),
      'events': events,
      'images': images,
      'websiteLink': websiteLink,
      'tag': tag,
      'merch': merch.map((item) => item.toJson()).toList(),
      'followers': followers,
      'files': files,
    };
  }
}
