import 'dart:convert';
import 'package:frontend/models/club_model.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:frontend/apis/protected.dart';
import 'package:frontend/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/endpoints.dart';
import '../../main.dart';
import '../../screens/login_screen.dart';
import '../../services/storage_service.dart';

Future<void> authenticate() async {

  final storageService = StorageService();

  try {
    final result = await FlutterWebAuth2.authenticate(
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

    await storageService.writeToken(accessToken);
    print("✅ Token saved successfully!");

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
      Map<String, dynamic> decodedUserJson = jsonDecode(decodedUserString);

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
      await prefs.setString('email', user.email);
      // Now fetch and send the FCM token
      String? token = await FirebaseMessaging.instance.getToken();
      sendFCMTokenToServer(token);
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print('Refreshed FCM Token: $newToken');
        sendFCMTokenToServer(newToken);
      });

      // Retrieve & print what was actually stored
      String? storedUserJson = prefs.getString('user_data');
      print("✅ Stored User Data in SharedPreferences: $storedUserJson");

      print("✅ User data saved successfully!");

      // try {
      //   final email = decodedUserJson['email'] ?? '';
      //   final response = await http.get(
      //     Uri.parse('${UserEndPoints.currentUser}/$email'),
      //     headers: {'Content-Type': 'application/json'},
      //   );
  
      //   if (response.statusCode == 200) {
      //     decodedUserJson = jsonDecode(response.body);
          
      //     // Ensure 'tag' field is properly formatted as a list
      //     if (decodedUserJson.containsKey('tag') && decodedUserJson['tag'] is List) {
      //       decodedUserJson['tag'] = List<Map<String, dynamic>>.from(decodedUserJson['tag']);
      //     } else {
      //       decodedUserJson['tag'] = [];
      //     }

      //     final User user = User.fromJson(decodedUserJson);
      //     await prefs.setString('user_data', jsonEncode(user.toJson()));
      //     String? storedUserJson = prefs.getString('user_data');
      //     print("✅ Stored User Data in SharedPreferences: $storedUserJson");

      //     print("✅ User data saved successfully!");

      //   } else {
      //     print('fetching user failed');
      //   }
      // } catch (e) {
      //   print('❌ Error in parsing user data: $e');
      // }

      final isClub = decodedUserJson['isClub'] ?? false;
      if(isClub) {
        try {
          final email = decodedUserJson['email'] ?? '';
          final response = await http.get(
            Uri.parse('${backend.uri}/api/clubs/c/$email'),
            headers: {'Content-Type': 'application/json'},
          );

          print('✅ statusCode: ${response.statusCode}');
    
          if (response.statusCode == 200) {
            final Map<String, dynamic> decodedClubJson = jsonDecode(response.body);

            if (decodedClubJson.containsKey('tag') && decodedClubJson['tag'] is List) {
              decodedClubJson['tag'] = List<Map<String, dynamic>>.from(decodedClubJson['tag']);
            } else {
              decodedClubJson['tag'] = [];
            }

            final Club club = Club.fromJson(decodedClubJson);
            await prefs.setString('club_data', jsonEncode(club.toJson()));

            String? storedClubJson = prefs.getString('club_data');
            print("✅ Stored Club Data in SharedPreferences: $storedClubJson");

            print("✅ Club data saved successfully!");

          } else {
            print('fetching club failed');
          }
        } catch (e) {
          print('❌ Error in parsing club data: $e');
        }
      }

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
  final storageService = StorageService();

  await storageService.deleteToken(); // Delete the secure token
  await prefs.clear(); // Clear all other saved data

  print("✅ All user data and tokens cleared on logout.");

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const login()),
        (route) => false,
  );
}

Future<bool> isLoggedIn() async {
  // CHECK FOR TOKEN IN SECURE STORAGE
  final storageService = StorageService();
  final token = await storageService.readToken();
  // The user is logged in if the token exists (is not null).
  return token != null;
}


