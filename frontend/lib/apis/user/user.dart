import 'dart:convert';

//import 'package:frontend/database/hive_store.dart';
import 'package:frontend/apis/authentication/login.dart';
//import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/endpoints.dart';
import 'package:frontend/apis/protected.dart';
import '../../utilities/branch_name.dart';





Future<Map<String, String>?> fetchUserDetails() async {
  final accessToken = await getAccessToken();
  print("Fetched access token: $accessToken");  // Debugging line

  if (accessToken == 'error') {
    print("No access token found!");
    return null;  // Return early if no token is found
  }

  final response = await http.get(
    Uri.parse(Userendpoints.getdetails),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> userData = json.decode(response.body);

    // Extract user details
    final String name = userData['displayName'];
    final String mail = userData['mail'];
    final String roll = userData['surname'];
    final String branch = calculateBranch(roll);

    print("Name: $name");
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

  } else {
    print("Failed to fetch user details: ${response.statusCode}");
    print("Response body: ${response.body}");  // Additional debugging line
    return null;
  }
}
