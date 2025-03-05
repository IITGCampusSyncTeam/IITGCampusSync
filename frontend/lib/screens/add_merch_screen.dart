import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddMerchScreen extends StatefulWidget {
  final String clubId;

  const AddMerchScreen({Key? key, required this.clubId}) : super(key: key);

  @override
  _AddMerchScreenState createState() => _AddMerchScreenState();
}

class _AddMerchScreenState extends State<AddMerchScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _selectedType = "T-Shirt"; // Default merch type
  List<String> _selectedSizes = [];
  bool _isLoading = false;
  String _errorMessage = '';

  final List<String> merchTypes = ["T-Shirt", "Hoodie", "Cap", "Mug", "Sticker"];
  final List<String> availableSizes = ["S", "M", "L", "XL", "XXL"];

  Future<void> addMerch() async {
    if (!_formKey.currentState!.validate() || _selectedSizes.isEmpty) {
      setState(() {
        _errorMessage = _selectedSizes.isEmpty ? "Please select at least one size!" : '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final Map<String, dynamic> merchData = {
      "name": _nameController.text.trim(),
      "description": _descriptionController.text.trim(),
      "price": double.parse(_priceController.text),
      "type": _selectedType,
      "sizes": _selectedSizes,
    };

    try {
      final response = await http.post(
        Uri.parse("https://iitgcampussync.onrender.com/api/clubs/${widget.clubId}/merch"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(merchData),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context, true); // Go back and refresh merch list
      } else {
        setState(() {
          _errorMessage = 'Failed to add merch. Please try again!';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Merch"), backgroundColor: Colors.blueAccent),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Merch Name", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Enter merch name" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Description", border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: "Price", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return "Enter price";
                  if (double.tryParse(value) == null) return "Enter a valid price";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Merch Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(labelText: "Merch Type", border: OutlineInputBorder()),
                items: merchTypes.map((type) {
                  return DropdownMenuItem<String>(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 12),

              // Multi-select Sizes
              Wrap(
                spacing: 10,
                children: availableSizes.map((size) {
                  bool isSelected = _selectedSizes.contains(size);
                  return FilterChip(
                    label: Text(size),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSizes.add(size);
                        } else {
                          _selectedSizes.remove(size);
                        }
                      });
                    },
                    selectedColor: Colors.blueAccent,
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                ),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: addMerch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text("Add Merch"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
