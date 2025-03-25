import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class EventShareScreen extends StatefulWidget {
  @override
  _EventShareScreenState createState() => _EventShareScreenState();
}
// use this code for sharing event

class _EventShareScreenState extends State<EventShareScreen> {
  final String eventTitle = "AI & ML Workshop";
  final String eventDescription = "Join us for an exciting workshop on Artificial Intelligence and Machine Learning!";
  final String eventDateTime = "March 20, 2025 at 10:00 AM";
  final String eventLocation = "Tech Auditorium, IIT Guwahati";
  final String eventLink = "https://example.com/ai-ml-workshop";

  // ✅ Image URL (Replace with your own image URL)
  final String imageUrl = "https://upload.wikimedia.org/wikipedia/commons/3/3a/Cat03.jpg";

  Future<void> _shareEvent() async {
    try {
      // 📥 Step 1: Get a temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = "${tempDir.path}/event.jpg";

      // 🌍 Download the image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // 📝 Step 2: Create the event message
        String message = "📢 *$eventTitle*\n\n"
            "📋 Description: $eventDescription\n"
            "📅 Date & Time: $eventDateTime\n"
            "📍 Location: $eventLocation\n"
            "🔗 More details: $eventLink\n\n"
            "🚀 Don't miss out!";

        // 📤 Step 3: Share with WhatsApp
        await Share.shareXFiles([XFile(file.path)], text: message);
      } else {
        print("Failed to download image");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Event Details")),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: _shareEvent,
          icon: Icon(Icons.share),
          label: Text("Share Event"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
