import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'checkout_screen.dart'; // Import the checkout screen

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, Map<String, dynamic>> cartItems = {}; // Stores item details
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
    double total = 0.0;

    for (var item in cartList) {
      List<String> parts = item.split(' - ');
      if (parts.length == 5) {
        String merchId = parts[0]; // Used internally, but not shown
        String itemName = parts[1];
        String size = parts[2];
        int quantity = int.tryParse(parts[3]) ?? 1;
        double price = double.tryParse(parts[4]) ?? 0.0;

        String key = "$itemName - $size"; // User-friendly key (without merch ID)

        if (cartMap.containsKey(key)) {
          cartMap[key]!["quantity"] += quantity;
        } else {
          cartMap[key] = {
            "quantity": quantity,
            "price": price,
            "merchId": merchId // Store for correct retrieval but hide from UI
          };
        }
        total += price * quantity;
      }
    }

    setState(() {
      cartItems = cartMap;
      totalPrice = total;
    });
  }

  Future<void> updateCart() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartList = cartItems.entries.map((entry) {
      String key = entry.key;
      List<String> keyParts = key.split(' - ');
      String itemName = keyParts[0];
      String size = keyParts[1];
      String merchId = entry.value["merchId"];

      return '$merchId - $itemName - $size - ${entry.value["quantity"]} - ${entry.value["price"]}';
    }).toList();

    await prefs.setStringList('cart', cartList);
  }

  void increaseQuantity(String item) {
    setState(() {
      cartItems[item]!["quantity"] += 1;
      totalPrice += cartItems[item]!["price"];
    });
    updateCart();
  }

  void decreaseQuantity(String item) {
    setState(() {
      if (cartItems[item]!["quantity"] > 1) {
        cartItems[item]!["quantity"] -= 1;
        totalPrice -= cartItems[item]!["price"];
      } else {
        totalPrice -= cartItems[item]!["price"];
        cartItems.remove(item);
      }
    });
    updateCart();
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cartItems.clear();
      totalPrice = 0.0;
    });
    await prefs.remove('cart');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
        backgroundColor: Colors.blueAccent,
      ),
      body: cartItems.isEmpty
          ? const Center(
        child: Text(
          "Your cart is empty!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                String itemKey = cartItems.keys.elementAt(index);
                int quantity = cartItems[itemKey]!["quantity"];
                double price = cartItems[itemKey]!["price"];
                double itemTotal = quantity * price;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(itemKey, style: const TextStyle(fontSize: 16)), // Only shows item name and size
                    subtitle: Text("₹${price.toStringAsFixed(2)} x $quantity = ₹${itemTotal.toStringAsFixed(2)}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.red),
                          onPressed: () => decreaseQuantity(itemKey),
                        ),
                        Text(
                          '$quantity',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () => increaseQuantity(itemKey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Total Price: ₹${totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: clearCart,
                    icon: const Icon(Icons.delete),
                    label: const Text("Clear Cart"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CheckoutScreen()),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: const Text("Checkout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
