import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/services/notification_services.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List events = [];
  final String serverKey = '';
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateTimeController = TextEditingController();
  final clubController = TextEditingController();
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    fetchEvents();
    notificationServices.requestNotificationPermission;
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
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

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // Obtain the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    // Close the HTTP client
    client.close();

    // Return the access token
    return credentials.accessToken.data;
  }

  Future<void> fetchEvents() async {
    final url = 'http://192.168.29.195:3000/get-events';
    try {
      final response = await http.get(Uri.parse(url));
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          events = json.decode(response.body);
        });
      } else {
        _showErrorDialog('Failed to load events');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    }
  }

  Future<void> createEvent() async {
    final String serverKey = await getServerKey();
    final title = titleController.text;
    final description = descriptionController.text;
    final dateTime = dateTimeController.text;
    final club = clubController.text;

    if (title.isEmpty ||
        description.isEmpty ||
        dateTime.isEmpty ||
        club.isEmpty) {
      _showErrorDialog('Please fill in all the fields');
      return;
    }

    final url = 'http://192.168.29.195:3000/create-event';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'description': description,
          'dateTime': dateTime,
          'club': club,
          'createdBy': '5f50b61f78d1e74d8c3f0002',
          'participants': [],
          'feedbacks': [],
          'notifications': []
        }),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog('Event created successfully');
        fetchEvents(); // Refresh event list
        _clearInputFields(); // Clear fields after submission

        // Fetch all registered FCM tokens
        final tokensResponse =
            await http.get(Uri.parse('http://192.168.29.195:3000/get-tokens'));
        if (tokensResponse.statusCode == 200) {
          // Explicitly cast dynamic values to String
          List<String> tokens = (json.decode(tokensResponse.body) as List)
              .map((item) => item.toString())
              .toList();

          await sendNotificationToAll(tokens, title, description, serverKey);
        } else {
          _showErrorDialog('Failed to retrieve user tokens');
        }
      } else {
        _showErrorDialog('Error creating event');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    }
  }

  Future<void> sendNotificationToAll(
      List<String> tokens, String title, String body, String serverKey) async {
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

  // Future<void> sendFCMMessage() async {
  //   final String serverKey =
  //       // Your FCM server key
  //   final String fcmEndpoint =
  //       'https://fcm.googleapis.com/v1/projects/iitg-campus-sync/messages:send';
  //   final currentFCMToken = await FirebaseMessaging.instance.getToken();
  //   print("fcmkey : $currentFCMToken");
  //   final Map<String, dynamic> message = {
  //     'message': {
  //       'token':
  //           currentFCMToken, // Token of the device you want to send the message to
  //       'notification': {
  //         'body': 'This is an FCM notification message!',
  //         'title': 'FCM Message'
  //       },
  //       'data': {
  //         'current_user_fcm_token':
  //             currentFCMToken, // Include the current user's FCM token in data payload
  //       },
  //     }
  //   };
  //
  //   final http.Response response = await http.post(
  //     Uri.parse(fcmEndpoint),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $serverKey',
  //     },
  //     body: jsonEncode(message),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     print('FCM message sent successfully');
  //   } else {
  //     print('Failed to send FCM message: ${response.statusCode}');
  //   }
  // }

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
                            subtitle: Text(event['description']),
                            trailing: Text(event['dateTime']),
                          ),
                        );
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
