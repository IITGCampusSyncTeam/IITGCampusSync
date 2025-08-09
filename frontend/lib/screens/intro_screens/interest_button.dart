import 'package:flutter/material.dart';

class InterestButton extends StatefulWidget {
  final String labelText;
  final VoidCallback? onTouch;

  const InterestButton({
    super.key,
    required this.labelText,
    this.onTouch,
  });

  @override
  State<InterestButton> createState() => _InterestButtonState();
}

class _InterestButtonState extends State<InterestButton> {
  bool isSelected = false;

  void handleTap() {
    setState(() {
      isSelected = !isSelected;
    });

    if (widget.onTouch != null) {
      widget.onTouch!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: handleTap,
      child: Chip(
        label: Text(widget.labelText),
        backgroundColor: isSelected ? Colors.black : Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade800,
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(40)),
        side: BorderSide(
          color: isSelected ? Colors.black : Colors.grey,
        ),
      ),
    );
  }
}
