import 'package:flutter/foundation.dart';
import '../apis/events/event_api.dart';
import '../models/event.dart';

class EventProvider with ChangeNotifier {
  final EventAPI _eventAPI = EventAPI();

  List<Event> _allEvents = [];
  List<Event> _upcomingEvents = [];
  List<Event> _rsvpdUpcomingEvents = [];
  List<Event> _attendedEvents = [];
  bool _isLoading = false;
  String _errorMessage = '';
  DateTime _selectedDate = DateTime.now();

  // Getters
  List<Event> get allEvents => _allEvents;
  List<Event> get upcomingEvents => _upcomingEvents;
  List<Event> get rsvpdUpcomingEvents => _rsvpdUpcomingEvents;
  List<Event> get attendedEvents => _attendedEvents;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;


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
  Future<void> fetchUpcomingEvents() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final eventsData = await _eventAPI.fetchUpcomingEvents();
      _upcomingEvents = eventsData.map((data) => Event.fromJson(data)).toList();
      print("Fetched All Upcoming Events: ${_upcomingEvents.length}");
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    notifyListeners();
    try {
      // NOTE: You must add a 'fetchRsvpdUpcomingEvents' method to your EventApi class
      final eventsData = await _eventAPI.fetchRsvpdUpcomingEvents();
      _rsvpdUpcomingEvents = eventsData.map((data) => Event.fromJson(data)).toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAttendedEvents() async {
    _isLoading = true;
    notifyListeners();
    try {
      final eventsData = await _eventAPI.fetchAttendedEvents();
      _attendedEvents = eventsData.map((data) => Event.fromJson(data)).toList();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }


  Future<void> toggleRsvpStatus(String eventId) async {

    final eventIndex = _upcomingEvents.indexWhere((event) => event.id == eventId);
    if (eventIndex == -1) return; // Exit if the event isn't found


    _upcomingEvents[eventIndex].isRsvpd = !_upcomingEvents[eventIndex].isRsvpd;
    notifyListeners();

    try {
      await _eventAPI.rsvpForEvent(eventId);

      // 4. On success, refresh ALL relevant lists from the server.
      // This keeps both the Explore screen and My Events screen in sync.
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
