import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/merch_model.dart';

/// Displays details of a selected merch item using the full merch data passed.
class MerchDetailScreen extends StatefulWidget {
  final Merch merch;

  const MerchDetailScreen({Key? key, required this.merch}) : super(key: key);

  @override
  _MerchDetailScreenState createState() => _MerchDetailScreenState();
}

class _MerchDetailScreenState extends State<MerchDetailScreen> {
  String? selectedSize;

  /// Adds the merch item to the cart with the selected size.
  Future<void> addToCart() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList('cart') ?? [];
    cart.add('${widget.merch.name} - ${selectedSize ?? "No Size"}');
    await prefs.setStringList('cart', cart);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final merch = widget.merch;
    return Scaffold(
      appBar: AppBar(title: Text(merch.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(merch.description, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Price: ₹${merch.price}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Type: ${merch.type}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Text('Select Size:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Wrap(
              children: merch.sizes.map<Widget>((size) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ChoiceChip(
                    label: Text(size),
                    selected: selectedSize == size,
                    onSelected: (selected) {
                      setState(() {
                        selectedSize = selected ? size : null;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addToCart,
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
