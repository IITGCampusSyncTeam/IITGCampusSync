import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:frontend/screens/org_screens/menu_icons.dart';

class EventMenuScreen extends StatefulWidget {
  @override
  _EventMenuScreenState createState() => _EventMenuScreenState();
}

class _EventMenuScreenState extends State<EventMenuScreen> {
  // Dummy event details
  final String eventTitle = "AI & ML Workshop";
  final String eventDescription =
      "Join us for an exciting workshop on Artificial Intelligence and Machine Learning!";
  final String eventDateTime = "March 20, 2025 at 10:00 AM";
  final String eventLocation = "Tech Auditorium, IIT Guwahati";
  final String eventLink = "https://example.com/ai-ml-workshop";
  final String imageUrl =
      "https://upload.wikimedia.org/wikipedia/commons/3/3a/Cat03.jpg";

  // ---------------- SHARE EVENT ----------------
  Future<void> _shareEvent() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = "${tempDir.path}/event.jpg";

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        String message = "📢 *$eventTitle*\n\n"
            "📋 Description: $eventDescription\n"
            "📅 Date & Time: $eventDateTime\n"
            "📍 Location: $eventLocation\n"
            "🔗 More details: $eventLink\n\n"
            "🚀 Don't miss out!";

        await Share.shareXFiles([XFile(file.path)], text: message);
      }
    } catch (e) {
      print("Error sharing event: $e");
    }
  }

  void _showSharePopup() {
    _shareEvent();
  }

  // ---------------- SEND REMINDERS ---------------------
  void _showReminderPopup() {
    showModalBottomSheet(
      backgroundColor: Color(0xFFF4F4F5),
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Color(0xFF71717B),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Send a timely nudge!",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF27272A)),
              ),
              const SizedBox(height: 12),
              const Text(
                "Your RSVPed students will get a notification. "
                "You can send up to 2 reminders - keep them relevant and well-timed :)",
                style: TextStyle(fontSize: 14, color: Color(0xFF27272A)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFFE4E4E7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: const Text(
                        "Go back",
                        style: TextStyle(
                            color: Color(0xFF27272A),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Reminder Sent")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color(0xFF27272A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: const Text(
                        "Send Reminder",
                        style: TextStyle(
                            color: Color(0xFFFAFAFA),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // ---------------- PAUSE REGISTRATIONS ----------------
  void _showPausePopup() {
    showModalBottomSheet(
      backgroundColor: Color(0xFFF4F4F5),
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Color(0xFF71717B),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Pause Registrations?",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF27272A)),
              ),
              const SizedBox(height: 12),
              const Text(
                "Students will see it as full but can still request to join. "
                "You can resume registrations anytime before the event date.",
                style: TextStyle(fontSize: 14, color: Color(0xFF27272A)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Registrations paused")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color(0xFF27272A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: const Text("Continue",
                          style: TextStyle(
                              color: Color(0xFFFAFAFA),
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFFE4E4E7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: const Text(
                        "Go back",
                        style: TextStyle(
                            color: Color(0xFF27272A),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // ---------------- CANCEL EVENT ----------------
  void _showCancelPopup() {
    showModalBottomSheet(
      backgroundColor: Color(0xFFF4F4F5),
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Color(0xFF71717B),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xFFFFE2E2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_rounded,
                    color: Color(0xFFFB2C36), size: 30),
              ),
              SizedBox(height: 20),
              Text(
                "Cancel Event?",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF27272A)),
              ),
              const SizedBox(height: 12),
              const Text(
                "You cannot undo this action.\n",
                style: TextStyle(fontSize: 14, color: Color(0xFFFB2C36)),
              ),
              const Text(
                "You will lose all current registrations and insights. "
                "We will send a message to guests notifying them that the event has been canceled.\n\n"
                "We will shift this event to your drafts.",
                style: TextStyle(fontSize: 14, color: Color(0xFF27272A)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Event canceled")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color(0xFFFB2C36),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: const Text("Continue",
                          style: TextStyle(
                              color: Color(0xFFFAFAFA),
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFFE4E4E7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: const Text(
                        "Go back",
                        style: TextStyle(
                          color: Color(0xFF27272A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // ---------------- MENU PANEL ----------------
  void _showMenuPanel() {
    showModalBottomSheet(
      backgroundColor: Color(0xFFF4F4F5),
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            Center(
              child: Container(
                width: 48,
                height: 2,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF71717B),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(MenuIcons.share),
              title: const Text("Share Event"),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                _showSharePopup();
              },
            ),
            ListTile(
              leading: const Icon(MenuIcons.draft),
              title: const Text("Duplicate as Draft"),
              onTap: () {
                Navigator.pop(context);
                final snackBar = SnackBar(
                  content: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "A duplicate of this event has been added to your Drafts.",
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          // TODO: Add logic to open drafts screen
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                        child: const Text("Open Drafts"),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          // TODO: Add logic to undo the duplication
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                        child: const Text("Undo"),
                      ),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF323232),
                  margin: const EdgeInsets.all(12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  duration: const Duration(seconds: 5),
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            ),
            ListTile(
              leading: const Icon(MenuIcons.rsvp),
              title: const Text("View RSVP List"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Opening RSVP List...")),
                );
              },
            ),
            ListTile(
              leading: const Icon(MenuIcons.reminder),
              title: const Text("Send Reminders"),
              onTap: () {
                Navigator.pop(context);
                _showReminderPopup();
              },
            ),
            ListTile(
              leading: const Icon(MenuIcons.pause),
              title: const Text("Pause Registrations"),
              onTap: () {
                Navigator.pop(context);
                _showPausePopup();
              },
            ),
            ListTile(
              leading: const Icon(MenuIcons.cancel, color: Color(0xFFFB2C36)),
              tileColor: Color(0xFFFFE2E2),
              title: const Text("Cancel Event",
                  style: TextStyle(color: Color(0xFFFB2C36))),
              onTap: () {
                Navigator.pop(context);
                _showCancelPopup();
              },
            ),
          ],
        );
      },
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _showMenuPanel,
          child: const Text("Event Menu Testing"),
        ),
      ),
    );
  }
}
