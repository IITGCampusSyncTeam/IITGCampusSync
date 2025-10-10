import 'package:flutter/material.dart';

class TagChip extends StatefulWidget {
  final String tagId;
  final String tagName;
  final bool initiallySelected;
  final Function(String tagId, bool isSelected) onSelectionChanged;

  const TagChip({
    super.key,
    required this.tagId,
    required this.tagName,
    this.initiallySelected = false,
    required this.onSelectionChanged,
  });

  @override
  State<TagChip> createState() => _TagChipState();
}

class _TagChipState extends State<TagChip> {
  late bool isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = widget.initiallySelected;
  }

  void toggleSelection() {
    setState(() {
      isSelected = !isSelected;
    });
    widget.onSelectionChanged(widget.tagId, isSelected);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleSelection,
      child: Chip(
        label: Text(
          widget.tagName,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isSelected ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        side: BorderSide(
          color: isSelected ? Colors.black : Colors.grey,
          width: 1.2,
        ),
        elevation: 0,
      ),
    );
  }
}
