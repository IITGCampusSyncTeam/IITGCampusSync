import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/apis/UserTag/userTag_api.dart';
import 'package:frontend/screens/login_options_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String name = '', email = '', roll = '', branch = '', website = '';
  bool isClub = false;
  List<String> tags = []; // List of tag IDs
  List<Map<String, String>> availableTags = []; // All tags with id and name
  bool isAdding = false;

  @override
  void initState() {
    super.initState();
    fetchAvailableTags(); // Load available tags first
    fetchUserData();      // Then fetch user info
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

        // Extract tag IDs only
        tags = (user['tag'] as List<dynamic>?)
            ?.map((tag) => tag['id'].toString())
            .toList() ?? [];
      });
    }
  }

  Future<void> fetchAvailableTags() async {
    List<Map<String, String>>? fetchedTags = await UserTagAPI.fetchAvailableTags();
    if (fetchedTags != null) {
      setState(() {
        availableTags = fetchedTags;
      });
    } else {
      showSnackbar("Failed to fetch tags");
    }
  }

  Future<void> addTag(String tagId) async {
    if (isAdding) return;
    isAdding = true;

    String cleanedTagId = tagId.trim().toLowerCase();

    if (tags.any((t) => t.trim().toLowerCase() == cleanedTagId)) {
      showSnackbar("Tag already added.");
      isAdding = false;
      return;
    }

    bool success = await UserTagAPI.addTag(email, cleanedTagId);
    if (success) {
      setState(() {
        tags.add(cleanedTagId);
      });
      updateLocalUserData();
      showSnackbar("Tag added successfully!");
    } else {
      showSnackbar("Failed to add tag");
    }

    isAdding = false;
  }

  Future<void> removeTag(String tagId) async {
    bool success = await UserTagAPI.removeTag(email, tagId);
    if (success) {
      setState(() {
        tags.remove(tagId);
      });
      updateLocalUserData();
      showSnackbar("Tag removed successfully!");
    } else {
      showSnackbar("Failed to remove tag");
    }
  }

  Future<void> updateLocalUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user_data');
    if (userJson != null) {
      final user = jsonDecode(userJson);

      final enrichedTags = tags.map((id) {
        final tag = availableTags.firstWhere(
          (tag) => tag['id'] == id,
          orElse: () => {'id': id, 'name': 'Unknown'},
        );
        return {'id': tag['id'], 'name': tag['name']};
      }).toList();

      user['tag'] = enrichedTags;
      await prefs.setString('user_data', jsonEncode(user));
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Email: $email",
                        style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                    Text(isClub ? "Website: $website" : "Roll Number: $roll",
                        style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                    Text("Branch: $branch",
                        style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Your Interests:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (tags.isEmpty)
              Text("No tags selected", style: TextStyle(color: Colors.red)),
            Wrap(
              spacing: 8.0,
              children: tags.map((tagId) {
                String tagName = availableTags.firstWhere(
                  (tag) => tag["id"] == tagId,
                  orElse: () => {"name": "Unknown"},
                )["name"]!;

                return Chip(
                  label: Text(tagName, style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.deepPurple,
                  deleteIconColor: Colors.white,
                  onDeleted: () => removeTag(tagId),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text("Discover More Tags:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: availableTags.isEmpty
                  ? Center(child: Text("No tags available", style: TextStyle(color: Colors.red)))
                  : ListView.builder(
                      itemCount: availableTags.length,
                      itemBuilder: (context, index) {
                        final tag = availableTags[index];
                        final bool isSelected = tags.contains(tag["id"]);

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 3,
                          child: ListTile(
                            title: Text(tag["name"]!,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : ElevatedButton(
                                    onPressed: () => addTag(tag["id"]!),
                                    child: Text("Add"),
                                  ),
                          ),
                        );
                      },
                    ),
            ),
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
