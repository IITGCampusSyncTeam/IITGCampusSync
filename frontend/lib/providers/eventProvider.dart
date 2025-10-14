import 'package:flutter/foundation.dart';
import '../apis/events/event_api.dart';
import '../models/event.dart';
import '../services/storage_service.dart';

class EventProvider with ChangeNotifier {
  final EventAPI _eventAPI = EventAPI();

  List<Event> _allEvents = [];
  List<Event> _upcomingEvents = [];
  List<Event> _rsvpdUpcomingEvents = [];
  List<Event> _attendedEvents = [];
  bool _isLoading = false;
  String _errorMessage = '';
  DateTime _selectedDate = DateTime.now();
  List<Event> _filteredEvents = [];

  // Getters
  List<Event> get allEvents => _allEvents;
  List<Event> get upcomingEvents => _upcomingEvents;
  List<Event> get rsvpdUpcomingEvents => _rsvpdUpcomingEvents;
  List<Event> get attendedEvents => _attendedEvents;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;
  List<Event> get filteredEvents => _filteredEvents;


  Future<void> fetchAllData() async {
    _isLoading = true;
    notifyListeners();

    // This runs all fetches in parallel for better performance
    await Future.wait([
      fetchAllEvents(),
      fetchUpcomingEvents(),
      fetchRsvpdUpcomingEvents(),
      fetchAttendedEvents(),
    ]);

    _isLoading = false;
    notifyListeners();
  }
  // Set selected date (for calendar navigation)
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Fetch all events
  Future<void> fetchAllEvents() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final eventsData = await _eventAPI.fetchEvents();
      _allEvents = eventsData.map((data) => Event.fromJson(data)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch upcoming events
  // Future<void> fetchUpcomingEvents() async {
  //   _isLoading = true;
  //   _errorMessage = '';
  //   notifyListeners();
  //
  //   try {
  //     final eventsData = await _eventAPI.fetchUpcomingEvents();
  //     _upcomingEvents = eventsData.map((data) => Event.fromJson(data)).toList();
  //     print("Fetched All Upcoming Events: ${_upcomingEvents.length}");
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> fetchUpcomingEvents() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    //print("--- STARTING FETCH UPCOMING EVENTS ---");

    try {
      // This calls your EventAPI to get the raw list of data
      final List<dynamic> eventsData = await _eventAPI.fetchUpcomingEvents();

      //print("1. DATA RECEIVED IN PROVIDER: Found ${eventsData.length} raw event items.");

      if (eventsData.isEmpty) {
        //print("2. CONCLUSION: The API returned an empty list.");
        _upcomingEvents = []; // Set to empty list
      } else {
        //print("2. PARSING DATA NOW...");

        List<Event> parsedEvents = [];
        for (var data in eventsData) {
          try {
            // Try to convert each piece of raw data into a structured Event object
            parsedEvents.add(Event.fromJson(data));
          } catch (e) {
            // If this fails, it will print the exact data and error
            // print("-----------------------------------------");
            // print("❌ FAILED TO PARSE ONE EVENT. ERROR: $e");
            // print("   Problematic Event Data: $data");
            // print("-----------------------------------------");
          }
        }

        _upcomingEvents = parsedEvents;
        //print("3. CONCLUSION: Successfully parsed ${_upcomingEvents.length} events.");
      }

    } catch (e) {
      _errorMessage = e.toString();
      //print("❌ CATASTROPHIC ERROR in provider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
      //print("--- FETCH UPCOMING EVENTS FINISHED ---");
    }
  }

  void applyFiltersAndNotify(Map<String, dynamic>? filters) {

    // If filters are null or reset, show all events.
    if (filters == null) {
      _filteredEvents = List.from(_allEvents);
      notifyListeners();
      return;
    }

    // Start with a fresh copy of all events
    List<Event> tempEvents = List.from(_allEvents);

    // 1. DATE FILTER (From/To only)
    final DateTime? fromDate = filters['from'] as DateTime?;
    final DateTime? toDate = filters['to'] as DateTime?;

    if (fromDate != null) {
      // Keep events that are on or after the start of the 'from' date
      tempEvents.retainWhere((event) => !event.dateTime.isBefore(fromDate));
    }
    if (toDate != null) {
      // Keep events that are before the start of the day *after* the 'to' date
      final DateTime inclusiveToDate = DateTime(toDate.year, toDate.month, toDate.day + 1);
      tempEvents.retainWhere((event) => event.dateTime.isBefore(inclusiveToDate));
    }

    // 2. VENUE FILTER
    final String? venueType = filters['venue'] as String?;
    final String? location = filters['location'] as String?;
    
    if (venueType != null) {
      tempEvents.retainWhere((event) => event.venueType == venueType);
    }
    if (location != null) {
      tempEvents.retainWhere((event) => event.venue == location);
    }
    
    // 3. ORGANIZER FILTER
    final organizers = filters['organizers'] as Map<String, dynamic>?;
    if (organizers != null) {
      final bool isGymkhanaChecked = organizers['gymkhanaChecked'] as bool? ?? false;
      final String? selectedBoard = organizers['gymkhanaBoard'] as String?;

      if (isGymkhanaChecked) {
        if (selectedBoard != null && selectedBoard != 'All Boards') {
          // Filter by a specific club/board name
          tempEvents.retainWhere((event) => event.club?.name == selectedBoard);
        } else {
          // Filter for any event that has a club associated with it
          tempEvents.retainWhere((event) => event.club != null);
        }
      }
    }

    // Update the final list and notify listeners
    _filteredEvents = tempEvents;
    notifyListeners();
  }

