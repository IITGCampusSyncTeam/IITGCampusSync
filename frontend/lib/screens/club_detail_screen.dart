import 'package:flutter/material.dart';

/// Shows detailed information for a selected club.
class ClubDetailScreen extends StatelessWidget {
  final Map<String, String> club;
  const ClubDetailScreen({Key? key, required this.club}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(club['name']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          club['description']!,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
