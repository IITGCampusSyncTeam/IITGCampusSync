import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../models/calendar_event.dart';

class CalendarScreen extends StatefulWidget {
  final String outlookId;
  const CalendarScreen({super.key, required this.outlookId});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  List<CalendarEvent> filteredEvents = [];

  @override
  void initState() {
    super.initState();
    filteredEvents = events
        .where((e) =>
    e.startTime.day == selectedDate.day &&
        e.startTime.month == selectedDate.month &&
        e.startTime.year == selectedDate.year)
        .toList();
  }

  @override
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(3000, 12, 31),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        filteredEvents = events
            .where((e) =>
        e.startTime.day == selectedDate.day &&
            e.startTime.month == selectedDate.month &&
            e.startTime.year == selectedDate.year)
            .toList();
      });
    }
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text(
                "Events on ${selectedDate.toLocal().toString().split(' ')[0].split('-').reversed.toList().join('/')}"),
            actions: [
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => selectDate(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return Container(
                        height: 200,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TimelineTile(
                          alignment: TimelineAlign.start,
                          isFirst: index == 0,
                          isLast: index == filteredEvents.length - 1,
                          beforeLineStyle: LineStyle(color: Colors.deepPurple),
                          indicatorStyle: IndicatorStyle(
                              color: Colors.deepPurple,
                              width: 40,
                              iconStyle: IconStyle(
                                iconData: Icons.event,
                                color: Colors.white,
                              )),
                          endChild: ListTile(
                            title: Text(
                              event.title,
                              style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Starts at : ${event.startTime}'),
                          ),
                          axis: TimelineAxis.vertical,
                        ),
                      );
                    })
              ],
            ),
          )),
    );
  }
}

List<CalendarEvent> events = [
  CalendarEvent(
      id: "1",
      title: "RangMunch",
      startTime: DateTime(2024, 10, 6, 7, 30),
      reminderTime: DateTime(2024, 10, 1, 7, 30)),
  CalendarEvent(
      id: "2",
      title: "Kriti",
      startTime: DateTime(2024, 10, 17, 4, 00),
      reminderTime: DateTime(2024, 10, 1, 7, 30)),
  CalendarEvent(
      id: "3",
      title: "Ethos",
      startTime: DateTime(2024, 10, 18, 8, 15),
      reminderTime: DateTime(2024, 10, 1, 7, 30)),
  CalendarEvent(
      id: "4",
      title: "Manthan",
      startTime: DateTime(2024, 10, 20, 6, 45),
      reminderTime: DateTime(2024, 10, 1, 7, 30)),
  CalendarEvent(
      id: "4",
      title: "Spardha",
      startTime: DateTime(2024, 10, 20, 6, 45),
      reminderTime: DateTime(2024, 10, 1, 7, 30)),
  CalendarEvent(
      id: "4",
      title: "Random",
      startTime: DateTime(2024, 10, 30, 6, 45),
      reminderTime: DateTime(2024, 10, 1, 7, 30)),
];