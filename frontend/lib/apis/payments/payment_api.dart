import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../constants/endpoints.dart';

class PaymentAPI {
  // Fetch Razorpay Key
  static Future<String?> fetchRazorpayKey() async {
    try {
      final response = await http.get(Uri.parse(payment.getRazorpayKey));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['key']; // Return key
      } else {
        print("Failed to fetch Razorpay Key");
        return null;
      }
    } catch (e) {
      print("Error fetching Razorpay Key: $e");
      return null;
    }
  }

  // Create Order
  static Future<String?> createOrder(String amount) async {
    try {
      final response = await http.post(
        Uri.parse(payment.createOrder),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['id']; // Return order ID
      } else {
        print("Failed to create order");
        return null;
      }
    } catch (e) {
      print("Error creating order: $e");
      return null;
    }
  }

  // Verify Payment
  static Future<bool> verifyPayment(
      String orderId, String paymentId, String signature) async {
    try {
      final response = await http.post(
        Uri.parse(payment.verifyPayment),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          'razorpay_signature': signature,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error verifying payment: $e");
      return false;
    }
  }
}