  // Create a new event
  Future<void> createEvent(
    String title,
    String description,
    DateTime dateTime,
    String club,
  ) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _eventAPI.createEvent(
          title: title, description: description, date: dateTime, club: club);

      // Refresh events after creating a new one
      await fetchAllEvents();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRsvpdUpcomingEvents() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    //print("--- FETCHING RSVP'D UPCOMING EVENTS ---");
    try {
      // 🧱 Developer bypass: hardcoded dev user ID (only during development)
      //const devUserId = '67cdd269256701c667eb3c00';
      //print("⚡ Developer bypass active. Using devUserId: $devUserId");
      final eventsData = await _eventAPI.fetchRsvpdUpcomingEvents();
      if (eventsData.isEmpty) {
        //print("⚠️ No RSVP'd upcoming events returned from API.");
        _rsvpdUpcomingEvents = [];
      } else {
        List<Event> parsedEvents = [];

        for (var data in eventsData) {
          try {
            Event event = Event.fromJson(data);
            event.isRsvpd = true; // All events returned here are RSVP'd
            parsedEvents.add(event);
          } catch (e) {
            //print("❌ Failed to parse one RSVP'd event: $e");
            print("   Event Data: $data");
          }
        }


        _rsvpdUpcomingEvents = parsedEvents;
        print("✅ Parsed ${_rsvpdUpcomingEvents.length} RSVP'd upcoming events.");
      }
    } catch (e) {
      _errorMessage = e.toString();
      print("❌ Error fetching RSVP'd upcoming events: $e");
      _rsvpdUpcomingEvents = [];
    } finally {
      _isLoading = false;
      notifyListeners();
      print("--- FETCH RSVP'D UPCOMING EVENTS COMPLETE ---");
    }
  }

  Future<void> fetchAttendedEvents() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    //print("--- FETCHING ATTENDED EVENTS ---");

    try {
      // const devUserId = '67cdd269256701c667eb3c00';
      // print("⚡ Developer bypass active. Using devUserId: $devUserId");
      final eventsData = await _eventAPI.fetchAttendedEvents();

      if (eventsData.isEmpty) {
        //print("⚠️ No attended events returned from API.");
        _attendedEvents = [];
      } else {
        List<Event> parsedEvents = [];

        for (var data in eventsData) {
          try {
            Event event = Event.fromJson(data);
            event.isRsvpd = true; // All attended events are RSVP'd
            parsedEvents.add(event);
          } catch (e) {
            print("❌ Failed to parse one attended event: $e");
            print("   Event Data: $data");
          }
        }

        _attendedEvents = parsedEvents;
        //print("✅ Parsed ${_attendedEvents.length} attended events.");
      }
    } catch (e) {
      _errorMessage = e.toString();
      print("❌ Error fetching attended events: $e");
      _attendedEvents = [];
    } finally {
      _isLoading = false;
      notifyListeners();
      print("--- FETCH ATTENDED EVENTS COMPLETE ---");
    }
  }


  Future<void> toggleRsvpStatus(String eventId) async {
    //print("--- TOGGLING RSVP STATUS FOR EVENT: $eventId ---");

    final eventIndex = _upcomingEvents.indexWhere((event) => event.id == eventId);
    if (eventIndex == -1) return; // Exit if the event isn't found


    _upcomingEvents[eventIndex].isRsvpd = !_upcomingEvents[eventIndex].isRsvpd;
    notifyListeners();

    try {
      final success = await _eventAPI.rsvpForEvent(eventId);
      print("✅ RSVP toggled on server successfully: $success");


      await fetchUpcomingEvents();
      await fetchRsvpdUpcomingEvents();


    } catch (error) {
      // 5. If the API call fails, revert the optimistic change.
      _upcomingEvents[eventIndex].isRsvpd = !_upcomingEvents[eventIndex].isRsvpd;
      notifyListeners();
      print("Error toggling RSVP: $error");
    }
  }


  // Get events for a specific club
  List<Event> getEventsForClub(String clubId) {
    return _allEvents.where((event) => event.club == clubId).toList();
  }

// get tentative events
  List<Event> get tentativeEvents =>
      _allEvents.where((event) => event.status == 'tentative').toList();

  // Get events for a specific day
  List<Event> getEventsForDay(DateTime date) {
    return _allEvents
        .where((event) =>
            event.dateTime.year == date.year &&
            event.dateTime.month == date.month &&
            event.dateTime.day == date.day)
        .toList();
  }

  // Get events for a specific week
  List<Event> getEventsForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(Duration(days: 6));
    return _allEvents
        .where((event) =>
            event.dateTime.isAfter(weekStart.subtract(Duration(days: 1))) &&
            event.dateTime.isBefore(weekEnd.add(Duration(days: 1))))
        .toList();
  }

  // Get events for a specific month
  List<Event> getEventsForMonth(int year, int month) {
    return _allEvents
        .where((event) =>
            event.dateTime.year == year && event.dateTime.month == month)
        .toList();
  }
}
