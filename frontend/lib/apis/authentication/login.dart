import 'dart:convert';

import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/profile_screen.dart';



import '../../constants/endpoints.dart';

import 'package:frontend/models/userModel.dart';
import '../../screens/login_screen.dart';
import 'package:frontend/apis/protected.dart';
import 'package:frontend/apis/user/user.dart';
=======
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:frontend/apis/protected.dart';
import 'package:frontend/models/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/endpoints.dart';
import '../../screens/login_screen.dart';
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050

Future<void> authenticate() async {
  try {
    final result = await FlutterWebAuth.authenticate(
<<<<<<< HEAD
        url: AuthEndpoints.getAccess, callbackUrlScheme: "iitgsync");
    print("Authentication result: $result");

    final accessToken = Uri
        .parse(result)
        .queryParameters['token'];
    final userDetail = Uri
        .parse(result)
        .queryParameters['user'];
=======
      url: AuthEndpoints.getAccess,
      callbackUrlScheme: "iitgsync",
    );
    print("Authentication result: $result");

    final accessToken = Uri.parse(result).queryParameters['token'];
    final userDetail = Uri.parse(result).queryParameters['user'];
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
    print("access_token: $accessToken");
    print("user: $userDetail");

    if (accessToken == null || userDetail == null) {
<<<<<<< HEAD
      throw ('access token or user detail not found');
    }
=======
      throw ('Access token or user detail not found');
    }

>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
    try {
      // Decode URL-encoded userDetail string
      String decodedUserString = Uri.decodeComponent(userDetail);

      // Clean up unsupported elements in the JSON string to make it JSON-compliant
      decodedUserString = decodedUserString
          .replaceAll("new ObjectId(", "")
          .replaceAll(")", "")
          .replaceAllMapped(
<<<<<<< HEAD
          RegExp(r"_id:\s*'([^']*)'"),
              (match) => '"_id": "${match[1]}"'
      )
          .replaceAllMapped(
          RegExp(r"(\w+):\s*'([^']*)'"),
              (match) => '"${match[1]}": "${match[2]}"'
      )
          .replaceAllMapped(
          RegExp(r"(\w+):\s*(\d+)"),
              (match) => '"${match[1]}": ${match[2]}'
      )
          .replaceAllMapped(
          RegExp(r"(\w+):\s*\[\]"),
              (match) => '"${match[1]}": []'
      )
          .replaceAll(
          "'", '"') // Replace single quotes with double quotes for JSON
          .replaceAll(",\n}", "\n}"); // Remove trailing commas if they exist
=======
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
        RegExp(r"(\w+):\s*\[\]"),
            (match) => '"${match[1]}": []',
      )
          .replaceAll("'", '"') // Replace single quotes with double quotes for JSON
          .replaceAll(",\n}", "\n}") // Remove trailing commas
          .replaceAllMapped(
        RegExp(r"merchOrders:\s*\[([\s\S]*?)\]"),
            (match) {
          String cleanedList = match[1]!
              .split(',')
              .map((id) => '"${id.trim().replaceAll("'", "").replaceAll('"', "")}"')
              .join(', ');
          return '"merchOrders": [$cleanedList]';
        },
      );
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050

      // Debug print cleaned-up JSON string
      print("Cleaned User JSON: $decodedUserString");

      // Parse JSON string
      final decodedUserJson = jsonDecode(decodedUserString);

      // Create User object from JSON
      final User user = User.fromJson(decodedUserJson);

      // Store user data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));
      await prefs.setString('access_token', accessToken);
    } catch (e) {
      print('Error in parsing user data: $e');
      rethrow;
    }
<<<<<<< HEAD
  }
  catch (e) {
    print('Error in getting code');
=======
  } catch (e) {
    print('Error in getting code: $e');
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
    rethrow;
  }
}

<<<<<<< HEAD




Future<void> logoutHandler(context) async {
  final prefs = await SharedPreferences.getInstance();

  prefs.clear();

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => const login(),
    ),
        (route) => false,
=======
Future<void> logoutHandler(context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const login()),
    (route) => false,
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
  );
}

Future<bool> isLoggedIn() async {
  var access = await getAccessToken();
<<<<<<< HEAD

  if (access != 'error') {

    return true;
  } else {
    return false;
  }
}
=======
  return access != 'error';
}

// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_web_auth/flutter_web_auth.dart';
// import 'package:http/http.dart' as http;
// import 'package:frontend/screens/profile_screen.dart';
//
//
//
// import '../../constants/endpoints.dart';
//
// import 'package:frontend/models/userModel.dart';
// import '../../screens/login_screen.dart';
// import 'package:frontend/apis/protected.dart';
// import 'package:frontend/apis/user/user.dart';
//
// Future<void> authenticate() async {
//   try {
//     final result = await FlutterWebAuth.authenticate(
//         url: AuthEndpoints.getAccess, callbackUrlScheme: "iitgsync");
//     print("Authentication result: $result");
//
//     final accessToken = Uri
//         .parse(result)
//         .queryParameters['token'];
//     final userDetail = Uri
//         .parse(result)
//         .queryParameters['user'];
//     print("access_token: $accessToken");
//     print("user: $userDetail");
//
//     if (accessToken == null || userDetail == null) {
//       throw ('access token or user detail not found');
//     }
//     try {
//       // Decode URL-encoded userDetail string
//       String decodedUserString = Uri.decodeComponent(userDetail);
//
//       // Clean up unsupported elements in the JSON string to make it JSON-compliant
//       decodedUserString = decodedUserString
//           .replaceAll("new ObjectId(", "")
//           .replaceAll(")", "")
//           .replaceAllMapped(
//           RegExp(r"_id:\s*'([^']*)'"),
//               (match) => '"_id": "${match[1]}"'
//       )
//           .replaceAllMapped(
//           RegExp(r"(\w+):\s*'([^']*)'"),
//               (match) => '"${match[1]}": "${match[2]}"'
//       )
//           .replaceAllMapped(
//           RegExp(r"(\w+):\s*(\d+)"),
//               (match) => '"${match[1]}": ${match[2]}'
//       )
//           .replaceAllMapped(
//           RegExp(r"(\w+):\s*\[\]"),
//               (match) => '"${match[1]}": []'
//       )
//           .replaceAll(
//           "'", '"') // Replace single quotes with double quotes for JSON
//           .replaceAll(",\n}", "\n}"); // Remove trailing commas if they exist
//
//       // Debug print cleaned-up JSON string
//       print("Cleaned User JSON: $decodedUserString");
//
//       // Parse JSON string
//       final decodedUserJson = jsonDecode(decodedUserString);
//
//       // Create User object from JSON
//       final User user = User.fromJson(decodedUserJson);
//
//       // Store user data in SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('user_data', jsonEncode(user.toJson()));
//       await prefs.setString('access_token', accessToken);
//     } catch (e) {
//       print('Error in parsing user data: $e');
//       rethrow;
//     }
//   }
//   catch (e) {
//     print('Error in getting code');
//     rethrow;
//   }
// }
//
//
//
//
//
// Future<void> logoutHandler(context) async {
//   final prefs = await SharedPreferences.getInstance();
//
//   prefs.clear();
//
//   Navigator.of(context).pushAndRemoveUntil(
//     MaterialPageRoute(
//       builder: (context) => const login(),
//     ),
//         (route) => false,
//   );
// }
//
// Future<bool> isLoggedIn() async {
//   var access = await getAccessToken();
//
//   if (access != 'error') {
//
//     return true;
//   } else {
//     return false;
//   }
// }
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
