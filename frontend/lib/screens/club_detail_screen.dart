import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/club_model.dart';
import 'merch_detail_screen.dart';

class ClubDetailScreen extends StatefulWidget {
  final String clubId; // Club ID to fetch details

  const ClubDetailScreen({Key? key, required this.clubId}) : super(key: key);

  @override
  _ClubDetailScreenState createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  Club? club;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchClubDetails();
  }

  Future<void> fetchClubDetails() async {
    try {
      final response = await http.get(
        Uri.parse('https://iitgcampussync.onrender.com/api/clubs/${widget.clubId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          club = Club.fromJson(data);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load club details';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(club?.name ?? 'Club Details')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(club!.description, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              if (club!.merch.isNotEmpty) ...[
                const Text(
                  'Merch',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: club!.merch.length,
                    itemBuilder: (context, index) {
                      final merchItem = club!.merch[index];
                      return GestureDetector(
                        onTap: () {
                          // Passing the entire merch object instead of just the ID
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MerchDetailScreen(merch: merchItem),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  merchItem.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "₹${merchItem.price}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
