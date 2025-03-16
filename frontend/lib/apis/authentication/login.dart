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
    print("Authentication result: $result");

    final accessToken = Uri.parse(result).queryParameters['token'];
    final userDetail = Uri.parse(result).queryParameters['user'];
    print("access_token: $accessToken");
    print("user: $userDetail");

    if (accessToken == null || userDetail == null) {
      throw ('Access token or user detail not found');
    }

    try {
      // Decode URL-encoded userDetail string
      String decodedUserString = Uri.decodeComponent(userDetail);

      // Clean up unsupported elements in the JSON string to make it JSON-compliant
      decodedUserString = decodedUserString
          .replaceAll("new ObjectId(", "")
          .replaceAll(")", "")
          .replaceAllMapped(
        RegExp(r"_id:\s*'([^']*)'"),
            (match) => '"_id": "${match[1]}"',
      )
          .replaceAllMapped(
        RegExp(r"(\w+):\s*'([^']*)'"),
            (match) => '"${match[1]}": "${match[2]}"',
      )
          .replaceAllMapped(
        RegExp(r"(\w+):\s*(\d+)"),
            (match) => '"${match[1]}": ${match[2]}',
      )
          .replaceAllMapped(
        RegExp(r"(\w+):\s*\[\s*([\s\S]*?)\s*\]"),
            (match) => '"${match[1]}": [${match[2]}]',
      )
          .replaceAll("'", '"') // Ensure all single quotes are replaced by double quotes
          .replaceAll(",\n}", "\n}"); // Remove trailing commas

      // Debug print cleaned-up JSON string
      print("Cleaned User JSON: $decodedUserString");

      // Parse JSON string
      final Map<String, dynamic> decodedUserJson = jsonDecode(decodedUserString);

      // Ensure 'tag' field is properly formatted as a list of objects [{id, name}]
      if (decodedUserJson.containsKey('tag') && decodedUserJson['tag'] is List) {
        decodedUserJson['tag'] = List<Map<String, dynamic>>.from(decodedUserJson['tag']);
      } else {
        decodedUserJson['tag'] = [];
      }

      // Create User object from JSON
      final User user = User.fromJson(decodedUserJson);

      // Store user data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));
      await prefs.setString('access_token', accessToken);

      print("User data saved successfully!");
    } catch (e) {
      print('Error in parsing user data: $e');
      rethrow;
    }
  } catch (e) {
    print('Error in authentication: $e');
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
