import 'package:flutter/material.dart';
import 'package:frontend/apis/User/user.dart';
import 'package:frontend/apis/authentication/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_profile_page.dart';
import 'home.dart';
//import 'edit_profile_page.dart';
//import 'main_screen.dart';

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
    loadProfileData(); // Load saved profile data from SharedPreferences
  }

  Future<void> fetchUserData() async {
    final userDetails = await fetchUserDetails();
    if (userDetails != null) {
      setState(() {
        name = userDetails['name'] ?? '';
        email = userDetails['email'] ?? '';
        roll = userDetails['roll'] ?? '';
        branch = userDetails['branch'] ?? '';
      });
    } else {
      print("Failed to load user details.");
    }
  }

  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hostelController.text = prefs.getString('hostel') ?? '';
      roomController.text = prefs.getString('room') ?? '';
      contactController.text = prefs.getString('contact') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: Text("Profile"),
        actions: [
          // Logout Button
          IconButton(
            onPressed: () async {
             await logoutHandler(context);
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
              width: double.infinity, // Make the card take the full width
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
                      _buildProfileItem("Hostel", hostelController.text),
                      SizedBox(height: 16),
                      _buildProfileItem("Room Number", roomController.text),
                      SizedBox(height: 16),
                      _buildProfileItem("Contact", contactController.text),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfileScreen(
                hostel: hostelController.text,
                room: roomController.text,
                contact: contactController.text,
                onSave: (hostel, room, contact) async {
                  // Save the updated data locally using SharedPreferences
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setString('hostel', hostel);
                  prefs.setString('room', room);
                  prefs.setString('contact', contact);

                  setState(() {
                    hostelController.text = hostel;
                    roomController.text = room;
                    contactController.text = contact;
                  });

                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.edit),
      ),
    );
  }


  // Helper function to build each label and value pair
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
}