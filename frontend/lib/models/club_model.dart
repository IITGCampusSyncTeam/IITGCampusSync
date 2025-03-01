import 'package:frontend/models/merch_model.dart';  // ✅ Import Merch from merch_model.dart

class ClubMember {
  final String userId;
  final String responsibility;

  ClubMember({
    required this.userId,
    required this.responsibility,
  });

  factory ClubMember.fromJson(Map<String, dynamic> json) {
    return ClubMember(
      userId: json['userId'] ?? '',
      responsibility: json['responsibility'] ?? '',
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
  final List<ClubMember> members;
  final List<String> events;
  final String images;
  final String websiteLink;
  final List<Merch> merch;  // ✅ Now uses Merch from merch_model.dart

  Club({
    required this.id,
    required this.name,
    required this.description,
    required this.heads,
    required this.members,
    required this.events,
    required this.images,
    required this.websiteLink,
    required this.merch,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown Club',
      description: json['description'] ?? 'No description available',
      heads: List<String>.from(json['heads'] ?? []),
      members: (json['members'] as List<dynamic>?)
          ?.map((member) => ClubMember.fromJson(member))
          .toList() ??
          [],
      events: List<String>.from(json['events'] ?? []),
      images: json['images'] ?? '',
      websiteLink: json['websiteLink'] ?? '',
      merch: (json['merch'] as List<dynamic>?)
          ?.map((item) => Merch.fromJson(item)) // ✅ Now properly references Merch from merch_model.dart
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'heads': heads,
      'members': members.map((member) => member.toJson()).toList(),
      'events': events,
      'images': images,
      'websiteLink': websiteLink,
      'merch': merch.map((item) => item.toJson()).toList(),
    };
  }
}
