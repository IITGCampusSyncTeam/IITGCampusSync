import 'package:flutter/foundation.dart';
import 'package:frontend/apis/events/event_api.dart';
import 'package:frontend/models/event.dart';

class EventProvider with ChangeNotifier {
  final EventAPI _eventAPI = EventAPI();

  List<Event> _allEvents = [];
  List<Event> _upcomingEvents = [];
  bool _isLoading = false;
  String _errorMessage = '';
  DateTime _selectedDate = DateTime.now();

  // Getters
  List<Event> get allEvents => _allEvents;
  List<Event> get upcomingEvents => _upcomingEvents;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;

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
