import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/multi_tag_screen/interest_button.dart';
import 'package:frontend/apis/UserTag/userTag_api.dart';
import 'package:frontend/screens/intro_screens/intro_screen_3.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InterestPage extends StatefulWidget {
  const InterestPage({super.key});

  @override
  State<InterestPage> createState() => _InterestPageState();
}

class _InterestPageState extends State<InterestPage> {
  List<Map<String, String>> availableTags = [];
  final Set<String> selectedTagIds = {};
  bool isLoading = true;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  /// ✅ Combine both user email + tags loading
  Future<void> _initPage() async {
    setState(() => isLoading = true);
    await _loadUserEmail();
    await _loadTags();
    setState(() => isLoading = false);
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('email');
    print("Loaded user email: $userEmail");
  }

  Future<void> _loadTags() async {
    try {
      final tags = await UserTagAPI.fetchAvailableTags();
      availableTags = tags;
    } catch (e) {
      print("Error loading tags: $e");
      availableTags = [];
    }
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
      print("No user email found, cannot submit tags.");
      return;
    }

    print("Submitting tags for user: $userEmail");
    print("Selected tag IDs: $selectedTagIds");

    bool success = await UserTagAPI.updateUserTags(
      userEmail!,
      selectedTagIds.toList(),
    );

    if (success) {
      print("Tags updated successfully!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      print("Failed to update tags.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.black),
              )
            : Column(
                children: [
                  _upperUI(),
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
      bottomNavigationBar: SafeArea(
        child: Container(
          height: height * 0.1,
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: selectedTagIds.isEmpty ? null : _submitTags,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: Text("Continue", style: TextStyle(fontSize: width * 0.05)),
          ),
        ),
      ),
    );
  }

  Widget _upperUI() {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    return Center(
      child: Column(
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
        ],
      ),
    );
  }
}
