import 'package:flutter/material.dart';
import 'package:frontend/screens/intro_screens/interest_button.dart';
import 'package:frontend/apis/UserTag/userTag_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InterestPage extends StatefulWidget {
  const InterestPage({super.key});

  @override
  State<InterestPage> createState() => _InterestPageState();
}

class _InterestPageState extends State<InterestPage> {
  List<Map<String, String>> availableTags = [];
  final Set<String> selectedTagIds = {}; // store IDs, not names
  bool isLoading = true;
  String? userEmail; // will be loaded from SharedPreferences

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _loadTags();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('email');
    });
    print("📧 Loaded user email: $userEmail");
  }

  Future<void> _loadTags() async {
    final tags = await UserTagAPI.fetchAvailableTags();
    setState(() {
      availableTags = tags;
      isLoading = false;
    });
  }

  void toggleInterest(String tagId) {
    setState(() {
      if (selectedTagIds.contains(tagId)) {
        selectedTagIds.remove(tagId);
      } else {
        selectedTagIds.add(tagId);
      }
    });
  }

  Future<void> _submitTags() async {
    if (userEmail == null) {
      print("⚠️ No user email found, cannot submit tags.");
      return;
    }

    for (final tagId in selectedTagIds) {
      final success = await UserTagAPI.addTag(userEmail!, tagId);
      if (success) {
        print("✅ Added tag $tagId");
      } else {
        print("❌ Failed to add tag $tagId");
      }
    }

    // Example: Navigate after submission
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Skip",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 40),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "What are your interests?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'SaansTrial',
                        fontSize: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "Choose topics you like. You can update them anytime from your profile.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: availableTags.map((tag) {
                          final tagId = tag["id"] ?? "";
                          final tagName = tag["name"] ?? "Unknown";

                          return InterestButton(
                            labelText: tagName,
                            isSelected: selectedTagIds.contains(tagId),
                            onTouch: () => toggleInterest(tagId),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: selectedTagIds.isEmpty ? null : _submitTags,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          child: const Text("Continue", style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
