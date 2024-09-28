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
      //Your serviceAccoucnt Json Data
      "type": "service_account",
      "project_id": "iitg-campus-sync",
      "private_key_id": "e4409b4f2999862281cff53e1413cb71bc359434",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCx04tL6bzfmkrf\nW55IE/CYI7ssQw+jvoNACcbg3rsQIc1SOi3vNF/o7wBaEPgFboLk4KkQnm6Vdf+U\nscVKQAIm+4gqzJ2uDQ8w7O6Cc1tImnq6pNBVE+NWk1m++RRHAvzGgBSypjdre8KO\n4RPQQqIPRzo675kuGO6XJ7CX+0cFnozKMhP94vatDktSuIQqKDaVLed4lhvFT2Gz\nyUg5YEohhWb1uuRCgQilDC2/Lra+W+B/Quu7po/bePk+1Nf/dpflen6DafkUJUW7\nYFNhyRjRm1m3G4G5jBJ8Ih0eePmZ1CtYrmdW/ZXDTkt/VqPe+eMKco5rcObsnyid\nwjgGxW41AgMBAAECggEAEmfc9nczpMk+5VjW9zWTz4t952+W13yemoA95Nno7sXb\nj0k/po9QkLbm3cD9NZgMqvf98nRo6cYUNXsjpTMe2z4UXVRfIGbFoxYYUcmdhymb\neQ9vaNRC0ZvgIX4nynnVWWO5wLanlykbfYJvyec7su0ians7laPgU3uOMbeWevmT\nhq6yHJ/iw7ysSBIYtRo4mBeCZujEEVsL9w9VrMJZTEI4DmAyGU+ocrG3DaqL6LuC\nrg2GhQ299FjRjtxmkmNZzzpPvXmuaEj2HTxZmgeZGE6lzbn1mTZxa0Kz0sxz94KC\nNhzOBePczklmktW/1xMvUpTetBI6JSbYbh3CSlgz+QKBgQD3qZJFz+E7Frrdw9jA\nR4v0kkr0Zgo4M1tsU9MXBxAkvKNW6BTrLvvW6I30anih7nhbpj1XdPxIR/qJAyj3\n4o6m3TE48dtnPUdsjeSrChH1SiDWySi0PeWgN8R1wo/4EZec2liXOj/mAPLUEgfK\nkX9BrDxxzUEdt+kAue4SGiBw8wKBgQC30BrU32huvRFiDqVdg/Me4GN/OKttcNNt\nbtUUVbY988ISpcEgpVro75yGmDRmJ8si3f7j6OkD18X4leu6Hf2lm12DkfTF2IAp\n6GCA+oDz4VvWa6FPiiP+nnu6oAHPSiZNAScJMtXjm5QRi+PYI6zb+UndLhCnveUr\ngHdEsNiuNwKBgF1JpG1jhmVphG3wTX7v9EnlqRIyNXtB7Rf64zJzWKNd4vDjbq2/\n/uDOrFn6mQH1/6QWFFkTGcxoQHjHlfD5h95Wxym6AHj83iCHujCrFGSezYvaLdjm\nz83v87Kf3PcGOWO940zjhhovFUjImeK1t4eXRxVeyT5Wfg/l+UUcTkf9AoGAbAvU\nqcqEvYs/e482Xwjf0Qd/FNo/0j3e2dWrRJ+5VyNAseti4YixLnkiXe975YyAmIc7\ne8Z9qbec9ClT/fwBC+aOincyFVXUyE2C5G3bfP+8Fwb/NBz0WYfZHPNO/QUODHef\n9YU/OuJJoCLFlFgsFMWtSGj6e09hNTf3Y5Y8V/MCgYEA9yPOVYcf1RChQGjDdrYH\n5v91py9Dc5gNbGYfq7Dzmlq1OeWmEcBRkq9Q58X95ubwXl4dg5iW1NAT2m2e0bkc\nl//z5MLSjmKl9FU35nQYSOFZyzlHEa7R09g64u/RLjBFwDy5q2H4jq8a5/Un6Qzp\n4PNnhmny6+3Z/V+VcXikmdA=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-lriwj@iitg-campus-sync.iam.gserviceaccount.com",
      "client_id": "100065933557536941684",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-lriwj%40iitg-campus-sync.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
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
    final url = 'http://192.168.0.102:3000/get-events';
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

    final url = 'http://192.168.0.102:3000/create-event';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'description': description,
          'dateTime': dateTime,
          'club': club,
          'createdBy':
              '5f50b61f78d1e74d8c3f0002', // Replace with actual user ID
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
            await http.get(Uri.parse('http://192.168.0.102:3000/get-tokens'));
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
