import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/constants/endpoints.dart';
import 'package:frontend/apis/protected.dart';

class UserTagAPI {
  // Fetch available tags from the backend
  static Future<List<Map<String, String>>> fetchAvailableTags() async {
    try {
      final response = await http.get(Uri.parse(UserTag.getAvailableTags));

      if (response.statusCode == 200) {
        List<dynamic> fetchedTags = jsonDecode(response.body);
        return fetchedTags.map((tag) {
          return {
            "id": tag["_id"]?.toString() ?? "",
            "name": tag["title"]?.toString() ?? "Unknown",
          };
        }).toList();
      } else {
        print("Failed to fetch tags");
        return [];
      }
    } catch (e) {
      print("Error fetching tags: $e");
      return [];
    }
  }

  // Add a tag for the user
  static Future<bool> addTag(String email, String tagId) async {
    final token = await getAccessToken();
    if (token == 'error') {
      print("Error: Authentication required!");
      return false;
    }

    try {
      final url = Uri.parse(UserTag.addTag(email, tagId));

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error adding tag: $e");
      return false;
    }
  }

  // Remove a tag from the user
  static Future<bool> removeTag(String email, String tagId) async {
    final token = await getAccessToken();
    if (token == 'error') {
      print("Error: Authentication required!");
      return false;
    }

    try {
      final response = await http.delete(
        Uri.parse(UserTag.removeTag(email, tagId)),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error removing tag: $e");
      return false;
    }
  }
}
