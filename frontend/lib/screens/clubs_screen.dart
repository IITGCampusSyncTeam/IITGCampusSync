import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'club_detail_screen.dart';
import '../apis/protected.dart';
import '../constants/endpoints.dart';
import '../models/club_model.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({Key? key}) : super(key: key);

  @override
  _ClubsScreenState createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  List<Club> clubs = [];
  bool isLoading = true;
  String errorMessage = '';
  String userId = ''; // To store user ID

  @override
  void initState() {
    super.initState();
    fetchUserId(); // Fetch user ID first
    fetchClubs();
  }

  /// Fetch the user ID from SharedPreferences
  Future<void> fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString('user_data');

    print("Fetching user data...");
    print("Stored user_data: $userDataString"); // Debugging line

    if (userDataString == null || userDataString.isEmpty) {
      print("User data not found in SharedPreferences.");
      return;
    }

    try {
      final dynamic decodedUser = jsonDecode(userDataString);

      if (decodedUser is Map<String, dynamic> && decodedUser.containsKey('_id')) {
        setState(() {
          userId = decodedUser['_id']; // Ensure you're using '_id' from stored data
        });
        print("User ID: $userId");
      } else {
        print("User data structure is invalid.");
      }
    } catch (e) {
      print("Error decoding user data: $e");
    }
  }



  /// Fetch clubs from API
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
      appBar: AppBar(
        title: const Text(
          "Clubs",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 3,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ListView.builder(
          itemCount: clubs.length,
          itemBuilder: (context, index) {
            final club = clubs[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClubDetailScreen(clubId: club.id, userId: userId),
                  ),
                );
              },
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon Placeholder for Club Image
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.group,
                          size: 30,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Club Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              club.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              club.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
