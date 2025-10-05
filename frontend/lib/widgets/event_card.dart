import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';

enum CardStyle { full, compact }

class EventCard extends StatelessWidget {
  final String banner;
  final String title;
  final String organizer;
  final String dateTime;
  final String location;
  final List<String> tags;
  final String imageUrl;
  final String description;
  final Event event;
  final CardStyle style;
  final VoidCallback onRsvpPressed;

  const EventCard({
    super.key,
    required this.event,
    required this.style,
    required this.onRsvpPressed,
    required this.banner,
    required this.title,
    required this.organizer,
    required this.dateTime,
    required this.location,
    required this.tags,
    required this.imageUrl,
    required this.description,
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
                    imageUrl,
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
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      banner,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                      ),
                    ),
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
                    child: IconButton(
                      icon: const Icon(Icons.calendar_today_outlined),
                      onPressed: () {},
                      color: Colors.black,
                      iconSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    organizer,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          dateTime,
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16), // Spacing before the button

                  //  RSVP BUTTON ADDED HERE
                  ElevatedButton.icon(
                   onPressed: onRsvpPressed, // Calls the function from the screen
                   icon: Icon(
                   event.isRsvpd ? Icons.check_circle : Icons.event_available,
                   size: 18,
                   ),
                   label: Text(event.isRsvpd ? "RSVP'd" : "RSVP"),
                   style: ElevatedButton.styleFrom(
                   backgroundColor: event.isRsvpd ? Colors.green : Theme.of(context).primaryColor,
                   foregroundColor: Colors.white,
                   minimumSize: const Size(double.infinity, 36), // Make button wide
                   shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(20),
                      ),
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
  //New UI
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
              imageUrl, // Using the 'imageUrl' property
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.purple.withOpacity(0.2),
                  child: Center(child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), // Using 'title'
                const SizedBox(height: 4),
                Text(organizer, style: TextStyle(color: Colors.grey[600], fontSize: 13)), // Using 'organizer'
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateTime, style: TextStyle(color: Colors.grey[700])), // Using 'dateTime'
                    Text(location, style: TextStyle(color: Colors.grey[700])), // Using 'location'
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



