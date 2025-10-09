import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/screens/org_screens/RSVPIcons.dart';
import 'package:frontend/screens/org_screens/rsvp_info_slider.dart';
import 'package:intl/intl.dart';

class ActiveEventsScreen extends StatefulWidget {
  final dynamic events;

  const ActiveEventsScreen({super.key, required this.events});

  @override
  State<ActiveEventsScreen> createState() => _ActiveEventsScreenState();
}

class _ActiveEventsScreenState extends State<ActiveEventsScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.events == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (widget.events.isEmpty) {
      return const Center(
        child: Text('No events available'),
      );
    }
    return ListView.builder(
      itemCount: widget.events.length,
      itemBuilder: (context, index) => _ActiveEventTile(
        event: widget.events[index],
      ),
    );
  }
}

class _ActiveEventTile extends StatelessWidget {
  const _ActiveEventTile({required this.event});

  final dynamic event;

  @override
  Widget build(BuildContext context) {
    return _ActiveEventsCard(
      event: event,
    );
  }
}

class _ActiveEventsCard extends StatefulWidget {
  const _ActiveEventsCard({required this.event});

  final dynamic event;

  @override
  State<_ActiveEventsCard> createState() =>
      _ActiveEventsCardState(event: event);
}

class _ActiveEventsCardState extends State<_ActiveEventsCard> {
  _ActiveEventsCardState({required this.event});

  final dynamic event;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final end = DateTime.parse(event['dateTime']).add(
      Duration(
        hours: DateTime.parse(event['duration'] ?? '0000-00-00 00:00:00').hour,
        minutes:
            DateTime.parse(event['duration'] ?? '0000-00-00 00:00:00').minute,
        seconds:
            DateTime.parse(event['duration'] ?? '0000-00-00 00:00:00').second,
      ),
    );

    if (DateTime.now().isAfter(end)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
            border: Border.all(color: TextColors.muted)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    topLeft: Radius.circular(16),
                  ),
                  child: Image.network(
                    event == null
                        ? 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?q=80&w=2070&auto=format&fit=crop'
                        : event['banner'] ??
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
                if (event != null)
                  if (DateTime.parse(event['dateTime'])
                      .isBefore(DateTime.now()))
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 24,
                            width: 52,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1000)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  height: 6,
                                  width: 6,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius:
                                          BorderRadius.circular(1000)),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  'Live',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
              ],
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    event == null
                        ? 'Test Title'
                        : event['title'] ?? "Test Title",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(
                        Icons.watch_later_outlined,
                        size: 18,
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                        event == null
                            ? 'Test dateTime'
                            : DateFormat('d MMMM, h:mm a').format(
                                        DateTime.parse(event['dateTime'])) ==
                                    ''
                                ? "Test dateTime"
                                : DateFormat('d MMMM, h:mm a')
                                    .format(DateTime.parse(event['dateTime'])),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 17.5, vertical: 4),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/locationIcon.svg',
                        height: 16.33,
                        width: 13.67,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        event == null
                            ? 'Test Venue'
                            : event['venue'] ?? "Test Venue",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RSVPIcons(
                  RSVP: event['RSVP'],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                  child: Text(
                    '${event == null ? '0' : event['views'] == null ? '0' : event['views'] == '' ? '0' : event['views'].length} Views',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )
              ],
            ),
            Divider(
              height: 1,
              color: TextColors.muted,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        // TODO: implement See Insights
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 40,
                        width: (screenWidth - 112) * 161 / 248,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'See Insight',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 4, 16),
                  child: InkWell(
                    onTap: () {
                      // TODO: implement Edit
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 40,
                      width: (screenWidth - 112) * 87 / 248,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFFE4E4E7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mode_edit_outlined,
                            color: Colors.black,
                            size: 18,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                  child: RsvpInfoSlider(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
