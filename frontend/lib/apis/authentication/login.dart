import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:frontend/apis/protected.dart';
import 'package:frontend/models/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/endpoints.dart';
import '../../main.dart';
import '../../screens/login_screen.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

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

      // Ensure the JSON format is correct
      decodedUserString = decodedUserString
          .replaceAll("new ObjectId(", "\"")  // Convert `new ObjectId('...')` to `"..."`
          .replaceAll(")", "\"")  // Remove closing parenthesis
          .replaceAllMapped(
        RegExp(r"'(\w+)':\s*'([^']*)'"),  // Convert 'key': 'value' to "key": "value"
            (match) => '"${match[1]}": "${match[2]}"',
      )
          .replaceAllMapped(
        RegExp(r"'(\w+)':\s*(\d+)"),  // Convert 'key': number to "key": number
            (match) => '"${match[1]}": ${match[2]}',
      )
          .replaceAll("'", '"');  // Replace all single quotes with double quotes

      // Ensure it's enclosed in curly braces
      if (!decodedUserString.startsWith("{")) {
        decodedUserString = "{$decodedUserString}";
      }

      print("🟢 Cleaned User JSON (Before Decoding): $decodedUserString");

      // Parse JSON string
      final Map<String, dynamic> decodedUserJson = jsonDecode(decodedUserString);

      // Debugging parsed JSON
      print("🔵 Parsed User Data: $decodedUserJson");

      // Ensure 'tag' field is properly formatted
      if (decodedUserJson.containsKey('tag') && decodedUserJson['tag'] is List) {
        decodedUserJson['tag'] = List<String>.from(decodedUserJson['tag']);
      } else {
        decodedUserJson['tag'] = [];
      }

      // Convert to User object and store in SharedPreferences
      final User user = User.fromJson(decodedUserJson);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));

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