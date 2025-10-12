import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class EventShareScreen extends StatelessWidget {

  final String eventTitle;
  final String eventDescription;
  final String eventDateTime;
  final String eventLocation;
  final String eventLink;
  final String imageUrl;

  const EventShareScreen({
    super.key,
    required this.eventTitle,
    required this.eventDescription,
    required this.eventDateTime,
    required this.eventLocation,
    required this.eventLink,
    required this.imageUrl,
  });

  Future<void> _shareEvent() async {
  try {
    // 📝 Create the event message
    String message = "📢 *$eventTitle*\n\n"
        "📋 Description: $eventDescription\n"
        "📅 Date & Time: $eventDateTime\n"
        "📍 Location: $eventLocation\n"
        "🔗 More details: $eventLink\n\n"
        "🚀 Don't miss out!";

    // 🖼️ Check if imageUrl is provided and valid
    if (imageUrl.isNotEmpty && Uri.tryParse(imageUrl)?.hasAbsolutePath == true) {
      try {
        final tempDir = await getTemporaryDirectory();
        final filePath = "${tempDir.path}/event.jpg";

        // 🌍 Download image
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final File file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          // 📤 Share with image + text
          await Share.shareXFiles([XFile(file.path)], text: message);
          return; // ✅ Exit here if success
        }
      } catch (e) {
        print("Image download failed, falling back to text-only share.");
      }
    }

    // 📤 Fallback → Share only text
    await Share.share(message);
  } catch (e) {
    print("Error: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height:  MediaQuery.of(context).size.height * 0.03),
          ListTile(
              leading:  Icon(Icons.share, color: Colors.grey[800]),
              title:  Text("Share Event", style: TextStyle(color: Colors.grey[800])),
              onTap: () {
                _shareEvent();
              },
            ),
        ],
      )
    );
  }
}
