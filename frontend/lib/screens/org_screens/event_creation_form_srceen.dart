import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/eventProvider.dart';

class EventCreationFormScreen extends StatefulWidget {
  final Map<String, dynamic>? eventData;

  EventCreationFormScreen({this.eventData});

  @override
  _EventCreationFormScreenState createState() =>
      _EventCreationFormScreenState();
}

class _EventCreationFormScreenState extends State<EventCreationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  DateTime? _selectedDate;
  String? _selectedVenue;
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    if (widget.eventData != null) {
      _eventNameController.text = widget.eventData!['title'] ?? '';
      _eventDescriptionController.text = widget.eventData!['description'] ?? '';
      _selectedDate = widget.eventData!['dateObject'];
      _selectedVenue = widget.eventData!['venue'];
      _selectedTag = widget.eventData!['tags']?[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Event Creation Form')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _eventNameController,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter an event name'
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _eventDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Event Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter an event description'
                    : null,
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Pick Event Date'
                    : 'Event Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
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
              DropdownButtonFormField<String>(
                value: _selectedVenue,
                decoration: InputDecoration(
                  labelText: 'Select Venue',
                  border: OutlineInputBorder(),
                ),
                items: ['Auditorium', 'Hall A', 'Hall B']
                    .map((String venue) => DropdownMenuItem<String>(
                          value: venue,
                          child: Text(venue),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVenue = value;
                  });
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTag,
                decoration: InputDecoration(
                  labelText: 'Select Tag',
                  border: OutlineInputBorder(),
                ),
                items: ['Tech', 'Cultural', 'Sports']
                    .map((String tag) => DropdownMenuItem<String>(
                          value: tag,
                          child: Text(tag),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTag = value;
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _selectedDate != null &&
                      _selectedVenue != null &&
                      _selectedTag != null) {
                    final title = _eventNameController.text.trim();
                    final description = _eventDescriptionController.text.trim();
                    final date = _selectedDate!;
                    final venue = _selectedVenue!;
                    final club =
                        '67cdd9f518c21216e18a728c'; // TODO: Replace with actual club ID

                    try {
                      await eventProvider.createEvent(
                        title,
                        description,
                        date,
                        club,
                      );

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Event Published Successfully!')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: Text('Publish Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
//
// class EventCreationFormScreen extends StatefulWidget {
//   final Map<String, dynamic>? eventData;
//
//   EventCreationFormScreen({this.eventData});
//
//   @override
//   _EventCreationFormScreenState createState() =>
//       _EventCreationFormScreenState();
// }
//
// class _EventCreationFormScreenState extends State<EventCreationFormScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _eventNameController = TextEditingController();
//   final TextEditingController _eventDescriptionController =
//       TextEditingController();
//   DateTime? _selectedDate;
//   String? _selectedVenue;
//   String? _selectedTag;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.eventData != null) {
//       _eventNameController.text = widget.eventData!['title'] ?? '';
//       _eventDescriptionController.text = widget.eventData!['description'] ?? '';
//       _selectedDate = widget.eventData!['dateObject'];
//       _selectedVenue = widget.eventData!['venue'];
//       _selectedTag = widget.eventData!['tags']?[0];
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Event Creation Form')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: _eventNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Event Name',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) => value == null || value.isEmpty
//                     ? 'Please enter an event name'
//                     : null,
//               ),
//               SizedBox(height: 16),
//               TextFormField(
//                 controller: _eventDescriptionController,
//                 decoration: InputDecoration(
//                   labelText: 'Event Description',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//                 validator: (value) => value == null || value.isEmpty
//                     ? 'Please enter an event description'
//                     : null,
//               ),
//               SizedBox(height: 16),
//               ListTile(
//                 title: Text(_selectedDate == null
//                     ? 'Pick Event Date'
//                     : 'Event Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
//                 trailing: Icon(Icons.calendar_today),
//                 onTap: () async {
//                   DateTime? pickedDate = await showDatePicker(
//                     context: context,
//                     initialDate: _selectedDate ?? DateTime.now(),
//                     firstDate: DateTime.now(),
//                     lastDate: DateTime(2100),
//                   );
//                   if (pickedDate != null) {
//                     setState(() {
//                       _selectedDate = pickedDate;
//                     });
//                   }
//                 },
//               ),
//               SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _selectedVenue,
//                 decoration: InputDecoration(
//                   labelText: 'Select Venue',
//                   border: OutlineInputBorder(),
//                 ),
//                 items: ['Auditorium', 'Hall A', 'Hall B']
//                     .map((String venue) => DropdownMenuItem<String>(
//                           value: venue,
//                           child: Text(venue),
//                         ))
//                     .toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedVenue = value;
//                   });
//                 },
//               ),
//               SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _selectedTag,
//                 decoration: InputDecoration(
//                   labelText: 'Select Tag',
//                   border: OutlineInputBorder(),
//                 ),
//                 items: ['Tech', 'Cultural', 'Sports']
//                     .map((String tag) => DropdownMenuItem<String>(
//                           value: tag,
//                           child: Text(tag),
//                         ))
//                     .toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedTag = value;
//                   });
//                 },
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate() &&
//                       _selectedDate != null &&
//                       _selectedVenue != null &&
//                       _selectedTag != null) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Event Published Successfully!')),
//                     );
//                     Navigator.pop(context);
//                   }
//                 },
//                 child: Text('Publish Event'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
