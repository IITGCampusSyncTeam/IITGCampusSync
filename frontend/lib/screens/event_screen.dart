import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/apis/events/event_api.dart';
import 'package:frontend/services/notification_services.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/eventProvider.dart';
import '../widgets/event_card.dart';

import '../utilities/helper_functions.dart';

class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {

  List upcomingEvents = [];
  final String serverKey = '';
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateTimeController = TextEditingController();
  final clubController = TextEditingController();
  NotificationServices notificationServices = NotificationServices();

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).fetchAllEvents();
    });
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


  Future<void> sendNotificationToAll(List<String> tokens, String title,
      String body, String serverKey) async {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
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
                  onPressed: () {
                    //  Call createEvent from the provider
                    eventProvider.createEvent(
                      titleController.text,
                      descriptionController.text,
                      DateTime.parse(dateTimeController.text),
                      // Ensure this parsing is safe
                      clubController.text,
                    ).then((
                        _) { // Use .then() to show your dialogs after the action is complete
                      if (eventProvider.errorMessage.isEmpty) {
                        _showSuccessDialog('Event created successfully');
                        _clearInputFields();
                      } else {
                        _showErrorDialog(eventProvider.errorMessage);
                      }
                    });
                  },
                  child: Text('Create Event'),
                ),
                SizedBox(height: 24),
                // Event List
                Expanded(
                  // Check the provider's loading state
                  child: eventProvider.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : eventProvider.allEvents.isNotEmpty
                      ? ListView.builder(
                    //  Get item count and data from the provider
                    itemCount: eventProvider.allEvents.length,
                    itemBuilder: (context, index) {
                      final event = eventProvider.allEvents[index];

                      //  Use new EventCard and pass the provider's logic
                      return EventCard(
                        style: CardStyle.full,
                        event: event,
                        onRsvpPressed: () {
                          eventProvider.toggleRsvpStatus(event.id);
                        }, banner: event.title, // Or event.banner if you have that field
                          title: event.title,
                          organizer: event.organizer,
                          // Format the DateTime object into a simple String
                          dateTime: "${event.dateTime.toLocal().day}/${event.dateTime.toLocal().month}/${event.dateTime.toLocal().year}",
                          location: event.location,
                          // Ensure the tags are a List<String>
                          tags: List<String>.from(event.tag),
                          imageUrl: event.imageUrl,
                          description: event.description,
                      );
                    },
                  )
                      : Center(child: Text('No events found')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

