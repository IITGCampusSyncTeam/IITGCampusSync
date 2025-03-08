import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order_summary_screen.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController hostelController = TextEditingController();
  TextEditingController roomController = TextEditingController();
  bool isLoading = true;
  bool isFormComplete = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user_data');

    if (userJson != null) {
      final user = jsonDecode(userJson);
      setState(() {
        nameController.text = user['name'] ?? '';
        contactController.text = user['contact'] ?? '';
        hostelController.text = user['hostel'] ?? '';
        roomController.text = user['roomnum'] ?? '';
        isLoading = false;
        checkFormCompletion();
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void checkFormCompletion() {
    setState(() {
      isFormComplete = nameController.text.isNotEmpty &&
          contactController.text.isNotEmpty &&
          hostelController.text.isNotEmpty &&
          roomController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Checkout", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField("Name", nameController, Icons.person),
                    _buildTextField("Contact", contactController, Icons.phone),
                    _buildTextField("Hostel", hostelController, Icons.home),
                    _buildTextField("Room Number", roomController, Icons.door_front_door),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isFormComplete
                          ? () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => OrderSummaryScreen(
                              name: nameController.text,
                              contact: contactController.text,
                              hostel: hostelController.text,
                              room: roomController.text,
                            ),
                            transitionsBuilder: (_, anim, __, child) {
                              return FadeTransition(opacity: anim, child: child);
                            },
                          ),
                        );
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFormComplete ? Colors.blueAccent : Colors.grey,
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Next", style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) => checkFormCompletion(),
      ),
    );
  }
}
