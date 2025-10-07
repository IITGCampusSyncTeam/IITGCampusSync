import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';

enum CardStyle { full, compact }

class EventCard extends StatelessWidget {

  final Event event;
  final CardStyle style;
  final VoidCallback onRsvpPressed;

  const EventCard({
    super.key,
    required this.event,
    required this.style,
    required this.onRsvpPressed,

  });

  @override
  Widget build(BuildContext context) {

    if (style == CardStyle.full) {
      return _buildFullCard(context); // Original layout for the Explore screen
    } else {
      return _buildCompactCard(context); // The new layout for the My Events screen
    }
  }
  Widget _buildFullCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    event.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 160,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported,
                              size: 50, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(icon: const Icon(Icons.calendar_today_outlined), onPressed: () {}),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(event.organizer, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(DateFormat('d MMM, h:mm a').format(event.dateTime), style: const TextStyle(fontSize: 14, color: Colors.grey))),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(event.location, style: const TextStyle(fontSize: 14, color: Colors.grey))),
                  ]),
                  const SizedBox(height: 8),
                  Text(event.description, style: const TextStyle(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List<String>.from(event.tag).map((tag) => Chip(label: Text(tag, style: const TextStyle(fontSize: 12)))).toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onRsvpPressed,
                    icon: Icon(event.isRsvpd ? Icons.check_circle : Icons.event_available),
                    label: Text(event.isRsvpd ? "RSVP'd" : "RSVP"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: event.isRsvpd ? Colors.green : Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCompactCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              event.imageUrl, // Using the 'imageUrl' property
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.purple.withOpacity(0.2),
                  child: Center(child: Text(event.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), // Using 'title'
                const SizedBox(height: 4),
                Text(event.organizer, style: TextStyle(color: Colors.grey[600], fontSize: 13)), // Using 'organizer'
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('d MMM, h:mm a').format(event.dateTime), style: TextStyle(color: Colors.grey[700])),
                    Text(event.location, style: TextStyle(color: Colors.grey[700])), // Using 'location'
                  ],
                ),
                // "Reminders" button still needs to check the real date from the 'event' object
                if (event.dateTime.isAfter(DateTime.now())) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_calendar_outlined, size: 20),
                      label: const Text("Reminders"),
                      style: TextButton.styleFrom(foregroundColor: Colors.black),
                    ),
                  ),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}



