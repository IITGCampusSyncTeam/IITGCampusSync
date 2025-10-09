import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/screens/org_screens/RSVPIcons.dart';
import 'package:intl/intl.dart';

class PastEventsScreen extends StatefulWidget {
  // Use a specific type for better code safety. `List<dynamic>?` allows for a null list.
  final List<dynamic>? events;

  const PastEventsScreen({super.key, required this.events});

  @override
  State<PastEventsScreen> createState() => _PastEventsScreenState();
}

class _PastEventsScreenState extends State<PastEventsScreen> {
  @override
  Widget build(BuildContext context) {
    // If events list is null (loading), show 2 skeleton cards as placeholders.
    if (widget.events == null) {
      return ListView(
        children: const [
          _SkeletonCard(),
          _SkeletonCard(),
        ],
      );
    }
    // If the list is empty after loading, show a message.
    if (widget.events!.isEmpty) {
      return const Center(
        child: Text('No past events available.'),
      );
    }
    // Once data is available, build the list of event cards.
    return ListView.builder(
      itemCount: widget.events!.length,
      itemBuilder: (context, index) => _PastEventsCard(
        event: widget.events![index],
      ),
    );
  }
}

class _PastEventsCard extends StatelessWidget {
  const _PastEventsCard({required this.event});

  final dynamic event;

  @override
  Widget build(BuildContext context) {
    // --- Date and Time Logic ---
    // Safely parse dateTime. A valid dateTime is required to show the card.
    final DateTime? eventStart =
        event['dateTime'] != null ? DateTime.tryParse(event['dateTime']) : null;

    // Don't build the card if the event date is invalid or missing.
    if (eventStart == null) {
      return const SizedBox.shrink();
    }

    // Assumption: 'duration' is an integer representing minutes.
    // Defaulting to 120 minutes (2 hours) if the value is missing or invalid.
    final int durationInMinutes = (event['duration'] as num?)?.toInt() ?? 120;
    final DateTime eventEnd =
        eventStart.add(Duration(minutes: durationInMinutes));

    // On the "Past Events" screen, only show events that have already finished.
    if (eventEnd.isAfter(DateTime.now())) {
      return const SizedBox.shrink(); // Hide ongoing or future events.
    }
    // --- End of Date and Time Logic ---

    // --- FIX: Correctly process the RSVP list of Maps ---
    // This handles the "'_Map<String, dynamic>' is not a subtype of type 'String'" error.
    final List<dynamic> rsvpRawList = event['RSVP'] as List<dynamic>? ?? [];
    final List<String> rsvpIds = rsvpRawList
        .map((item) {
          // Check if the item in the list is a Map (like a user object).
          if (item is Map<String, dynamic>) {
            // Attempt to extract the ID, assuming the key is '_id'.
            return item['_id']?.toString() ?? '';
          }
          // Fallback if the item is already a string.
          return item.toString();
        })
        .where((id) => id.isNotEmpty)
        .toList(); // Ensure no empty IDs are passed.
    // --- END OF FIX ---

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(16),
            ),
            border: Border.all(color: TextColors.muted)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                topLeft: Radius.circular(16),
              ),
              child: Image.network(
                event['banner'] ??
                    'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?q=80&w=2070&auto=format&fit=crop',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
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

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                event['title'] ?? "Event Title",
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
            ),

            // Date
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.watch_later_outlined, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('d MMMM yyyy').format(eventStart),
                    style: const TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 14),
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                rsvpIds.isEmpty
                    ? SizedBox(width: MediaQuery.widthOf(context)-83,)
                    : Flexible(
                        child: RSVPIcons(
                          RSVP: rsvpIds, // Use the correctly processed list
                        ),
                      ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 16.0, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.star,
                          size: 14, color: Color(0xFFFF6900)),
                      const SizedBox(width: 4),
                      Text(
                        '${event['rating'] ?? '0'}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(
              height: 24,
              color: TextColors.muted,
            ),

            // "See Insight" Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: InkWell(
                onTap: () {
                  // TODO: implement See Insights
                },
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'See Insight',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A placeholder widget to display while event data is loading.
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: MediaQuery.of(context).size.width * 0.6,
                    color: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: MediaQuery.of(context).size.width * 0.4,
                    color: Colors.grey.shade200,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
