import 'dart:io';
import 'package:flutter/material.dart';

class DynamicListItem {
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  DynamicListItem();
}

class ItineraryItem {
  TimeOfDay? time;
  final TextEditingController textController = TextEditingController();

  ItineraryItem({this.time});

  // Convert an ItineraryItem object into a Map
  Map<String, dynamic> toMap() {
    return {
      'time': time != null ? '${time!.hour}:${time!.minute}' : null,
      'text': textController.text,
    };
  }

  // Create an ItineraryItem object from a Map
  factory ItineraryItem.fromMap(Map<String, dynamic> map) {
    final item = ItineraryItem();
    if (map['time'] != null && (map['time'] as String).contains(':')) {
      final parts = map['time'].split(':');
      item.time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    item.textController.text = map['text'] ?? '';
    return item;
  }
}

class EventCreationProvider with ChangeNotifier {
  int currentPage = 0;
  final PageController pageController = PageController();

  // --- Step 1 Data ---
  File? bannerImage;
  final TextEditingController eventTitleController = TextEditingController();
  final TextEditingController numDaysController = TextEditingController();
  final TextEditingController venueLinkController = TextEditingController();
  final TextEditingController venueInstructionsController = TextEditingController();
  
  String? eventType;
  bool isPartOfSeries = false;
  DateTime? eventDate;
  TimeOfDay? eventTime;
  String? venue;
  int venueTypeIndex = 1; // 0 for Online, 1 for Offline (default to Offline)
  
  // --- Step 2 Data ---
  final TextEditingController guidelinesController = TextEditingController();
  final TextEditingController registrationFeeController = TextEditingController();
  final TextEditingController registrationLinkController = TextEditingController();
  DateTime? registrationLastDate;
  List<DynamicListItem> coHosts = [DynamicListItem()];
  final TextEditingController agendaController = TextEditingController();
  List<DynamicListItem> speakers = [DynamicListItem()];
  List<ItineraryItem> itinerary = [ItineraryItem()];
  List<DynamicListItem> communityLinks = [DynamicListItem()];
  List<DynamicListItem> pocs = [DynamicListItem()];
  bool isPaidRegistration = false;
  File? resourceFile;

  // --- Step 3 Data ---
  List<DynamicListItem> eventTeam = [DynamicListItem()];
  File? internalMaterialFile;
  List<String> sponsors = [];
  final TextEditingController sponsorInputController = TextEditingController();
  final TextEditingController otherRequirementsController = TextEditingController();

