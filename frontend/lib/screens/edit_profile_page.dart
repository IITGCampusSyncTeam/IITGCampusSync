import 'package:flutter/material.dart';

// Edit Profile Screen for editing information
class EditProfileScreen extends StatefulWidget {
  final String hostel;
  final String room;
  final String contact;
  final Function(String, String, String) onSave;

  EditProfileScreen({
    required this.hostel,
    required this.room,
    required this.contact,
    required this.onSave,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController hostelController = TextEditingController();
  TextEditingController roomController = TextEditingController();
  TextEditingController contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    hostelController.text = widget.hostel;
    roomController.text = widget.room;
    contactController.text = widget.contact;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildEditableField("Hostel Name", hostelController),
            SizedBox(height: 16),
            _buildEditableField("Room Number", roomController),
            SizedBox(height: 16),
            _buildEditableField("Contact Number", contactController, TextInputType.phone),
            SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: () {
                widget.onSave(
                  hostelController.text,
                  roomController.text,
                  contactController.text,
                );
              },
              child: Text("Save"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build each editable field
  Widget _buildEditableField(String label, TextEditingController controller, [TextInputType keyboardType = TextInputType.text]) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
    );
  }
}