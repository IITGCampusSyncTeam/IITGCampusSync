import 'dart:convert';
import 'dart:developer';
import 'package:frontend/constants/endpoints.dart';
import 'package:http/http.dart' as http;

class TagRepo {
  const TagRepo();

  // get all tags
  Future<List<Map<String, dynamic>>> getAvailableTags() async {
    try {
      final response = await http.get(Uri.parse(UserTag.getAvailableTags));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        log('Fetched ${data.length} tags');

        return data.map((tag) {
          return {
            '_id': tag['_id'],
            'title': tag['title'],
          };
        }).toList();
      } else {
        throw Exception('Failed to load tags: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching tags: $e');
      rethrow;
    }
  }

  // Get user tags
  Future<List<String>> getUserTags(String email) async {
    try {
      final response = await http.get(
        Uri.parse(UserTag.getUserTags(email)),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> tags = List<String>.from(data["tags"]);
        log('Fetched user tags: $tags');
        return tags;
      } else {
        log('Failed to fetch user tags: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (e) {
      log('Error fetching user tags: $e');
      rethrow;
    }
  }

  // update user tags
  Future<void> updateUserTags(String email, List<String> tagIds) async {
    try {
      final response = await http.put(
        Uri.parse(UserTag.updateUserTags as String),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'tagIds': tagIds,
        }),
      );

      if (response.statusCode == 200) {
        log("User tags updated successfully");
      } else {
        log("Failed to update user tags: ${response.statusCode}");
        throw Exception('Failed to update user tags');
      }
    } catch (e) {
      log('Error updating user tags: $e');
      rethrow;
    }
  }
}
