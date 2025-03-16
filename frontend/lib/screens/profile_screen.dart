import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/apis/protected.dart';
import '../constants/endpoints.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String email = '';
  String roll = '';
  String branch = '';

  TextEditingController hostelController = TextEditingController();
  TextEditingController roomController = TextEditingController();
  TextEditingController contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
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
        hostelController.text = user['hostel'] ?? ''; // Load hostel
        roomController.text = user['roomnum'] ?? ''; // Load room number
        contactController.text = user['contact'] ?? ''; // Load contact
      });
    }
  }

  Future<void> updateUserDetails() async {
    final token = await getAccessToken(); // Retrieve token
    if (token == 'error') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Authentication required!")),
      );
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('${backend.uri}/api/user/$email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'hostel': hostelController.text,
          'roomnum': roomController.text,
          'contact': contactController.text,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final updatedData = jsonDecode(response.body);
        print("Updated User Data: $updatedData");

        // Update only specific fields in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        String? userJson = prefs.getString('user_data');

        if (userJson != null) {
          Map<String, dynamic> existingUser = jsonDecode(userJson);

          // Only update the required fields
          existingUser['hostel'] = updatedData['hostel'];
          existingUser['roomnum'] = updatedData['roomnum'];
          existingUser['contact'] = updatedData['contact'];

          // Save updated data back
          await prefs.setString('user_data', jsonEncode(existingUser));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Profile updated successfully!")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: Text("Profile"),
        actions: [
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => login(),
                ),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileItem("Name", name),
                      SizedBox(height: 16),
                      _buildProfileItem("Roll Number", roll),
                      SizedBox(height: 16),
                      _buildProfileItem("Email", email),
                      SizedBox(height: 16),
                      _buildProfileItem("Branch", branch),
                      SizedBox(height: 16),
                      _buildEditableField("Hostel", hostelController),
                      SizedBox(height: 16),
                      _buildEditableField("Room Number", roomController),
                      SizedBox(height: 16),
                      _buildEditableField("Contact", contactController),
                      SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: updateUserDetails,
                          child: Text("Submit", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(20),
                            backgroundColor: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter $label",
          ),
        ),
      ],
    );
  }
}
