import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/merch_model.dart';

class MerchDetailScreen extends StatefulWidget {
  final Merch merch;

  const MerchDetailScreen({Key? key, required this.merch}) : super(key: key);

  @override
  _MerchDetailScreenState createState() => _MerchDetailScreenState();
}

class _MerchDetailScreenState extends State<MerchDetailScreen> {
  String? selectedSize;

  @override
  void initState() {
    super.initState();
    selectedSize = widget.merch.sizes.isNotEmpty ? widget.merch.sizes[0] : null;
  }

  /// Checks if the item with the same size is already in the cart
  Future<bool> isItemAlreadyInCart() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList('cart') ?? [];

    String newItem = '${widget.merch.name} - ${selectedSize ?? "No Size"}';
    return cart.any((item) => item.startsWith(newItem));
  }

  /// Adds the merch item to the cart if not already present.
  Future<void> addToCart() async {
    if (selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a size before adding to cart!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    if (await isItemAlreadyInCart()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item is already in the cart!'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    List<String> cart = prefs.getStringList('cart') ?? [];
    cart.add('${widget.merch.name} - ${selectedSize ?? "No Size"} - 1');
    await prefs.setStringList('cart', cart);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to cart!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final merch = widget.merch;
    return Scaffold(
      appBar: AppBar(
        title: Text(merch.name),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      merch.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Placeholder for Image
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black26),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Image",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    merch.description,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price: ₹${merch.price}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      Text(
                        'Type: ${merch.type}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Size:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    children: merch.sizes.map<Widget>((size) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        child: ChoiceChip(
                          label: Text(size),
                          selected: selectedSize == size,
                          selectedColor: Colors.blueAccent,
                          backgroundColor: Colors.grey[300],
                          labelStyle: TextStyle(
                            color: selectedSize == size ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              selectedSize = selected ? size : null;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: addToCart,
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        elevation: 5,
                      ),
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
