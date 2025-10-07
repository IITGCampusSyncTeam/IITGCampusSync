import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/models/interests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({Key? key}) : super(key: key);

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  final Set<String> _selectedInterests = {};

  void _toggleInterest(String name) {
    setState(() {
      if (_selectedInterests.contains(name)) {
        _selectedInterests.remove(name);
      } else {
        _selectedInterests.add(name);
      }
    });
  }

  // void _continue() {
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => const HomeScreen()),
  //   );
  // }

  void _continue() async {
    final uid = FirebaseAuth.instance.currentUser?.uid; // assuming login done
    if (uid == null) return;

    // Save the selected tags for this club
    await FirebaseFirestore.instance.collection('clubs').doc(uid).set({
      'interests': _selectedInterests.toList(),
    }, SetOptions(merge: true));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _continue,
            child: const Text(
              "Skip",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset('assets/icons/appicon.png'),
            const SizedBox(height: 20),
            const Text(
              "Tell us about your club",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1C1C1C),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Select the tags that best represent your club’s activities and interests.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Scrollable Interests
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: sampleInterests.map((interest) {
                    final isSelected = _selectedInterests.contains(interest.name);
                    return ChoiceChip(
                      showCheckmark: false,
                      label: Text(
                        interest.name,
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.white : Color(0xFF2E2E2E),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Color(0xFF2E2E2E),
                      backgroundColor: Colors.grey.shade200,
                      onSelected: (_) => _toggleInterest(interest.name),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SafeArea(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  // onPressed: _continue,
                  onPressed: _selectedInterests.isNotEmpty ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF252525),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
