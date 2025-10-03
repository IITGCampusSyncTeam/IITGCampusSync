import 'package:flutter/material.dart';
import 'package:frontend/apis/tags/tags.dart';
import 'package:frontend/models/tag_model.dart';
import 'package:frontend/screens/splash_screen.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../../apis/events/event_api.dart';
//import 'package:flutter/material.dart';

class TentativeEventAddScreen extends StatefulWidget {
  @override
  _TentativeEventAddScreenState createState() =>
      _TentativeEventAddScreenState();
}

class _TentativeEventAddScreenState extends State<TentativeEventAddScreen> {
  final TextEditingController _eventNameController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedVenue;
  bool _isSeries = false;
  bool _isOfflineSelected = true;
  List<Tag>? futureTags;
  List<Tag> selectedTags = [];
  String? _seriesName = "Team Recruitment";
  String? _openTo = 'All';
  bool loading = true;

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 12,
                      weight: 500,
                      color: Color.fromARGB(255, 39, 39, 42),
                    ),
                  ),
                  //SizedBox(width: 10),
                  Text(
                    'Add a Event Series',
                    style: TextStyle(
                        color: Color.fromARGB(255, 39, 39, 42),
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: 0),
                  ),
                ],
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _seriesName,
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 113, 113, 123),
                    fontSize: 12,
                  ),
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 113, 113, 123),
                    fontSize: 12,
                  ),
                  fillColor: Color.fromARGB(255, 255, 237, 212),
                  filled: true,
                  // label: Text(
                  //   'Name',
                  //   style: TextStyle(
                  //     color: Color.fromARGB(255, 113, 113, 123),
                  //     fontSize: 15,
                  //     fontWeight: FontWeight.w400,
                  //   ),
                  // ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [
                  'Team Recruitment',
                  'Placement tests',
                  'Club orientation',
                ].map((String series) {
                  return DropdownMenuItem<String>(
                    value: series,
                    child: Text(series),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _seriesName = value;
                  });
                },
              ),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "You can add other events to this series as and when you plan. "
                  "You can edit/add to a series details from 'Events' tab as well.",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 39, 39, 42),
                    letterSpacing: 0,
                    height: 16 / 12,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        minimumSize: Size(142, 40),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        backgroundColor: Color.fromARGB(255, 228, 228, 231),
                        foregroundColor: Color.fromARGB(255, 39, 39, 42),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: Text('More Series info'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(178, 40),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        backgroundColor: Color.fromARGB(255, 39, 39, 42),
                        foregroundColor: Color.fromARGB(255, 250, 250, 250),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: Text('Add Series'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchTags();
  }

  void fetchTags() async {
    try {
      final res = await TagAPI().getAllTags();
      setState(() {
        futureTags = res;
        loading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.grey,
        ),
        title: Text(
          'Add tentative event to timeline',
          style: TextStyle(
            color: Color.fromARGB(255, 113, 113, 123),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
            padding: EdgeInsets.only(left: 8, right: 8),
            iconSize: 20,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: ClipOval(
                  child: Image.asset(
                    'assets/Avatar.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white,
                        child: Icon(Icons.person, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "What's Coming Up?",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
              ),
              SizedBox(height: 8),
              Text(
                'Fill in key info-date, time, venue-to keep your timeline\n'
                'clear.',
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.grey[600],
                    letterSpacing: 0),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Event Title',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Color.fromARGB(255, 113, 113, 123),
                    ),
                  ),
                  Text(
                    '*',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 105, 0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              TextField(
                controller: _eventNameController,
                style: TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(255, 113, 113, 123),
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintText: 'Event Name',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color.fromARGB(255, 113, 113, 123),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Color.fromARGB(255, 228, 228, 231),
                  filled: true,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Open to',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Color.fromARGB(255, 113, 113, 123),
                    ),
                  ),
                  Text(
                    '*',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 105, 0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                style: TextStyle(
                  color: Color.fromARGB(255, 113, 113, 123),
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
                items: ['All', 'First year UG', 'Final year UG', 'MTech']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _openTo = value!;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'All',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 113, 113, 123),
                    fontSize: 12,
                  ),
                  // hintText: 'All',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 113, 113, 123),
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: Color.fromRGBO(228, 228, 231, 1),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color.fromARGB(255, 228, 228, 231),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Part of a Series?',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 113, 113, 123),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          FlutterSwitch(
                            value: _isSeries,
                            onToggle: (value) {
                              setState(() {
                                _isSeries = value;
                              });
                            },
                            activeColor: Color.fromARGB(255, 39, 39, 42),
                            activeToggleColor: Colors.white,
                            // activeTrackColor: Color.fromARGB(255, 39, 39, 42),
                            inactiveToggleColor: Color.fromARGB(
                              255,
                              250,
                              250,
                              250,
                            ),
                            inactiveColor: Color.fromARGB(255, 228, 228, 231),
                            width: 44,
                            height: 24,
                            toggleSize: 20,
                            borderRadius: 16,
                            padding: 0.5,
                          ),
                        ],
                      ),
                    ),
                    if (_isSeries) ...[
                      SizedBox(height: 10),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 8.0),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 237, 212),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _seriesName ?? "Team Recruitment",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 113, 113, 123),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                            IconButton(
                              onPressed: _showBottomSheet,
                              constraints: BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.edit_outlined, size: 24.975),
                              color: Color.fromARGB(255, 39, 39, 42),
                              tooltip: 'Edit',
                            ),
                          ],
                        ),
                      ),
                      //),
                    ]
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'Event Date',
                            style: TextStyle(
                              color: Color.fromARGB(255, 113, 113, 123),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: '*',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 105, 0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        ListTile(
                          title: Text(
                            _selectedDate == null
                                ? 'Pick Event Date'
                                : "${_selectedDate!.toLocal()}".split(' ')[0],
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(255, 113, 113, 123)),
                          ),
                          trailing:
                              Icon(Icons.edit_calendar_outlined, size: 20),
                          tileColor: Color.fromARGB(255, 228, 228, 231),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _selectedDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'Time ',
                            style: TextStyle(
                              color: Color.fromARGB(255, 113, 113, 123),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: '(approx.)',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 113, 113, 123),
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                  text: '*',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 255, 105, 0)))
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        ListTile(
                          tileColor: Color.fromARGB(255, 228, 228, 231),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          title: Text(
                            _selectedTime == null
                                ? 'Pick Time'
                                : _selectedTime!.format(context),
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 113, 113, 123),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          trailing: Icon(Icons.access_time, size: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onTap: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime ?? TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedTime = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Venue',
                style: TextStyle(
                  color: Color.fromARGB(255, 113, 113, 123),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        hintText: 'Select Venue',
                        fillColor: Color.fromARGB(255, 228, 228, 231),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(
                        color: Color.fromARGB(255, 113, 113, 123),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      value: _selectedVenue,
                      items: [
                        'Main Auditorium',
                        'Lecture Hall 1',
                        'Lecture Hall 2',
                        'Lecture Hall 3',
                        'Lecture Hall 4',
                        'Mini Auditorium',
                        'Conference Center',
                        'Core 5',
                        'Old SAC',
                        'New SAC',
                      ].map((String venue) {
                        return DropdownMenuItem<String>(
                          value: venue,
                          child: Text(
                            venue,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedVenue = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 2.55),
                  Container(
                    height: 48.7,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 228, 228, 231),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () =>
                              setState(() => _isOfflineSelected = false),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: !_isOfflineSelected
                                  ? Colors.black
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Online',
                              style: TextStyle(
                                color: !_isOfflineSelected
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () =>
                              setState(() => _isOfflineSelected = true),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _isOfflineSelected
                                  ? Colors.black
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Offline',
                              style: TextStyle(
                                color: _isOfflineSelected
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  text: 'Tags / Interests',
                  style: TextStyle(
                    color: Color.fromARGB(255, 113, 113, 123),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Color.fromARGB(255, 255, 105, 0)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: 48,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 228, 228, 231),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedTags.isEmpty
                          ? 'Add'
                          : selectedTags.map((tag) => tag.title).join(', '),
                      style: TextStyle(
                        color: Color.fromARGB(255, 113, 113, 123),
                        fontSize: 12,
                      ),
                    ),
                    IconButton(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              return MultiSelectDialog<Tag>(
                                items: futureTags!
                                    .map((tag) =>
                                        MultiSelectItem<Tag>(tag, tag.title))
                                    .toList(),
                                initialValue: selectedTags,
                                title: const Text('Select Tags'),
                                confirmText: const Text(
                                  "OK",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                cancelText: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                itemsTextStyle: TextStyle(
                                    color: Color.fromARGB(255, 113, 113, 123),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                                listType: MultiSelectListType.CHIP,
                                onConfirm: (values) {
                                  setState(() {
                                    selectedTags = values;
                                  });
                                },
                              );
                            },
                          );
                        },
                        icon: Icon(
                          Icons.add,
                          color: Color.fromARGB(255, 39, 39, 42),
                          size: 20,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 228, 228, 231),
                  foregroundColor: Color.fromARGB(255, 39, 39, 42),
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Add Details'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  final eventName = _eventNameController.text;
                  if (eventName.isNotEmpty &&
                      _selectedDate != null &&
                      _selectedTime != null &&
                      selectedTags.isNotEmpty &&
                      _openTo != null &&
                      _selectedVenue != null) {
                    try {
                      await EventAPI().createTentativeEvent(
                          title: eventName,
                          date: _selectedDate!,
                          venue: _selectedVenue!,
                          time: _selectedTime!,
                          isSeries: _isSeries,
                          openTo: _openTo!,
                          isOffline: _isOfflineSelected,
                          tag: selectedTags,
                          seriesName: _seriesName!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tentative event created!')),
                      );
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SplashScreen()));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating event: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fill all required fields'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 39, 39, 42),
                  foregroundColor: Color.fromARGB(255, 250, 250, 250),
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Add to Timeline'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
