import 'dart:convert';
import 'package:frontend/screens/follow_club_system/club_model.dart';
import 'package:http/http.dart' as http;

class ClubRepository {
  final String baseUrl;

  ClubRepository({required this.baseUrl});

  Future<List<Club>> fetchClubs() async {
    final response = await http.get(Uri.parse("$baseUrl/clubs"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Club.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load clubs");
    }
  }

  Future<void> followClub(String clubId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/clubs/$clubId/follow"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to follow club");
    }
  }

  Future<void> unfollowClub(String clubId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/clubs/$clubId/unfollow"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to unfollow club");
    }
  }
}
