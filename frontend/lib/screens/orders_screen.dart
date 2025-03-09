import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../constants/endpoints.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      // 🔹 Retrieve user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? userDataString = prefs.getString('user_data');

      if (userDataString == null || userDataString.isEmpty) {
        print("User data not found in SharedPreferences.");
        setState(() => isLoading = false);
        return;
      }

      final dynamic decodedUser = jsonDecode(userDataString);
      String? userId;
      if (decodedUser is Map<String, dynamic> && decodedUser.containsKey('_id')) {
        userId = decodedUser['_id'];
        print("User ID: $userId");
      } else {
        print("User data structure is invalid.");
        setState(() => isLoading = false);
        return;
      }

      // Fetch orders from API
      final response = await http.get(
        Uri.parse('${backend.uri}/api/orders/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          orders = json.decode(response.body)['orders'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Orders')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? Center(child: Text('No orders found'))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final merch = order['merchDetails'] ?? {};

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "IMAGE",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              title: Text(merch['name'] ?? 'Unknown Item'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Size: ${order['size']}"),
                  Text("Quantity: ${order['quantity']}"),
                  Text("Total Price: ₹${order['totalPrice']}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
