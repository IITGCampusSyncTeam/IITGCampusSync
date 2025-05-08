import 'package:flutter/material.dart';
import 'package:my_app/event_creation_form_screen.dart';
import 'package:my_app/tentative_event_add_screen.dart';


class EventPlannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Planner')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  hint: Text('Filter by Date'),
                  items: ['Today', 'This Week', 'This Month'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {},
                ),
                DropdownButton<String>(
                  hint: Text('Filter by Venue'),
                  items: ['Auditorium', 'Hall A', 'Hall B'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {},
                ),
                DropdownButton<String>(
                  hint: Text('Filter by Tags'),
                  items: ['Tech', 'Cultural', 'Sports'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {},
                ),
              ],
            ),
            SizedBox(height: 16),
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TentativeEventAddScreen()),
                );
              },
              child: Text('Add Tentative Event'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: List.generate(5, (index) {
                  return Card(
                    child: ListTile(
                      title: Text('Tentative Event ${index + 1}'),
                      subtitle: Text('Tap to publish as an event'),
                      trailing: Icon(Icons.edit),
                      onTap: () {},
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventCreationFormScreen()),
                );
              },
              child: Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}
