import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/endpoints.dart';
import 'package:frontend/apis/protected.dart'; // to get access token

class ClubTagAPI {
  //Fetch available tags from backend
  static Future<List<Map<String, String>>> fetchAvailableTags() async {
    try {
      final response = await http.get(Uri.parse(ClubTag.getAvailableTags));

      if (response.statusCode == 200) {
        List<dynamic> fetchedTags = jsonDecode(response.body);
        return fetchedTags.map((tag) {
          return {
            "id": tag["_id"]?.toString() ?? "",
            "name": tag["title"]?.toString() ?? "Unknown",
          };
        }).toList();
      } else {
        print("Failed to fetch club tags: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching club tags: $e");
      return [];
    }
  }

  //Add a tag to a club
  static Future<bool> addTag(String clubId, String tagId) async {
    final token = await getAccessToken();
    if (token == 'error') return false;

    try {
      final response = await http.post(
        Uri.parse(ClubTag.addTag(clubId, tagId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("Tag added successfully to club");
        return true;
      } else {
        print("Failed to add tag: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error adding tag to club: $e");
      return false;
    }
  }

  //Remove a tag from a club
  static Future<bool> removeTag(String clubId, String tagId) async {
    final token = await getAccessToken();
    if (token == 'error') return false;

    try {
      final response = await http.delete(
        Uri.parse(ClubTag.removeTag(clubId, tagId)),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print("Tag removed successfully from club");
        return true;
      } else {
        print("Failed to remove tag: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error removing tag from club: $e");
      return false;
    }
  }
}
