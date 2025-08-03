import 'dart:convert';

import 'package:frontend/constants/endpoints.dart';
import 'package:http/http.dart' as http;

class EventAPI {
  Future<List> fetchEvents() async {
    final url = event.getAllEvents;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List> fetchUpcomingEvents() async {
    final url = event.getUpcomingEvents;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> createEvent({
    required String title,
    required String description,
    required DateTime date, // Should be in IST timezone
    required String club,
  }) async {
    final url = event.createEvent;

    final body = json.encode({
      'title': title,
      'description': description,
      'dateTime': date
          .toIso8601String(), // You can assume this is IST; backend will convert to UTC
      'club': club,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create event: ${response.body}');
      }

      print('✅ Event created successfully!');
    } catch (e) {
      print('❌ Error creating event: $e');
      throw Exception('Error: $e');
    }
  }

  //
  // Future<void> createEvent(String title, String description, String dateTime,
  //     String club, String tag) async {
  //   final url = event.createEvent;
  //   final body = json.encode({
  //     'title': title,
  //     'description': description,
  //     'dateTime': dateTime,
  //     'club': club,
  //     'tags': [tag],
  //   });
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {'Content-Type': 'application/json'},
  //       body: body,
  //     );
  //
  //     if (response.statusCode != 201) {
  //       throw Exception('Failed to create event');
  //     }
  //   } catch (e) {
  //     throw Exception('Error: $e');
  //   }
  // }

  Future<void> createTentativeEvent(
      String title, DateTime date, String venue) async {
    final url = event
        .createTentativeEvent; // Add this endpoint to your `endpoints.dart`
    final body = json.encode({
      'title': title,
      'date': date.toIso8601String(),
      'venue': venue,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create tentative event');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
