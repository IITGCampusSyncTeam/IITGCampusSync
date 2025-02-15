import 'dart:convert';

import 'package:frontend/apis/authentication/login.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/endpoints.dart';
import 'package:frontend/apis/protected.dart';
import 'dart:io';





Future<Map<String, String>?> fetchUserDetails() async {
  final header = await getAccessToken();
  print(header);
  if (header == 'error') {
    throw ('token not found');
  }
  try {
    final resp = await http.get(
      Uri.parse(UserEndPoints.currentUser),
      headers: {
        "Authorization": "Bearer $header",//make sure to include Bearer
        "Content-Type": "application/json",
      },
    );
    print('Response headers: ${resp.headers}');

    if (resp.statusCode == 200) {
      final Map<String, dynamic> userData = json.decode(resp.body);

      // Extract user details
      final String name = userData['name'];
      final String degree = userData['degree'];
      final String mail = userData['email'];
      final String roll = userData['rollNumber'];
      final String branch = userData['department'];

      print("Name: $name");
      print("Degree: $degree");
      print("Email: $mail");
      print("Roll: $roll");
      print("Branch: $branch");

      // Return the data as a map
      return {
        'name': name,
        'email': mail,
        'roll': roll,
        'branch': branch,
      };
    }


  } catch (e) {
    print("error is: $e");
    rethrow;
  }
}

