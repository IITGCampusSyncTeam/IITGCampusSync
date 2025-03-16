import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../apis/protected.dart';
import '../constants/endpoints.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String name = '', email = '', roll = '', branch = '';
  List<String> tags = []; // Store selected tag IDs
  List<Map<String, String>> availableTags = []; // Store tag ID & Name

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchAvailableTags();
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user_data');

    if (userJson != null) {
      final user = jsonDecode(userJson);
      setState(() {
        name = user['name'];
        email = user['email'];
        roll = user['rollNumber'].toString();
        branch = user['department'];
        tags = List<String>.from(user['tags'] ?? []);
      });
    }
  }

  Future<void> fetchAvailableTags() async {
    try {
      final response = await http.get(Uri.parse('${backend.uri}/api/tags/'));

      if (response.statusCode == 200) {
        List<dynamic> fetchedTags = jsonDecode(response.body);
        setState(() {
          availableTags = fetchedTags.map((tag) {
            return {
              "id": tag["_id"]?.toString() ?? "",
              "name": tag["title"]?.toString() ?? "Unknown",
            };
          }).toList();
        });
      } else {
        showSnackbar("Failed to fetch tags");
      }
    } catch (e) {
      showSnackbar("Error: $e");
    }
  }

  Future<void> addTag(String tagId) async {
    if (tags.contains(tagId)) return;

    final token = await getAccessToken();
    print("🟡 Retrieved Token: $token");
    if (token == 'error') {
      showSnackbar("Error: Authentication required!");
      return;
    }

    try {
      final url = Uri.parse('${backend.uri}/api/user/$email/addtag/$tagId');
      print("🔗 Sending request to: $url");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("🔴 Response status: ${response.statusCode}");
      print("🔴 Response body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          tags.add(tagId);
        });
        updateLocalUserData();
        showSnackbar("Tag added successfully!");
      } else {
        showSnackbar("Failed to add tag: ${response.body}");
      }
    } catch (e) {
      showSnackbar("Error: $e");
      print("🔴 Exception caught: $e");
    }
  }


  Future<void> removeTag(String tagId) async {
    if (!tags.contains(tagId)) return;

    final token = await getAccessToken();
    if (token == 'error') {
      showSnackbar("Error: Authentication required!");
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('${backend.uri}/api/user/$email/deletetag/$tagId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          tags.remove(tagId);
        });
        updateLocalUserData();
        showSnackbar("Tag removed successfully!");
      } else {
        showSnackbar("Failed to remove tag");
      }
    } catch (e) {
      showSnackbar("Error: $e");
    }
  }

  Future<void> updateLocalUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user_data');
    if (userJson != null) {
      final user = jsonDecode(userJson);
      user['tags'] = tags;
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
        title: Text("User Profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ User Info
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name: $name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Email: $email", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                    Text("Roll Number: $roll", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                    Text("Branch: $branch", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // ✅ Selected Tags (Chips)
            Text("Your Interests:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

            // ✅ Available Tags (Vertical List)
            Text("Discover More Tags:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                    child: ListTile(
                      title: Text(tag["name"]!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : ElevatedButton(
                        onPressed: () => addTag(tag["id"]!),
                        child: Text("Add"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
