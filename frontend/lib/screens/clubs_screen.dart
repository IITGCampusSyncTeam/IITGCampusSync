import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'club_detail_screen.dart';
import '../apis/protected.dart';
import '../constants/endpoints.dart';
import '../models/club_model.dart'; // Import the Club model

/// Displays a list of clubs fetched from the backend.
class ClubsScreen extends StatefulWidget {
  const ClubsScreen({Key? key}) : super(key: key);

  @override
  _ClubsScreenState createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  List<Club> clubs = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchClubs();
  }

  Future<void> fetchClubs() async {
    try {
      final token = await getAccessToken(); // Retrieve authentication token
      if (token == 'error') {
        setState(() {
          isLoading = false;
          errorMessage = 'Authentication required.';
        });
        return;
      }

      final response = await http.get(
        Uri.parse(ClubEndPoints.cluburl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> clubList = jsonDecode(response.body);
        setState(() {
          clubs = clubList.map((clubJson) => Club.fromJson(clubJson)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load clubs.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clubs")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView.builder(
        itemCount: clubs.length,
        itemBuilder: (context, index) {
          final club = clubs[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(club.name),
              subtitle: Text(club.description),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClubDetailScreen(clubId: club.id,),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
