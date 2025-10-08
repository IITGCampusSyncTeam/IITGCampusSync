import 'dart:convert';

import 'package:frontend/constants/endpoints.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:http/http.dart' as http;

class EventAPI {

  final StorageService _storageService = StorageService();

  Future<List> fetchEvents() async {
    final url = event.getAllEvents;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        return decodedBody['events'] ?? [];
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
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        return decodedBody['events'];
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
          .toIso8601String(),
      // You can assume this is IST; backend will convert to UTC
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

  Future<bool> rsvpForEvent(String eventId) async {
    // read the token
    final token = await _storageService.readToken();

    // Check if token exists, otherwise the user is not logged in
    //  if (token == null) {
    //   throw Exception('User is not authenticated.');
    // }

    final response = await http.post(
      Uri.parse('${Constants.API_BASE_URL}/registrations/events/$eventId/rsvp'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      return responseBody['data']['rsvpd'];
    } else {
      print("Failed to RSVP. Status: ${response.statusCode}, Body: ${response.body}");
      throw Exception('Failed to RSVP for event.');
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

  Future<void> createTentativeEvent(String title, DateTime date,
      String venue) async {
    final url = event
        .createTentativeEvent;
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

  // Fetches upcoming events the user has RSVP'd for
  Future<List> fetchRsvpdUpcomingEvents() async {
    final url = event.rsvpdUpcomingEvents;

    final token = await _storageService.readToken();
    if (token == null) throw Exception('User not authenticated.');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedBody = jsonDecode(response.body);
      return decodedBody['events'] ?? [];
    } else {
      throw Exception('Failed to load RSVP\'d upcoming events.');
    }
  }

  // Fetches past events the user has RSVP'd for (attended)
  Future<List> fetchAttendedEvents() async {
    final url = event.attendedEvents;
    final token = await _storageService.readToken();
    if (token == null) throw Exception('User not authenticated.');


    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedBody = jsonDecode(response.body);
      return decodedBody['events'] ?? [];
    } else {
      throw Exception('Failed to load attended events.');
    }
  }
}





