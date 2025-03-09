import 'package:flutter/material.dart';
import 'club_detail_screen.dart';

/// Displays a list of clubs as cards. Tapping a card navigates to the club detail screen.
class ClubsScreen extends StatelessWidget {
  ClubsScreen({Key? key}) : super(key: key);

  // Dummy list of clubs.
  final List<Map<String, String>> clubs = [
    {
      'name': 'Chess Club',
      'description': 'A club for chess enthusiasts.',
    },
    {
      'name': 'Art Club',
      'description': 'Express your creativity with us!',
    },
    {
      'name': 'Robotics Club',
      'description': 'Innovate and build amazing robots.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: clubs.length,
      itemBuilder: (context, index) {
        final club = clubs[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(club['name']!),
            subtitle: Text(club['description']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClubDetailScreen(club: club),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
