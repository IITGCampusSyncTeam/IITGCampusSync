import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/profile_screen.dart';



import '../../constants/endpoints.dart';

import 'package:frontend/models/userModel.dart';
import '../../screens/login_screen.dart';
import 'package:frontend/apis/protected.dart';
import 'package:frontend/apis/User/user.dart';

Future<void> authenticate() async {
  try {

    final result = await FlutterWebAuth.authenticate(
        url: AuthEndpoints.getAccess, callbackUrlScheme: "iitgsync");
    print(result);

    final accessToken = Uri.parse(result).queryParameters['token'];
    final userDetail = Uri.parse(result).queryParameters['user'];

    if (accessToken == null || userDetail == null) {
      throw ('access token or user detail not found');
    }

    // Decode the user data from the URL-encoded JSON string
    String decodedUserString = Uri.decodeComponent(userDetail);

    // Clean up unsupported elements in the JSON string
    decodedUserString = decodedUserString
        .replaceAll("new ObjectId(", "")
        .replaceAll(")", "")
        .replaceAllMapped(RegExp(r"_id:\s*'?([^,]+)'?"), (match) => '"_id": "${match[1]}"'); // Wrap _id values with quotes

    // Parse the cleaned JSON
    final decodedUserJson = jsonDecode(decodedUserString);
    final User user = User.fromJson(decodedUserJson);

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('access_token', accessToken);
    prefs.setString('user_data', jsonEncode(user.toJson()));

  } on PlatformException catch (_) {
    rethrow;
  } catch (e) {
    print('Error in getting code');
    rethrow;
  }
}





Future<void> logoutHandler(context) async {
  final prefs = await SharedPreferences.getInstance();

  prefs.clear();

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => const login(),
    ),
        (route) => false,
  );
}

Future<bool> isLoggedIn() async {
  var access = await getAccessToken();

  if (access != 'error') {

    return true;
  } else {
    return false;
  }
}
