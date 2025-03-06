import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderSummaryScreen extends StatefulWidget {
  final String name;
  final String contact;
  final String hostel;
  final String room;

  OrderSummaryScreen({
    required this.name,
    required this.contact,
    required this.hostel,
    required this.room,
  });

  @override
  _OrderSummaryScreenState createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  Map<String, Map<String, dynamic>> cartItems = {};
  bool isLoading = true;
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartList = prefs.getStringList('cart') ?? [];

    Map<String, Map<String, dynamic>> cartMap = {};
    double newTotalPrice = 0.0;

    for (var item in cartList) {
      List<String> parts = item.split(' - ');
      if (parts.length == 5) {
        String merchId = parts[0]; // Extract merchId
        String itemName = parts[1];
        String size = parts[2];
        int quantity = int.tryParse(parts[3]) ?? 1;
        double price = double.tryParse(parts[4]) ?? 0.0;

        // Use "$itemName - $size" as the key to ensure all items show up
        String key = "$itemName - $size";

        if (cartMap.containsKey(key)) {
          cartMap[key]!["quantity"] += quantity;  // Merge same items
          cartMap[key]!["total"] += quantity * price;
        } else {
          cartMap[key] = {
            "name": itemName,
            "size": size,
            "quantity": quantity,
            "price": price,
            "total": quantity * price,
            "merchId": merchId,
          };
        }
        newTotalPrice += (quantity * price);
      }
    }

    setState(() {
      cartItems = cartMap;
      totalPrice = newTotalPrice;
      isLoading = false;
    });
  }

  Future<void> placeOrder() async {
    final prefs = await SharedPreferences.getInstance();

    // Fetch userId
    final String? userDataString = prefs.getString('user_data');
    if (userDataString == null || userDataString.isEmpty) {
      print("User data not found in SharedPreferences.");
      return;
    }

    final dynamic decodedUser = jsonDecode(userDataString);
    String? userId;
    if (decodedUser is Map<String, dynamic> && decodedUser.containsKey('_id')) {
      userId = decodedUser['_id'];
      print("User ID: $userId");
    } else {
      print("User data structure is invalid.");
      return;
    }

    // Group items with the same merchId and size
    Map<String, Map<String, dynamic>> groupedItems = {};

    for (var entry in cartItems.entries) {
      String merchId = entry.value["merchId"];
      String size = entry.value["size"];
      String key = "$merchId-$size"; // Unique key for merging same merch & size

      if (groupedItems.containsKey(key)) {
        // If already exists, sum up the quantity and price
        groupedItems[key]!["quantity"] += entry.value["quantity"];
        groupedItems[key]!["price"] += entry.value["price"] * entry.value["quantity"];
      } else {
        // Otherwise, create a new entry
        groupedItems[key] = {
          "merchId": merchId,
          "size": size,
          "quantity": entry.value["quantity"],
          "price": entry.value["price"] * entry.value["quantity"], // Total price for this item
        };
      }
    }

    // Convert map to list for API request
    List<Map<String, dynamic>> orderItems = groupedItems.values.toList();

    // Calculate total price based on grouped items
    double totalPrice = orderItems.fold(0, (sum, item) => sum + item["price"]);

    final orderData = {
      "user": userId,  // Use the fetched userId
      "name": widget.name,
      "contact": widget.contact,
      "hostel": widget.hostel,
      "roomNum": widget.room,
      "items": orderItems,
      "totalPrice": totalPrice
    };

    final response = await http.post(
      Uri.parse("https://iitgcampussync.onrender.com/api/orders/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(orderData),
    );
    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
    if (response.statusCode == 201) {
      await prefs.remove('cart');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Order Placed", style: TextStyle(color: Colors.green)),
          content: Text("Your order has been placed successfully! 🎉\nTotal Price: ₹$totalPrice"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, "/ordersPage");
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error", style: TextStyle(color: Colors.red)),
          content: Text("Failed to place order. Please try again."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order Summary")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.green.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("User Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("📌 ${widget.name}\n📞 ${widget.contact}\n🏠 ${widget.hostel}\n🚪 ${widget.room}",
                      style: TextStyle(fontSize: 16)),
                  Divider(),
                  Text("Your Cart", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...cartItems.entries.map((entry) {
                    final details = entry.value;
                    return ListTile(
                      title: Text(details["name"], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      subtitle: Text("Size: ${details['size']} • ₹${details['price']} × ${details['quantity']}"),
                      trailing: Text("₹${details['total']}", style: TextStyle(fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                  Divider(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text("Total: ₹$totalPrice",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: cartItems.isNotEmpty ? placeOrder : null,
                      child: Text("Place Order"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
