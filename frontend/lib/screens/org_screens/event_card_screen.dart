import 'package:flutter/material.dart';
import 'package:frontend/screens/sharing.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class EventCardScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventCardScreen({super.key, required this.event});

  @override
  State<EventCardScreen> createState() => _EventCardScreenState();
}

class _EventCardScreenState extends State<EventCardScreen> {
  bool _expandedText = false;

   Future<void> _shareEvent(Map<String, dynamic> event) async {
  try {
    String message = "📢 *${event['title'] ?? 'Untitled Event'}*\n\n"
        "📋 Description: ${event['description'] ?? 'No description'}\n"
        "📅 Date & Time: ${event['dateTime'] ?? 'Unknown date'}\n"
        "📍 Location: ${event['venue'] ?? 'Unknown venue'}\n"
        "🔗 More details: https://example.com/event/${event['_id'] ?? 'default'}\n\n"
        "🚀 Don't miss out!";

    final imageUrl = event['banner'] ?? "";

    if (imageUrl.isNotEmpty && Uri.tryParse(imageUrl)?.hasAbsolutePath == true) {
      try {
        final tempDir = await getTemporaryDirectory();
        final filePath = "${tempDir.path}/event.jpg";
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final File file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          await Share.shareXFiles([XFile(file.path)], text: message);
          return;
        }
      } catch (e) {
        print("Image download failed, falling back to text-only share.");
      }
    }

    await Share.share(message);
  } catch (e) {
    print("Error sharing event: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Event Page",
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
        ),
        centerTitle: true,
        actions: [
        IconButton(
  onPressed: () {
    _shareEvent(event); 
  },
  icon: const Icon(Icons.share_outlined),
),


        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {},
          child: const Text("I am in!",
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            
           _eventBanner(event),
            const SizedBox(height: 16),

            // Title + Club
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] ?? "",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  event['club'] ?? "",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tags
            Wrap(
              spacing: 8,
              children: (event['tags'] as List<dynamic>?)
                      ?.map((tag) => _outlinedChip(tag))
                      .toList() ??
                  [],
            ),
            const SizedBox(height: 16),

            // Date / Time / Venue
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _infoCell(event['date'] ?? "", "Date"),
                  _divider(),
                  _infoCell(event['datetime'] ?? "", "Time"),
                  _divider(),
                  _infoCell(event['venue'] ?? "", "Venue"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Event Brief
            const Text("Event Brief", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              event['description'] ??
                  "No description provided for this event.",
              maxLines: _expandedText ? null : 3,
              overflow:
                  _expandedText ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _expandedText = !_expandedText;
                  });
                },
                child: Text(_expandedText ? "Read Less" : "Read More"),
              ),
            ),

            // Audience
            if (event['audience'] != null)
              Text(
                event['audience'],
                style: TextStyle(
                    color: Colors.grey.shade600, fontWeight: FontWeight.w400),
              ),
            const Divider(height: 32),

            // Event Itinerary
            if (event['itinerary'] != null)
              _customExpansion(
                "Event Details",
                children: (event['itinerary'] as List<dynamic>)
                    .map((item) => _timelineEvent(
                        item['title'] ?? "", item['time'] ?? ""))
                    .toList(),
              ),
            const SizedBox(height: 16),

            // Speakers
            if (event['speakers'] != null)
              _customExpansion(
                "Speakers List",
                children: (event['speakers'] as List<dynamic>)
                    .map((speaker) =>
                        _speakerTile(speaker['name'], speaker['details']))
                    .toList(),
              ),
            const SizedBox(height: 16),

            // Prerequisites
            if (event['prerequisites'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Prerequisites",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...((event['prerequisites'] as List<dynamic>)
                      .map((p) => Text("• $p"))
                      .toList()),
                  const SizedBox(height: 16),
                ],
              ),

            // Resources
            if (event['resources'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Resources",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...((event['resources'] as List<dynamic>).map((res) {
                    return ListTile(
                      tileColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      leading: const Icon(Icons.open_in_new),
                      title: Text(res['title'] ?? ""),
                      subtitle: Text(res['description'] ?? ""),
                      onTap: () {},
                    );
                  }).toList()),
                  const SizedBox(height: 16),
                ],
              ),

            // Venue Details
            if (event['venueDetails'] != null)
              _customExpansion(
                "Venue Details",
                children: (event['venueDetails'] as List<dynamic>).map((v) {
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(v['title'] ?? ""),
                    subtitle: Text(v['subtitle'] ?? ""),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),

            // Resources & Links
            if (event['links'] != null)
              _customExpansion(
                "Resources & Links",
                children: [
                  Wrap(
                    spacing: 12,
                    children: (event['links'] as List<dynamic>).map((link) {
                      return IconButton(
                        icon: Icon(link['icon'] ?? Icons.link, size: 30),
                        onPressed: () {},
                      );
                    }).toList(),
                  )
                ],
              ),
            const SizedBox(height: 16),

            // POCs
            if (event['pocs'] != null)
              _customExpansion(
                "POCs",
                children: (event['pocs'] as List<dynamic>)
                    .map((poc) => _speakerTile(poc['name'], poc['details']))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------- Helpers ----------------

  Widget _eventBanner(Map<String, dynamic> event) {
  final imageUrl = event['banner'];
  if (imageUrl != null && imageUrl.isNotEmpty) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
      ),
    );
  } else {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          event['title'] ?? "Untitled Event",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}


  static Widget _outlinedChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white,
      shape: StadiumBorder(
        side: BorderSide(color: Colors.grey.shade400),
      ),
    );
  }

  static Widget _infoCell(String value, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  static Widget _divider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.shade400,
    );
  }

  static Widget _customExpansion(String title,
      {required List<Widget> children}) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 8, bottom: 8),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: children,
      ),
    );
  }

  static Widget _timelineEvent(String title, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(width: 2, height: 60, color: Colors.black),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(time, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _speakerTile(String name, String details) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(name),
      subtitle: Text(details),
    );
  }
}
