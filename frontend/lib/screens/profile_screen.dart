import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        roomController.text = user['room'] ?? ''; // Load room number
        contactController.text = user['contact'] ?? ''; // Load contact
      });
    }
  }

  Future<void> updateUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    // Prepare updated user data
    Map<String, dynamic> updatedUser = {
      'name': name,
      'email': email,
      'rollNumber': roll,
      'department': branch,
      'hostel': hostelController.text,
      'room': roomController.text,
      'contact': contactController.text,
    };
    // Save updated data to SharedPreferences
    await prefs.setString('user_data', jsonEncode(updatedUser));

    // Navigate to the home page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => Home(),
      ),
    );
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
                        child: Text("Submit" , style: TextStyle(
                          color: Colors.white
                        ),),
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
