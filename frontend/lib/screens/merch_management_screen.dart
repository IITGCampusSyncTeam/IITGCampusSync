import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/club_model.dart';
import '../models/merch_model.dart';
import 'add_merch_screen.dart';
import 'package:frontend/apis/protected.dart'; // Import getAccessToken()

class MerchManagementScreen extends StatefulWidget {
  final String clubId;

  const MerchManagementScreen({Key? key, required this.clubId}) : super(key: key);

  @override
  _MerchManagementScreenState createState() => _MerchManagementScreenState();
}

class _MerchManagementScreenState extends State<MerchManagementScreen> {
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
      String token = await getAccessToken();
      print("DEBUG: Access Token -> $token"); // ✅ Debugging log

      if (token == 'error') {
        setState(() {
          errorMessage = 'Authentication error: No token found';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://iitgcampussync.onrender.com/api/clubs/${widget.clubId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("DEBUG: Backend Response -> ${response.body}"); // ✅ Print full backend response

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


  Future<void> deleteMerch(String merchId) async {
    try {
      String token = await getAccessToken();
      print("DEBUG: Access Token -> $token"); // ✅ Debugging log
      if (token == 'error') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication error: No token found')),
        );
        return;
      }
      print("DEBUG: Attempting to delete merch -> ID: ${merchId}");

      final response = await http.delete(
        Uri.parse('https://iitgcampussync.onrender.com/api/clubs/${widget.clubId}/merch/$merchId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("DEBUG: Delete Response -> ${response.statusCode} ${response.body}"); // ✅ Debugging log

      if (response.statusCode == 200) {
        setState(() {
          club!.merch.removeWhere((item) => item.id == merchId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete merch: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Merch"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
          : Column(
        children: [
          Expanded(
            child: club!.merch.isEmpty
                ? const Center(child: Text("No merch available"))
                : ListView.builder(
              itemCount: club!.merch.length,
              itemBuilder: (context, index) {
                final merch = club!.merch[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Text("Img", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    title: Text(merch.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    subtitle: Text("₹${merch.price}", style: const TextStyle(fontSize: 14)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteMerch(merch.id),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Add New Merch"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMerchScreen(clubId: widget.clubId)),
                ).then((_) => fetchClubDetails()); // Refresh list after adding merch
              },
            ),
          ),
        ],
      ),
    );
  }
}
