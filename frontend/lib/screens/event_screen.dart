import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/apis/events/event_api.dart';
import 'package:frontend/services/notification_services.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;

import '../utilities/helper_functions.dart';

class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List events = [];
  List upcomingEvents = [];
  final String serverKey = '';
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateTimeController = TextEditingController();
  final clubController = TextEditingController();
  NotificationServices notificationServices = NotificationServices();
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  EventAPI eventAPI = EventAPI();
  //notif details setup
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
          'daily_channel_id', 'Daily Notifications',
          channelDescription: 'Daily Notification Channel',
          importance: Importance.max,
          priority: Priority.high),
      iOS: DarwinNotificationDetails(),
    );
  }

  @override
  void initState() {
    super.initState();
    loadEvents();
    notificationServices.requestNotificationPermission;
    notificationServices.forgroundMessage();
    // notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.getDeviceToken().then((value) {
      print('device token');
      print(value);
    });
  }

  Future<String> getServerKey() async {
    // Your client ID and client secret obtained from Google Cloud Console
    final serviceAccountJson = {
      //put iitg campus sync json file content here
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    final client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    return client.credentials.accessToken.data;
  }

  void loadEvents() async {
    try {
      final eventList = await eventAPI.fetchEvents();
      setState(() {
        events = eventList.map((event) {
          event['dateTime'] = convertToIST(event['dateTime']);
          return event;
        }).toList();
      });
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void loadUpcomingEvents() async {
    try {
      final eventList = await eventAPI.fetchUpcomingEvents();
      setState(() {
        upcomingEvents = eventList.map((event) {
          event['dateTime'] = convertToIST(event['dateTime']);
          return event;
        }).toList();
      });
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void createEvent() async {
    final title = titleController.text;
    final description = descriptionController.text;
    final dateTime = dateTimeController.text;
    final club = clubController.text;

    if (title.isEmpty ||
        description.isEmpty ||
        dateTime.isEmpty ||
        club.isEmpty) {
      _showErrorDialog('Please fill in all fields');
      return;
    }

    try {
      await eventAPI.createEvent(title, description, dateTime, club);
      loadEvents(); // Refresh the event list
      _showSuccessDialog('Event created successfully');
      _clearInputFields(); // Clear fields after submission
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> sendNotificationToAll(
      List<String> tokens, String title, String body, String serverKey) async {
    final String serverKey = await getServerKey(); // Get token dynamically
    for (String token in tokens) {
      var data = {
        'message': {
          'token': token,
          'notification': {'body': body, 'title': title},
        }
      };
      try {
        final response = await http.post(
          Uri.parse(
              'https://fcm.googleapis.com/v1/projects/iitg-campus-sync/messages:send'),
          body: jsonEncode(data),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $serverKey',
          },
        );
        if (response.statusCode != 200) {
          print(
              'Failed to send notification to $token: ${response.statusCode}');
        }
      } catch (e) {
        print('Error sending notification to $token: $e');
      }
    }
  }

  void _clearInputFields() {
    titleController.clear();
    descriptionController.clear();
    dateTimeController.clear();
    clubController.clear();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showReminderDialog(Map<String, dynamic> event) async {
    final DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    ).then((date) async {
      if (date != null) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          return DateTime(date.year, date.month, date.day, pickedTime.hour,
              pickedTime.minute);
        }
      }
      return null;
    });

    if (pickedDateTime != null) {
      final scheduledTime = pickedDateTime;

      await notificationServices.scheduleLocalNotification(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .remainder(100000), // unique ID
        title: event['title'],
        body: event['description'],
        scheduledDateTime: scheduledTime,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder set for ${event['title']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Campus Sync')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Event creation form
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: dateTimeController,
              decoration: InputDecoration(
                  labelText: 'Date and Time (YYYY-MM-DD HH:MM)'),
            ),
            TextField(
              controller: clubController,
              decoration: InputDecoration(labelText: 'Club ID'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: createEvent,
              child: Text('Create Event'),
            ),
            SizedBox(height: 24),
            // Event List
            Expanded(
              child: events.isNotEmpty
                  ? ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Card(
                          child: ListTile(
                            title: Text(event['title']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(event['description']),
                                SizedBox(height: 4),
                                Text('Date: ${event['dateTime']}'),
                                SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    print(
                                      tz.TZDateTime.now(tz.local)
                                          .add(const Duration(seconds: 5)),
                                    );
                                    await flutterLocalNotificationsPlugin
                                        .zonedSchedule(
                                            2,
                                            'scheduled title',
                                            'scheduled body',
                                            tz.TZDateTime.now(tz.local).add(
                                                const Duration(seconds: 20)),
                                            notificationDetails(),
                                            androidScheduleMode:
                                                AndroidScheduleMode
                                                    .inexactAllowWhileIdle);

                                    //
                                    // print(scheduledTime);
                                    // notificationServices
                                    //     .scheduleLocalNotification(
                                    //         id: 13,
                                    //         title: "dd",
                                    //         body: "dd",
                                    //         scheduledDateTime: scheduledTime);
                                  },

                                  // onPressed: () => _showReminderDialog(event),
                                  icon: Icon(Icons.alarm),
                                  label: Text('Set Reminder'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );

                        // return Card(
                        //   child: ListTile(
                        //     title: Text(event['title']),
                        //     subtitle: Text(event['description']),
                        //     trailing: Text(event['dateTime']),
                        //   ),
                        // );
                      },
                    )
                  : Center(child: Text('No events found')),
            ),
          ],
        ),
      ),
    );
  }
}
