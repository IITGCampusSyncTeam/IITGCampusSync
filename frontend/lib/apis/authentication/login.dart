import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;

import '../../constants/endpoints.dart';
import '../../screens/login_screen.dart';
import '../protected.dart';

Future<void> authenticate() async {
  try {
    print("Attempting to authenticate...");

    final result = await FlutterWebAuth.authenticate(
        url: AuthEndpoints.getAccess, callbackUrlScheme: "iitgsync");

    print("Authentication result: $result");

    final code = Uri.parse(result).queryParameters['code'];

    if (code != null) {
      print("Authorization code received: $code");
      await exchangeCodeForToken(code);
    } else {
      print("Authorization code is null. Something went wrong.");
    }
  } on PlatformException catch (e) {
    print("PlatformException caught during authentication: $e");
    rethrow;
  } catch (e) {
    print("Error during authentication: $e");
    rethrow;
  }
}

Future<void> exchangeCodeForToken(String authCode) async {
  final tokenUrl = Uri.parse(tokenlink.Tokenlink);
  print("Exchanging authorization code for token...");

  try {
    final response = await http.post(
      tokenUrl,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': clientid.Clientid,
        'grant_type': 'authorization_code',
        'code': authCode,
        'redirect_uri': redirecturi.Redirecturi,
        'scope': 'offline_access User.Read',
      },
    );

    print("Token exchange response status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final tokenData = json.decode(response.body);
      final accessToken = tokenData['access_token'];

      print("Access token received: $accessToken");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);

      print("Access token stored in SharedPreferences.");
    } else {
      print('Failed to exchange authorization code for token. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Token exchange failed');
    }
  } catch (e) {
    print('Error during token exchange: $e');
    throw e;
  }
}

Future<void> logoutHandler(context) async {
  final prefs = await SharedPreferences.getInstance();
  print("Clearing SharedPreferences and logging out...");

  prefs.clear();

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => const login(),
    ),
        (route) => false,
  );

  print("User logged out successfully.");
}

Future<bool> isLoggedIn() async {
  var access = await getAccessToken();
  print("Checking login status...");

  if (access != 'error') {
    print("User is logged in.");
    return true;
  } else {
    print("User is not logged in.");
    return false;
  }
}

