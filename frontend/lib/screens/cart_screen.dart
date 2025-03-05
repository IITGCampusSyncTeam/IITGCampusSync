import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, int> cartItems = {};

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  /// Loads cart items and their quantities from SharedPreferences.
  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartList = prefs.getStringList('cart') ?? [];

    Map<String, int> cartMap = {};
    for (var item in cartList) {
      List<String> parts = item.split(' - ');
      if (parts.length == 3) {
        String itemName = '${parts[0]} - ${parts[1]}';
        int quantity = int.tryParse(parts[2]) ?? 1;
        cartMap[itemName] = quantity;
      }
    }

    setState(() {
      cartItems = cartMap;
    });
  }

  /// Updates the cart and saves to SharedPreferences.
  Future<void> updateCart() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartList = cartItems.entries
        .where((entry) => entry.value > 0)
        .map((entry) => '${entry.key} - ${entry.value}')
        .toList();
    await prefs.setStringList('cart', cartList);
  }

  /// Increases quantity of an item.
  void increaseQuantity(String item) {
    setState(() {
      cartItems[item] = (cartItems[item] ?? 1) + 1;
    });
    updateCart();
  }

  /// Decreases quantity of an item or removes it if it reaches 0.
  void decreaseQuantity(String item) {
    setState(() {
      if (cartItems.containsKey(item)) {
        if (cartItems[item]! > 1) {
          cartItems[item] = cartItems[item]! - 1;
        } else {
          cartItems.remove(item);
        }
      }
    });
    updateCart();
  }

  /// Clears the entire cart.
  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cartItems.clear();
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
                String itemName = cartItems.keys.elementAt(index);
                int quantity = cartItems[itemName]!;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(itemName, style: const TextStyle(fontSize: 16)),
                    subtitle: Text("Quantity: $quantity"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.red),
                          onPressed: () => decreaseQuantity(itemName),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () => increaseQuantity(itemName),
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
            child: SizedBox(
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
          ),
        ],
      ),
    );
  }
}
