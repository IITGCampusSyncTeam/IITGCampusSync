import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/endpoints.dart';
import '../models/club_model.dart';
import '../apis/Club/ClubTag_api.dart';
import '../apis/Club/ClubMem_api.dart';
import 'merch_detail_screen.dart';
import 'merch_management_screen.dart';

class ClubProfileScreen extends StatefulWidget {
  const ClubProfileScreen({super.key});

  @override
  State<ClubProfileScreen> createState() => _ClubProfileScreenState();
}

class _ClubProfileScreenState extends State<ClubProfileScreen> {
  final String clubId = '67c9db2747ced698cff3c726'; // Hardcoded for now
  Club? club;
  bool isLoading = true;
  String errorMessage = '';
  List<String> tags = [];
  List<Map<String, String>> availableTags = [];

  final TextEditingController emailController = TextEditingController();
  String selectedRole = 'core';
  final List<String> roles = ['secy', 'head', 'core'];

  @override
  void initState() {
    super.initState();
    fetchClubDetails();
    fetchAvailableTags();
  }

  Future<void> fetchClubDetails() async {
    try {
      final response = await http.get(
        Uri.parse('${backend.uri}/api/clubs/$clubId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          club = Club.fromJson(data);
          print(data);
          tags = (data['tag'] as List<dynamic>)
              .map((tag) => tag['id'].toString())
              .toList();
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

  Future<void> fetchAvailableTags() async {
    List<Map<String, String>>? fetchedTags = await ClubTagAPI.fetchAvailableTags();
    if (fetchedTags != null) {
      setState(() {
        availableTags = fetchedTags;
      });
    } else {
      showSnackbar("Failed to fetch tags");
    }
  }

  Future<void> addTag(String tagId) async {
    bool success = await ClubTagAPI.addTag(clubId, tagId);
    if (success) {
      setState(() {
        tags.add(tagId);
      });
      showSnackbar("Tag added successfully!");
    } else {
      showSnackbar("Failed to add tag");
    }
  }

  Future<void> removeTag(String tagId) async {
    bool success = await ClubTagAPI.removeTag(clubId, tagId);
    if (success) {
      setState(() {
        tags.remove(tagId);
      });
      showSnackbar("Tag removed successfully!");
    } else {
      showSnackbar("Failed to remove tag");
    }
  }

  Future<void> handleAddOrEditMember() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      showSnackbar("Email cannot be empty.");
      return;
    }

    bool success = await ClubMemberAPI.addOrEditMember(clubId, email, selectedRole);
    if (success) {
      showSnackbar("Member added/updated successfully.");
    } else {
      showSnackbar("Failed to add/update member.");
    }
  }

  Future<void> handleRemoveMember() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      showSnackbar("Email cannot be empty.");
      return;
    }

    bool success = await ClubMemberAPI.removeMember(clubId, email);
    if (success) {
      showSnackbar("Member removed successfully.");
    } else {
      showSnackbar("Failed to remove member.");
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(club?.name ?? 'Club Details',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red, width: 1),
          ),
          child: Text(
            errorMessage,
            style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(club!.description,
                  style:
                  const TextStyle(fontSize: 18, height: 1.5)),
              const SizedBox(height: 20),
              const Text("Club Interests:",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (tags.isEmpty)
                const Text("No tags selected",
                    style: TextStyle(color: Colors.red)),
              Wrap(
                spacing: 8.0,
                children: tags.map((tagId) {
                  String tagName = availableTags.firstWhere(
                        (tag) => tag["id"] == tagId,
                    orElse: () => {"name": "Unknown"},
                  )["name"]!;
                  return Chip(
                    label: Text(tagName,
                        style:
                        const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.blueAccent,
                    deleteIconColor: Colors.white,
                    onDeleted: () => removeTag(tagId),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text("Add Tags to Your Club:",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              availableTags.isEmpty
                  ? const Center(child: Text("No tags available"))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: availableTags.length,
                itemBuilder: (context, index) {
                  final tag = availableTags[index];
                  final bool isSelected =
                  tags.contains(tag["id"]);
                  return Card(
                    margin:
                    const EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10)),
                    elevation: 3,
                    child: ListTile(
                      title: Text(tag["name"]!,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                          color: Colors.green)
                          : ElevatedButton(
                        onPressed: () =>
                            addTag(tag["id"]!),
                        child: const Text("Add"),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              if (club!.merch.isNotEmpty) ...[
                const Text('Merch',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: club!.merch.length,
                    itemBuilder: (context, index) {
                      final merchItem = club!.merch[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MerchDetailScreen(
                                      merch: merchItem),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12)),
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8),
                          child: Container(
                            width: 140,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 80,
                                  width: 80,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                    Colors.blueAccent.shade100,
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  child: const Text("Image",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                          FontWeight.bold)),
                                ),
                                const SizedBox(height: 8),
                                Text(merchItem.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                Text("₹${merchItem.price}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors
                                            .blueGrey.shade700)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MerchManagementScreen(clubId: clubId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text("Modify Merch",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(thickness: 1),
              const Text("Club Member Management",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Enter Member Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: "Select Responsibility",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: roles
                    .map((role) => DropdownMenuItem<String>(
                  value: role,
                  child: Text(role.toUpperCase()),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedRole = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: handleAddOrEditMember,
                      icon: const Icon(Icons.person_add),
                      label: const Text("Add / Edit Member"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding:
                        const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: handleRemoveMember,
                      icon: const Icon(Icons.delete),
                      label: const Text("Remove Member"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding:
                        const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}