import 'package:flutter/material.dart';

class EventCreationFormScreen extends StatefulWidget {
  @override
  _EventCreationFormScreenState createState() => _EventCreationFormScreenState();
}

class _EventCreationFormScreenState extends State<EventCreationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedVenue;
  String? _selectedTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Creation Form')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Name Field
                TextFormField(
                  controller: _eventNameController,
                  decoration: InputDecoration(
                    labelText: 'Event Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an event name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Event Description Field
                TextFormField(
                  controller: _eventDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Event Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an event description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Date Picker
                ListTile(
                  title: Text(_selectedDate == null
                      ? 'Pick Event Date'
                      : 'Event Date: ${_selectedDate.toString().split(' ')[0]}'),
                  trailing: Icon(Icons.calendar_today),
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
                SizedBox(height: 16),

                // Time Picker
                ListTile(
                  title: Text(_selectedTime == null
                      ? 'Pick Event Time'
                      : 'Event Time: ${_selectedTime!.format(context)}'),
                  trailing: Icon(Icons.access_time),
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedTime = pickedTime;
                      });
                    }
                  },
                ),
                SizedBox(height: 16),

                // Venue Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Venue',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Auditorium', 'Hall A', 'Hall B'].map((String venue) {
                    return DropdownMenuItem<String>(
                      value: venue,
                      child: Text(venue),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedVenue = value;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Tag Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Tag',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Tech', 'Cultural', 'Sports'].map((String tag) {
                    return DropdownMenuItem<String>(
                      value: tag,
                      child: Text(tag),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTag = value;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Publish Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _selectedDate != null &&
                        _selectedTime != null &&
                        _selectedVenue != null &&
                        _selectedTag != null) {

                      final DateTime eventDateTime = DateTime(
                        _selectedDate!.year,
                        _selectedDate!.month,
                        _selectedDate!.day,
                        _selectedTime!.hour,
                        _selectedTime!.minute,
                      );

                      print('Event: ${_eventNameController.text}');
                      print('Description: ${_eventDescriptionController.text}');
                      print('DateTime: $eventDateTime');
                      print('Venue: $_selectedVenue');
                      print('Tag: $_selectedTag');

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Event Published Successfully!')),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all fields')),
                      );
                    }
                  },
                  child: Text('Publish Event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
