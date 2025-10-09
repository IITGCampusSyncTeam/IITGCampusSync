import 'dart:convert';
import 'package:frontend/constants/endpoints.dart';
import 'package:frontend/models/club_follow_model.dart';
import 'package:http/http.dart' as http;

class ClubRepository {
  const ClubRepository();

  Future<List<Club>> fetchClubs() async {
    final response = await http.get(
      Uri.parse(ClubFollowEndpoints.getAllClubs()),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Club.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load clubs: ${response.statusCode}");
    }
  }

  Future<void> followClub(String clubId) async {
    final response = await http.post(
      Uri.parse(ClubFollowEndpoints.followClub(clubId)),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to follow club: ${response.statusCode}");
    }
  }

  Future<void> unfollowClub(String clubId) async {
    final response = await http.post(
      Uri.parse(ClubFollowEndpoints.unfollowClub(clubId)),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to unfollow club: ${response.statusCode}");
    }
  }
}
