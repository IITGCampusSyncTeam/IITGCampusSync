import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/club_model.dart';
import 'package:frontend/config/auth_config.dart';

class ClubFollowService {
  static const String _baseUrl = "${AuthConfig.serverUrl}/api/user";

  /// Fetch all clubs
  static Future<List<Club>> getAllClubs() async {
    final url = Uri.parse("$_baseUrl/getbasicallclubs");
    print('📡 Fetching clubs from: $url');

    final response = await http.get(url);
    print('📨 Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Club.fromJson(json)).toList();
    } else {
      throw Exception('❌ Failed to load clubs: ${response.statusCode}');
    }
  }

  /// Follow a club
  static Future<void> followClub(String userId, String clubId) async {
    final url = Uri.parse("$_baseUrl/$clubId/follow");
    final response = await http.post(url, body: {'userId': userId});

    if (response.statusCode != 200) {
      throw Exception('❌ Failed to follow club: ${response.statusCode}');
    }
  }

  /// Unfollow a club
  static Future<void> unfollowClub(String userId, String clubId) async {
    final url = Uri.parse("$_baseUrl/$clubId/unfollow");
    final response = await http.post(url, body: {'userId': userId});

    if (response.statusCode != 200) {
      throw Exception('❌ Failed to unfollow club: ${response.statusCode}');
    }
  }

  /// Get subscribed (followed) club IDs
  static Future<List<String>> getSubscribedClubIds(String userId) async {
    final url = Uri.parse("$_baseUrl/getsubscribedclubs/$userId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((club) => club["_id"].toString()).toList();
    } else {
      throw Exception(
          '❌ Failed to fetch subscribed clubs: ${response.statusCode}');
    }
  }
}
