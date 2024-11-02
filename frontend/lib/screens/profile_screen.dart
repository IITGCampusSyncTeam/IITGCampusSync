import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/apis/User/user.dart';
import 'package:frontend/apis/authentication/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/userModel.dart';
import 'edit_profile_page.dart';

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
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user_data');

    if (userJson != null) {
      User user = User.fromJson(jsonDecode(userJson));

      setState(() {
        name = user.name;
        email = user.email;
        roll = user.rollNumber.toString();
        branch = user.department;
      });
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
