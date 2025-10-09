import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/apis/UserTag/userTag_api.dart';
import 'package:frontend/screens/login_options_screen.dart';
import 'package:frontend/screens/multi_tag_screen/interest_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String name = '', email = '', roll = '', branch = '', website = '';
  bool isClub = false;
  bool isAdding = false;

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
      });
    }
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
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => InterestPage()));
                },
                child: Text("Yours Interests")),
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
