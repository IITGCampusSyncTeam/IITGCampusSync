import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class UpiPaymentScreen extends StatelessWidget {
  final String clubName = "Bhanwari Devi";
  final String upiId = "7878682166@ybl"; // Club's UPI ID
  final double amount = 1;
  final String serverUrl = "http://10.150.47.95:3000"; // Your backend URL

  final uuid = Uuid(); // Initialize the UUID generator

  // Function to generate unique transaction ID
  String generateTransactionId() {
    return uuid.v4(); // Generate a unique UUID
  }

  Future<void> openGooglePay(BuildContext context) async {
    // Generate unique tid and tr
    String tid = generateTransactionId();
    String tr = generateTransactionId();

    // Construct UPI URL with the unique IDs
    String url =
        "upi://pay?pa=$upiId&pn=${Uri.encodeComponent(clubName)}&am=$amount&cu=INR&tid=$tid&tr=$tr&tn=Test%20Transaction";

    try {
      Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        // Send transaction initiation to backend
        await sendTransactionToBackend(tid, tr, "PENDING");

        // Open Google Pay (or default UPI app)
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Wait for user to return after payment
        await Future.delayed(Duration(seconds: 5));

        // Verify transaction status
        await verifyPayment(context, tid);
      } else {
        throw Exception("Google Pay is not installed or the URL is incorrect.");
      }
    } catch (e) {
      print("Error launching Google Pay: $e");
    }
  }

  // Send transaction details to backend
  Future<void> sendTransactionToBackend(
      String tid, String tr, String status) async {
    final response = await http.post(
      Uri.parse("${serverUrl}/api/transactions"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "tid": tid,
        "tr": tr,
        "upiId": upiId,
        "amount": amount,
        "status": status
      }),
    );
    if (response.statusCode == 200) {
      print("Transaction initiated on backend.");
    } else {
      print("Failed to send transaction to backend.");
    }
  }

  // Verify Payment Status via Backend
  Future<void> verifyPayment(BuildContext context, String tid) async {
    final response = await http.get(
      Uri.parse("${serverUrl}/api/transactions/verify?tid=$tid"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["status"] == "SUCCESS") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment Successful!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment Failed!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("UPI Payment")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => openGooglePay(context),
          child: Text("Pay ₹$amount via Google Pay"),
        ),
      ),
    );
  }
}
