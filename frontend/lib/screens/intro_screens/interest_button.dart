import 'package:flutter/material.dart';

class InterestButton extends StatelessWidget {
  final String labelText;
  final VoidCallback? onTouch;
  final bool isSelected;

  const InterestButton({
    super.key,
    required this.labelText,
    this.onTouch,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTouch,
      child: Chip(
        label: Text(labelText),
        backgroundColor: isSelected ? Colors.black : Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade800,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        side: BorderSide(
          color: isSelected ? Colors.black : Colors.grey,
        ),
      ),
    );
  }
}
