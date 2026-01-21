import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/apis/UserTag/userTag_api.dart';
import 'package:frontend/constants/endpoints.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/screens/login_options_screen.dart';

import 'package:frontend/screens/multi_tag_screen/tag_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String name = '', email = '', roll = '', branch = '', website = '';
  bool isClub = false;
  bool isAdding = false;
  List<String> usertags = [];
  //user email
  // Empty = not signed in
  String? userEmail;
  //String? userEmail = "any@iitg.ac.in"; (for testing without login)

  @override
  void initState() {
    super.initState();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginOptionsScreen()),
      (route) => false,
    );
  }

  Future<List<String>> getUserTags() async {
    if (userEmail == null || userEmail!.isEmpty) {
      _showSnackBar(
        "Please sign in to see your info!",
        backgroundColor: Colors.redAccent,
        icon: Icons.error_outline,
      );
      log("User not signed in — cannot update tags");
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse(UserTag.getUserTags(userEmail!)),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        log("User Tags fetched successfully for $userEmail");
        final data = jsonDecode(response.body);

        if (data is List) {
          return data
              .map<String>((tag) => tag is Map<String, dynamic>
                  ? tag['title'].toString()
                  : tag.toString())
              .toList();
        } else if (data is Map && data['tags'] is List) {
          return (data['tags'] as List)
              .map<String>((tag) => tag is Map<String, dynamic>
                  ? tag['title'].toString()
                  : tag.toString())
              .toList();
        } else {
          return [];
        }
      } else {
        final error = jsonDecode(response.body);
        _showSnackBar(
          "Error: ${error['error'] ?? 'Failed to fetch user tags'}",
          backgroundColor: Colors.redAccent,
          icon: Icons.error_outline,
        );
        log("Error fetching user tags: ${response.body}");
        return [];
      }
    } catch (e) {
      _showSnackBar(
        "An error occurred: $e",
        backgroundColor: Colors.redAccent,
        icon: Icons.error_outline,
      );
      log("Exception fetching user tags: $e");
      return [];
    }
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user_data');
    String? clubJson = prefs.getString('club_data');

    if (userJson != null) {
      final user = jsonDecode(userJson);
      isClub = user['isClub'] ?? false;

      String websiteFromClub = '';
      if (isClub && clubJson != null) {
        final clubData = jsonDecode(clubJson);
        websiteFromClub = clubData['websiteLink'] ?? '';
      }

      setState(() {
        name = user['name'] ?? '';
        isClub = user['isClub'] ?? false;
        website = websiteFromClub;
        email = user['email'] ?? '';
        roll = user['rollNumber']?.toString() ?? '';
        branch = user['department'] ?? '';
        userEmail = user['email'];
        // userEmail = "@iitg.ac.in"; // (for testing without login)
      });
    }
  }

  void _showSnackBar(
    String message, {
    Color backgroundColor = Colors.black87,
    IconData? icon,
  }) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (icon != null) Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name: $name",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Email: $email",
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[700])),
                    Text(isClub ? "Website: $website" : "Roll Number: $roll",
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[700])),
                    Text("Branch: $branch",
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[700])),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Flexible(
              child: FutureBuilder(
                  future: getUserTags(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error fetching tags"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text("No tags found",
                              style: TextStyle(fontSize: 16)));
                    }
                    final tags = snapshot.data!;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...tags.map((tag) => Chip(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              label: Text(tag,
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'SaansTrial',
                                  )),
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 0, 0),
                            ))
                      ],
                    );
                  }),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TagScreen()));
                },
                child: Text("Edit Interests Tags")),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: Icon(Icons.logout),
                label: Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
