import 'dart:convert';
import 'package:http/http.dart' as http;

class UserTagAPI {
  static const String baseUrl = "http://10.0.2.2:3000/api/tags";

  // ✅ Fetch all available tags
  static Future<List<Map<String, String>>> fetchAvailableTags() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/all'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map<Map<String, String>>((tag) {
          return {
            "id": tag["_id"],
            "name": tag["title"], // Make sure it matches backend field
          };
        }).toList();
      } else {
        print("Failed to fetch tags: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching tags: $e");
    }
    return [];
  }

  // ✅ Update user's tags (Continue button)
  static Future<bool> updateUserTags(String email, List<String> tagIds) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/updateUserTags'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "tagIds": tagIds,
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Error updating tags: $e");
      return false;
    }
  }
}
