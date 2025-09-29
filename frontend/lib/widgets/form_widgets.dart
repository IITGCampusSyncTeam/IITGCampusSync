import 'package:flutter/material.dart';

// A styled header for form sections
Widget buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
    child: Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}

// A styled 'Add More' button for dynamic lists
Widget buildAddMoreButton({required VoidCallback onPressed}) {
  return TextButton.icon(
    onPressed: onPressed,
    icon: Icon(Icons.add_circle_outline, size: 20),
    label: Text('Add More'),
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
      alignment: Alignment.centerLeft,
    ),
  );
}