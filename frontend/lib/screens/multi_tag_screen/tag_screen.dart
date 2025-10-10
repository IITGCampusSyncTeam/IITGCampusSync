import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/constants/endpoints.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/intro_screens/intro_screen_3.dart';
import 'package:frontend/screens/multi_tag_screen/tag_chip.dart';
import 'package:frontend/providers/tag_repo.dart';
import 'package:frontend/screens/user_profile_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TagScreen extends StatefulWidget {
  const TagScreen({super.key});

  @override
  State<TagScreen> createState() => _TagScreenState();
}

class _TagScreenState extends State<TagScreen> {
  final TagRepo tagRepo = const TagRepo();

  List<Map<String, dynamic>> availableTags = [];
  final ValueNotifier<List<String>> selectedTagIds = ValueNotifier([]);
  bool isLoading = true;

  //user email
  // Empty = not signed in
  String? userEmail;
  //String? userEmail = "@iitg.ac.in";(for testing without login)

  @override
  void initState() {
    super.initState();
    _loadTags();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');

    if (userJson != null) {
      final user = jsonDecode(userJson);
      setState(() {
        userEmail = user['email'] ?? '';
      });
      log("Fetched user email: $userEmail");
    } else {
      log("No user data found in SharedPreferences.");
    }
    // manual email for testing without login
    // userEmail = "@iitg.ac.in";
  }

  Future<void> _loadTags() async {
    try {
      final tags = await tagRepo.getAvailableTags();
      setState(() {
        availableTags = tags;
        isLoading = false;
      });
    } catch (e) {
      log("Error loading tags: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateUserTags() async {
    if (userEmail == null || userEmail!.isEmpty) {
      _showSnackBar(
        "Please sign in to continue!",
        backgroundColor: Colors.redAccent,
        icon: Icons.error_outline,
      );
      log("User not signed in — cannot update tags");
      return;
    }

    try {
      final response = await http.put(
        Uri.parse(UserTag.updateUserTags()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': userEmail, 'tagIds': selectedTagIds.value}),
      );

      if (response.statusCode == 200) {
        _showSnackBar(
          "Your interests were saved successfully!",
          backgroundColor: Colors.green,
          icon: Icons.check_circle_outline,
        );
        log("Tags updated successfully for $userEmail");

        // Navigate to UserProfile on successful continuation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserProfileScreen()),
        );
      } else {
        final error = jsonDecode(response.body);
        _showSnackBar(
          "Error: ${error['error'] ?? 'Failed to update tags'}",
          backgroundColor: Colors.redAccent,
          icon: Icons.error_outline,
        );
        log("Error updating tags: ${response.body}");
      }
    } catch (e) {
      _showSnackBar(
        "An error occurred: $e",
        backgroundColor: Colors.redAccent,
        icon: Icons.error_outline,
      );
      log("Exception updating tags: $e");
    }
  }

  void _showSnackBar(String message,
      {Color backgroundColor = Colors.black87, IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    selectedTagIds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, width),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: height * 0.02),
                  SvgPicture.asset(
                    'assets/images/Avatar.svg',
                    width: width * 0.065,
                    height: height * 0.065,
                  ),
                  SizedBox(height: height * 0.02),
                  Text(
                    "Choose your Interests",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: width * 0.06,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'SaansTrial',
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    "Pick the tags that match your interests and we'll\nkeep you updated about those events",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: width * 0.039,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'SaansTrial',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.03),

                  // Tag Chips
                  ValueListenableBuilder<List<String>>(
                    valueListenable: selectedTagIds,
                    builder: (context, selected, _) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availableTags.map((tag) {
                          final tagId = tag['_id'] ?? '';
                          return TagChip(
                            tagId: tagId,
                            tagName: tag['title'] ?? 'Unnamed Tag',
                            initiallySelected: selected.contains(tagId),
                            onSelectionChanged: (id, isSelected) {
                              final updated = List<String>.from(selected);
                              if (isSelected) {
                                updated.add(id);
                              } else {
                                updated.remove(id);
                              }
                              selectedTagIds.value = updated;
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),

                  SizedBox(height: height * 0.05),

                  // Continue Button
                  ElevatedButton(
                    onPressed: () async {
                      log("Selected Tags: ${selectedTagIds.value}");
                      await _updateUserTags();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.35,
                        vertical: height * 0.01,
                      ),
                    ),
                    child: Text(
                      "Continue",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SaansTrial',
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.05),
                ],
              ),
            ),
    );
  }

  AppBar _buildAppBar(BuildContext context, double width) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const IntroScreen3()),
          );
        },
        icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          ),
          child: Text(
            "Skip",
            style: TextStyle(
              fontSize: width * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
              fontFamily: 'SaansTrial',
            ),
          ),
        )
      ],
    );
  }
}
