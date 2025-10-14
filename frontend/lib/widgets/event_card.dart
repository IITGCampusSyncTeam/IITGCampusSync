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
      return _buildCompactCard(
          context); // The new layout for the My Events screen
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
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4),
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
                        child: Image.asset(
                          'assets/drifter.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback if asset also fails
                            return Image.network(
                              'https://i.imgur.com/5Qf4WcN.png',
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 50,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit_calendar_outlined),
                      onPressed: () {},
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
                    event.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.organizer,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.black),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          DateFormat('d MMM, h:mm a').format(event.dateTime),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.black),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List<String>.from(event.tag)
                        .map(
                          (tag) =>
                          Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                    )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onRsvpPressed,
                    icon: Icon(event.isRsvpd
                        ? Icons.check_circle
                        : Icons.event_available),
                    label: Text(event.isRsvpd ? "RSVP'd" : "RSVP"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      event.isRsvpd ? Colors.green : Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 36),
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

  Widget _buildCompactCard(BuildContext context) {
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
                        child: Image.asset(
                          'assets/drifter.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback for if the asset itself can't be loaded (unlikely)
                            return const Center(
                              child: Icon(Icons.broken_image, size: 50,
                                  color: Colors.grey),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                        icon: const Icon(Icons.edit_calendar_outlined),
                        onPressed: () {}),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: const TextStyle(fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins')),
                  const SizedBox(height: 4),
                  Text(event.organizer,
                      style: TextStyle(color: Colors.black, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(
                        Icons.access_time, size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Expanded(child: Text(
                        DateFormat('d MMM, h:mm a').format(event.dateTime),
                        style: const TextStyle(fontSize: 14, color: Colors
                            .black))),
                    const SizedBox(width: 4),
                    const Icon(Icons.location_on_outlined, size: 16,
                        color: Colors.black),
                    const SizedBox(width: 4),
                    Expanded(child: Text(event.location,
                        style: const TextStyle(fontSize: 14, color: Colors
                            .black))),
                  ]),
                  // const SizedBox(height: 4),
                  // Row(children: [
                  //   const Icon(Icons.location_on, size: 16, color: Colors.black),
                  //   const SizedBox(width: 4),
                  //   Expanded(child: Text(event.location, style: const TextStyle(fontSize: 14, color: Colors.black))),
                  // ]),

                  // Text(event.description, style: const TextStyle(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List<String>.from(event.tag).map((tag) =>
                        Chip(label: Text(tag, style: const TextStyle(
                            fontSize: 12)))).toList(),
                  ),
                  const SizedBox(height: 16),
                  // "Reminders" button still needs to check the real date from the 'event' object
                  if (event.dateTime.isAfter(DateTime.now())) ...[

                    // const SizedBox(height: 12),
                    // const Divider(),
                    //
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: TextButton.icon(
                    //     onPressed: () {},
                    //     icon: const Icon(Icons.edit_calendar_outlined, size: 20),
                    //     label: const Text("Reminders"),
                    //     style: TextButton.styleFrom(foregroundColor: Colors.white,backgroundColor:  Colors.black),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 4),
                    // Optional spacing after divider

                    // ✅ ADDITION: A Row to hold the icons and the button
                    Row(
                      children: [


                        // Your existing Reminders button
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit_calendar_outlined,
                              size: 20),
                          label: const Text("Reminders"),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black,

                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)
                            ),
                          ),
                        ),
                        const SizedBox(width: 80),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey[200],
                          child: IconButton(
                            icon: const Icon(Icons.calendar_month, size: 18,
                                color: Colors.black54),
                            onPressed: () {
                              /* Add to Google Calendar logic */
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey[200],
                          child: IconButton(
                            icon: const Icon(
                                Icons.more_horiz, size: 18,
                                color: Colors.black54),
                            onPressed: () {
                              /* Add to local reminders logic */
                            },
                          ),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

