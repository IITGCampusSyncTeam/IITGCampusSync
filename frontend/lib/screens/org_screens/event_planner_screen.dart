import 'package:flutter/material.dart';
import 'package:frontend/screens/org_screens/event_creation_form_srceen.dart';
import 'package:frontend/screens/org_screens/tentative_event_add_screen.dart';
import 'package:provider/provider.dart';

import '../../providers/eventProvider.dart';

class EventPlannerScreen extends StatefulWidget {
  @override
  _EventPlannerScreenState createState() => _EventPlannerScreenState();
}

class _EventPlannerScreenState extends State<EventPlannerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).fetchAllEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Planner')),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          if (eventProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (eventProvider.errorMessage.isNotEmpty) {
            return Center(child: Text(eventProvider.errorMessage));
          }

          // Filter tentative events based on search query
          final tentativeEvents = eventProvider.tentativeEvents
              .where((event) => event.title
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
              .toList();

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Timeline Placeholder
                Text(
                  'Tentative Tenure Timeline',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 50,
                  color: Colors.grey[300],
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: Text('Timeline Placeholder')),
                ),

                // Add Tentative Event
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TentativeEventAddScreen()),
                    );
                  },
                  child: Text('Add Tentative Event'),
                ),
                SizedBox(height: 16),

                // Tentative Events List
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: tentativeEvents.length,
                  itemBuilder: (context, index) {
                    final event = tentativeEvents[index];
                    return Card(
                      child: ListTile(
                        title: Text(event.title),
                        subtitle: Text('Tap to publish as an event'),
                        trailing: Icon(Icons.edit),
                        onTap: () {
                          // Future: Navigate to event edit/publish screen
                        },
                      ),
                    );
                  },
                ),

                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EventCreationFormScreen()),
                    );
                  },
                  child: Text('Create Event'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
