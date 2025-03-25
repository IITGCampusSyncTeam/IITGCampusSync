import 'dart:convert';

import 'package:frontend/constants/endpoints.dart';
import 'package:http/http.dart' as http;

class EventAPI {
  Future<List> fetchEvents() async {
    final url = event.getAllEvents;
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

  Future<void> createEvent(
      String title, String description, String dateTime, String club) async {
    // final url = event.createEvent;
    final url = 'http://10.150.47.182:3000/api/events/create-event';
    final body = json.encode({
      'title': title,
      'description': description,
      'dateTime': dateTime,
      'club': club,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create event');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
