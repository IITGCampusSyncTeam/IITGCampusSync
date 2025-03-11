import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../constants/endpoints.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  String razorpayKey = "";
  String orderId = ""; // Store order ID

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    // Listen for payment events
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    // Fetch Razorpay Key from Backend
    fetchRazorpayKey();
  }

  @override
  void dispose() {
    _razorpay.clear(); // Clean up resources
    super.dispose();
  }

  Future<void> fetchRazorpayKey() async {
    try {
      final response =
          await http.get(Uri.parse("${AuthConfig.serverUrl}/get-razorpay-key"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          razorpayKey = data['key'];
        });
      } else {
        print("Failed to fetch Razorpay Key");
      }
    } catch (e) {
      print("Error fetching Razorpay Key: $e");
    }
  }

  // Function to create an order on the backend
  Future<void> createOrder(String amount) async {
    final response = await http.post(
      Uri.parse(
          '${AuthConfig.serverUrl}/create-order'), // Replace with deployed URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount}),
    );

    final body = jsonDecode(response.body);
    orderId = body['id']; // Save order ID

    // Open Razorpay Checkout
    openCheckout(amount);
  }

  // Function to open Razorpay Checkout
  void openCheckout(String amount) {
    var options = {
      'key': razorpayKey, // Use your Razorpay API key
      'amount': int.parse(amount) * 100, // Convert to paise
      'order_id': orderId, // Attach order ID from backend
      'name': 'campus sync',
      'description': 'Payment for Order',
      'prefill': {
        'contact': '9876543210',
        'email': 'user@example.com',
      },
      'theme': {'color': '#3399cc'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error: $e");
    }
  }

  // Handle Payment Success
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    String paymentId = response.paymentId!;
    String signature = response.signature!;

    print("Order ID: $orderId");
    print("Payment ID: $paymentId");
    print("Signature: $signature");
    print("Payment Success: ${response.paymentId}");

    // Verify payment on the backend
    await verifyPayment(orderId, response.paymentId!, response.signature!);
  }

  // Function to verify payment with the backend
  Future<void> verifyPayment(
      String orderId, String paymentId, String signature) async {
    final response = await http.post(
      Uri.parse('${AuthConfig.serverUrl}/verify-payment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      }),
    );

    if (response.statusCode == 200) {
      print("Payment Verified!");
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Successful!")),
      );
    } else {
      print("Payment Verification Failed!");
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Failed! Please try again.")),
      );
    }
  }

  // Handle Payment Failure
  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment Error: ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  // Handle External Wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet: ${response.walletName}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Razorpay Payment")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => createOrder("1"), // Call createOrder on button press

          child: Text("Pay ₹1"),
        ),
      ),
    );
  }
}
