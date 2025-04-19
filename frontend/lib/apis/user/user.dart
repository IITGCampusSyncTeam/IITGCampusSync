import 'dart:convert';

import 'package:frontend/apis/protected.dart';
import 'package:frontend/constants/endpoints.dart';
import 'package:http/http.dart' as http;

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
        "Authorization": "Bearer $header", //make sure to include Bearer
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

//for fetching events conducted by clubs the user is following
Future<List<dynamic>> getUserFollowedEvents() async {
  final header = await getAccessToken();
  print(header);
  if (header == 'error') {
    throw ('token not found');
  }

  try {
    final response = await http.get(
      Uri.parse(UserEndPoints.getUserFollowedEvents),
      headers: {
        "Authorization": "Bearer $header",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['events']; // List of upcoming events
    } else {
      print("Error: ${response.body}");
      return [];
    }
  } catch (e) {
    print("Error fetching events: $e");
    return [];
  }
}
