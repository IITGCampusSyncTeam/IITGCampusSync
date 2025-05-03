import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:frontend/apis/protected.dart';
import 'package:frontend/constants/endpoints.dart';
import 'package:frontend/models/club_model.dart';
import 'package:frontend/models/event.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Club> clubs = [];
  List<Event> events = [];
  bool isLoading = true;
  bool isLoading2 = true;
  String errorMessage = '';
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

  Future<void> fetchEvents() async {
    try {
      final token = await getAccessToken(); // Retrieve authentication token
      if (token == 'error') {
        setState(() {
          isLoading2 = false;
          errorMessage = 'Authentication required.';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${backend.uri}/get-events'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> eventList = jsonDecode(response.body);
        setState(() {
          events =
              eventList.map((eventJSON) => Event.fromJson(eventJSON)).toList();
          isLoading2 = false;
        });
      } else {
        setState(() {
          isLoading2 = false;
          errorMessage = 'Failed to load events.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading2 = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchClubs();
    fetchEvents();
  }

  Future<List<Club>> getSuggestions(String query) async {
    if (query.isEmpty) {
      return [];
    }
    return clubs
        .where((club) => club.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // backgroundColor: Colors.black87,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TypeAheadField<Club>(
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        filled: true,
                        fillColor: Color.fromARGB(255, 39, 39, 39),
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey,
                        )),
                  );
                },
                suggestionsCallback: getSuggestions,
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      child: ClipOval(
                        child: Image.network(
                          suggestion.images,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.group,size: 30,);
                          },
                        ),
                      ),
                    ),
                    title: Text(suggestion.name),
                    subtitle: Text(suggestion.description),
                  );
                },
                onSelected: (suggestion) {
                  // You can handle search result click here
                  print('Selected: $suggestion');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
