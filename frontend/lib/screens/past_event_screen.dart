import 'package:flutter/material.dart';

class PastEventScreen extends StatefulWidget {
  @override
  _PastEventScreenState createState() => _PastEventScreenState();
}

class _PastEventScreenState extends State<PastEventScreen> {
  final List<Map<String, String>> pastEvents = [
    {'name': 'Tech Conference 2023', 'date': '12 March 2023', 'venue': 'Auditorium'},
    {'name': 'Cultural Fest', 'date': '25 April 2023', 'venue': 'Hall A'},
    {'name': 'Sports Meet', 'date': '10 June 2023', 'venue': 'Stadium'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Past Events')),
      body: pastEvents.isEmpty
          ? Center(child: Text('No past events available'))
          : ListView.builder(
              itemCount: pastEvents.length,
              itemBuilder: (context, index) {
                final event = pastEvents[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(event['name']!),
                    subtitle: Text('${event['date']} | ${event['venue']}'),
                    leading: Icon(Icons.event_available),
                    trailing: Icon(Icons.feedback_outlined),
                    onTap: () {
                      _showFeedbackDialog(context, event['name']!);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showFeedbackDialog(BuildContext context, String eventName) {
    final TextEditingController _feedbackController = TextEditingController();
    int selectedRating = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Feedback for "$eventName"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rate the event:'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _feedbackController,
                decoration: InputDecoration(
                  hintText: 'Enter your feedback...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () {
                final feedback = _feedbackController.text.trim();
                if (feedback.isNotEmpty && selectedRating > 0) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Feedback submitted!')),
                  );

                  // Send to backend or Firestore
                  print('Feedback: $feedback');
                  print('Rating: $selectedRating');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please give a rating and feedback')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