  // --- Page Navigation ---
  void goToPage(int page) {
    currentPage = page;
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  // --- Generic List Management ---
  void addSponsor() {
    final sponsorName = sponsorInputController.text.trim();
    if (sponsorName.isNotEmpty && !sponsors.contains(sponsorName)) {
      sponsors.add(sponsorName);
      sponsorInputController.clear();
      notifyListeners();
    }
  }

  void removeSponsor(String sponsorName) {
    sponsors.remove(sponsorName);
    notifyListeners();
  }

  void addItineraryItem() {
    itinerary.add(ItineraryItem());
    notifyListeners();
  }

  void removeItineraryItem(int index) {
    if (itinerary.length > 1) {
      itinerary[index].textController.dispose();
      itinerary.removeAt(index);
      notifyListeners();
    }
  }

  void addItem(List<DynamicListItem> list) {
    list.add(DynamicListItem());
    notifyListeners();
  }

  void removeItem(List<DynamicListItem> list, int index) {
    if (list.length > 1) {
      list[index].controller1.dispose();
      list[index].controller2.dispose();
      list.removeAt(index);
      notifyListeners();
    }
  }

  // --- State Setters ---
  void setRegistrationLastDate(DateTime date) {
    registrationLastDate = date;
    notifyListeners();
  }

  void setBannerImage(File image) {
    bannerImage = image;
    notifyListeners();
  }
  
  void setEventDate(DateTime date) {
    eventDate = date;
    notifyListeners();
  }

  void setEventTime(TimeOfDay time) {
    eventTime = time;
    notifyListeners();
  }

  void setFile(String type, File file) {
    if (type == 'resource') {
      resourceFile = file;
    } else if (type == 'internal') {
      internalMaterialFile = file;
    }
    notifyListeners();
  }

  void toggleState(String field, dynamic value) {
    switch (field) {
      case 'isPartOfSeries':
        isPartOfSeries = value;
        break;
      case 'isPaidRegistration':
        isPaidRegistration = value;
        break;
      case 'eventType':
        eventType = value;
        break;
      case 'venue':
        venue = value;
        break;
      case 'venueType':
        venueTypeIndex = value;
        break;
    }
    notifyListeners();
  }

  // --- Data Collection ---
  Map<String, dynamic> toMap() {
    return {
      // --- Step 1 Data ---
      'bannerImagePath': bannerImage?.path,
      'eventTitle': eventTitleController.text,
      'numDays': numDaysController.text,
      'eventType': eventType,
      'isPartOfSeries': isPartOfSeries,
      'eventDate': eventDate?.toIso8601String(),
      'eventTime': eventTime != null ? '${eventTime!.hour}:${eventTime!.minute}' : null,
      'venue': venue,
      'venueTypeIndex': venueTypeIndex,
      'venueLink': venueLinkController.text,
      'venueInstructions': venueInstructionsController.text,

      // --- Step 2 Data ---
      'agenda': agendaController.text,
      'guidelines': guidelinesController.text,
      'isPaidRegistration': isPaidRegistration,
      'registrationFee': registrationFeeController.text,
      'registrationLink': registrationLinkController.text,
      'registrationLastDate': registrationLastDate?.toIso8601String(),
      'speakers': speakers.map((s) => {'name': s.controller1.text, 'details': s.controller2.text}).toList(),
      'communityLinks': communityLinks.map((s) => {'link': s.controller1.text}).toList(),
      'pocs': pocs.map((s) => {'name': s.controller1.text, 'contact': s.controller2.text}).toList(),
      'coHosts': coHosts.map((s) => {'name': s.controller1.text}).toList(),
      'itinerary': itinerary.map((item) => item.toMap()).toList(),

      // --- Step 3 Data ---
      'otherRequirements': otherRequirementsController.text,
      'eventTeam': eventTeam.map((s) => {'name': s.controller1.text, 'contact': s.controller2.text}).toList(),
      'sponsors': sponsors,
    };
  }

  void fromMap(Map<String, dynamic> map) {
    try {
      // --- Step 1 Data ---
      bannerImage = map['bannerImagePath'] != null ? File(map['bannerImagePath']) : null;
      eventTitleController.text = map['eventTitle'] ?? '';
      numDaysController.text = map['numDays'] ?? '';
      eventType = map['eventType'];
      isPartOfSeries = map['isPartOfSeries'] ?? false;
      eventDate = map['eventDate'] != null ? DateTime.parse(map['eventDate']) : null;

      if (map['eventTime'] != null && (map['eventTime'] as String).contains(':')) {
        final parts = map['eventTime'].split(':');
        eventTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } else {
        eventTime = null;
      }

      venue = map['venue'];
      venueTypeIndex = map['venueTypeIndex'] ?? 1;
      venueLinkController.text = map['venueLink'] ?? '';
      venueInstructionsController.text = map['venueInstructions'] ?? '';

      // --- Step 2 Data ---
      agendaController.text = map['agenda'] ?? '';
      guidelinesController.text = map['guidelines'] ?? '';
      isPaidRegistration = map['isPaidRegistration'] ?? false;
      registrationFeeController.text = map['registrationFee'] ?? '';
      registrationLinkController.text = map['registrationLink'] ?? '';
      registrationLastDate = map['registrationLastDate'] != null ? DateTime.parse(map['registrationLastDate']) : null;

      // --- Step 3 Data ---
      otherRequirementsController.text = map['otherRequirements'] ?? '';
      sponsors = List<String>.from(map['sponsors'] ?? []);

      // --- Robust Reconstruction of Dynamic Lists ---

      // Helper function to safely parse a list of maps into a List<DynamicListItem>
      List<DynamicListItem> _rebuildList(String key, {String key1 = 'name', String? key2}) {
          if (map[key] == null) return [DynamicListItem()]; // Return a default empty item if key is missing

          List<dynamic> rawList = map[key];
          if (rawList.isEmpty) return [DynamicListItem()];

          return rawList.map((item) {
              final dynamicItem = DynamicListItem();
              dynamicItem.controller1.text = item[key1] ?? '';
              if (key2 != null) {
                 dynamicItem.controller2.text = item[key2] ?? '';
              }
              return dynamicItem;
          }).toList();
      }

      speakers = _rebuildList('speakers', key1: 'name', key2: 'details');
      pocs = _rebuildList('pocs', key1: 'name', key2: 'contact');
      eventTeam = _rebuildList('eventTeam', key1: 'name', key2: 'contact');
      coHosts = _rebuildList('coHosts', key1: 'name');
      communityLinks = _rebuildList('communityLinks', key1: 'link');

      if (map['itinerary'] != null) {
        List<dynamic> rawItinerary = map['itinerary'];
        if (rawItinerary.isNotEmpty) {
          itinerary = rawItinerary.map((item) => ItineraryItem.fromMap(item)).toList();
        } else {
          itinerary = [ItineraryItem()];
        }
      }

      notifyListeners();
    } catch (e) {
      print("Error loading draft data from map: $e");
      // Optionally, you could have a method here to reset the form to a clean state
    }
  }

  // --- Cleanup ---
  @override
  void dispose() {
    pageController.dispose();

    // Dispose all single TextEditingControllers
    eventTitleController.dispose();
    numDaysController.dispose();
    venueLinkController.dispose();
    venueInstructionsController.dispose();
    guidelinesController.dispose();
    registrationFeeController.dispose();
    registrationLinkController.dispose();
    agendaController.dispose();
    sponsorInputController.dispose();
    otherRequirementsController.dispose();

    // Dispose controllers in ALL dynamic lists
    final allDynamicLists = [speakers, communityLinks, pocs, coHosts, eventTeam];
    for (var list in allDynamicLists) {
      for (var item in list) {
        item.controller1.dispose();
        item.controller2.dispose();
      }
    }

    for (var item in itinerary) {
      item.textController.dispose();
    }

    super.dispose();
  }
}
