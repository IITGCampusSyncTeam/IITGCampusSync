import 'package:flutter/material.dart';
import 'package:frontend/screens/event_creation_form_srceen.dart';


// Event Screen
class OrgEventScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text('Event Details'),
  actions: [
    IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventCreationFormScreen(),
          ),
        );
      },
    ),
  ],
),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text('Event Banner')),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Basic Details',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Name: Tech Conference 2024'),
                    Text('Organizing Body: XYZ Club'),
                    Text('Date: 15 March 2024'),
                    Text('Day: Friday'),
                    Text('Time: 10:00 AM - 2:00 PM'),
                    Text('Venue: Auditorium'),
                    Text('Tags: Tech, Conference'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Organizers Profile',
                  style: TextStyle(color: Colors.blue)),
              onTap: () {},
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('More Events / Related Events',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Optional if related events exist'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rating (after event)',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Ideating'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
