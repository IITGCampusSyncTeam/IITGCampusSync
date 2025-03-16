import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:frontend/apis/protected.dart';
import 'package:frontend/models/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/endpoints.dart';
import '../../screens/login_screen.dart';

Future<void> authenticate() async {
  try {
    final result = await FlutterWebAuth.authenticate(
      url: AuthEndpoints.getAccess,
      callbackUrlScheme: "iitgsync",
    );
    print("🟡 Authentication result: $result");

    final accessToken = Uri.parse(result).queryParameters['token'];
    final userDetail = Uri.parse(result).queryParameters['user'];
    print("🟡 access_token: $accessToken");
    print("🟡 Raw User Detail from API: $userDetail");

    if (accessToken == null || userDetail == null) {
      throw ('Access token or user detail not found');
    }

    try {
      // Decode URL-encoded userDetail string
      String decodedUserString = Uri.decodeComponent(userDetail);

      // Clean up unsupported elements in the JSON string to make it JSON-compliant
      decodedUserString = decodedUserString
          .replaceAll("new ObjectId(", "")  // Remove new ObjectId(
          .replaceAll(")", "")  // Remove closing )
          .replaceAllMapped(
        RegExp(r"'_id':\s*'([^']*)'"),  // Fix _id formatting
            (match) => '"_id": "${match[1]}"',
      )
          .replaceAllMapped(
        RegExp(r"'(\w+)':\s*'([^']*)'"),  // Convert 'key': 'value' -> "key": "value"
            (match) => '"${match[1]}": "${match[2]}"',
      )
          .replaceAllMapped(
        RegExp(r"'(\w+)':\s*(\d+)"),  // Convert 'key': number -> "key": number
            (match) => '"${match[1]}": ${match[2]}',
      )
          .replaceAll("'", '"')  // Ensure all remaining single quotes are replaced by double quotes
          .replaceAll(",\n}", "\n}");  // Remove trailing commas

      // Debug print cleaned-up JSON string
      print("🟢 Cleaned User JSON (Before Decoding): $decodedUserString");

      // Parse JSON string
      final Map<String, dynamic> decodedUserJson = jsonDecode(decodedUserString);

      // Debug parsed JSON
      print("🔵 Parsed User Data: $decodedUserJson");
      print("🔵 Parsed Tags: ${decodedUserJson['tag']}");

      // Ensure 'tag' field is properly formatted as a list
      if (decodedUserJson.containsKey('tag') && decodedUserJson['tag'] is List) {
        decodedUserJson['tag'] = List<Map<String, dynamic>>.from(decodedUserJson['tag']);
      } else {
        decodedUserJson['tag'] = [];
      }

      // Debug cleaned-up tag data
      print("🟠 Final Processed Tags: ${decodedUserJson['tag']}");

      // Create User object from JSON
      final User user = User.fromJson(decodedUserJson);

      // Debug before storing
      print("🟣 Final User JSON to Store: ${jsonEncode(user.toJson())}");

      // Store user data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));
      await prefs.setString('access_token', accessToken);

      // Retrieve & print what was actually stored
      String? storedUserJson = prefs.getString('user_data');
      print("✅ Stored User Data in SharedPreferences: $storedUserJson");

      print("✅ User data saved successfully!");
    } catch (e) {
      print('❌ Error in parsing user data: $e');
      rethrow;
    }
  } catch (e) {
    print('❌ Error in authentication: $e');
    rethrow;
  }
}


Future<void> logoutHandler(context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const login()),
        (route) => false,
  );
}

Future<bool> isLoggedIn() async {
  var access = await getAccessToken();
  return access != 'error';
}
