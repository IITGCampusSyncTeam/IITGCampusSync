import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/event_creation_provider.dart'; // Make sure this path is correct

class Step1Form extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const Step1Form({Key? key, required this.formKey}) : super(key: key);

  @override
  State<Step1Form> createState() => _Step1FormState();
}

class _Step1FormState extends State<Step1Form> {
  // --- HELPER WIDGETS FOR CONSISTENT STYLING ---

  // Helper for Text Fields
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    Widget? suffixIcon,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isOptional: isOptional),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: _inputDecoration(hintText: hintText, suffixIcon: suffixIcon),
        ),
      ],
    );
  }

  // Helper for Dropdown Fields
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String hintText,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          decoration: _inputDecoration(hintText: hintText),
          icon: Icon(Icons.keyboard_arrow_down),
        ),
      ],
    );
  }

  // Helper for Date/Time Picker Fields
  Widget _buildPickerField({
    required String label,
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(text, style: TextStyle(fontSize: 16)),
                Icon(icon, color: Colors.grey.shade700),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Reusable Input Decoration for a consistent look
  InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey.shade200,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      suffixIcon: suffixIcon,
    );
  }

  // Reusable Label widget
  Widget _buildLabel(String label, {bool isOptional = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey.shade800),
        ),
        if (isOptional)
          Text(
            ' (optional)',
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.grey.shade600),
          ),
      ],
    );
  }

  Future<void> _pickImage(EventCreationProvider provider) async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      provider.setBannerImage(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventCreationProvider>(context);

    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TOP BANNER SECTION ---
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: provider.bannerImage != null
                      ? Image.file(provider.bannerImage!, fit: BoxFit.cover)
                      : null,
                ),
                Positioned(
                  top: 100,
                  left: 16,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.calendar_today, color: Colors.white, size: 24),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(provider),
                    icon: Icon(Icons.edit, size: 16),
                    label: Text('Add Banner'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),

            // --- HEADER TEXT ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Your Event',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add the event name, type, audience eligibility, date, time, and venue.',
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 24),

                  // --- EVENT TITLE ---
                  _buildTextField(
                    label: 'Event Title*',
                    controller: provider.eventTitleController,
                    hintText: 'Enter the name of your event',
                  ),
                  SizedBox(height: 24),

                  // --- EXPANDABLE SCHEDULE & VENUE SECTION ---
                  ExpansionTile(
                    title: Text('Schedule and Venue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    initiallyExpanded: true,
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.only(top: 16),
                    children: [
                      // --- EVENT TYPE & NUM OF DAYS ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Event Type*',
                              value: provider.eventType,
                              hintText: 'Select Type',
                              items: ['Workshop', 'Seminar', 'Competition', 'Cultural Night'],
                              onChanged: (val) => provider.toggleState('eventType', val),
                            ),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: _buildTextField(
                              label: 'Num. of Days',
                              controller: provider.numDaysController,
                              hintText: 'e.g., 1',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // --- PART OF A SERIES ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel('Part of a Series?'),
                          Switch(
                            value: provider.isPartOfSeries,
                            onChanged: (val) => provider.toggleState('isPartOfSeries', val),
                            activeColor: Colors.orange,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // --- DATE & TIME PICKER ---
                      Row(
                        children: [
                          Expanded(
                            child: _buildPickerField(
                              label: 'Event Date*',
                              text: provider.eventDate == null ? 'Select Date' : DateFormat.yMMMd().format(provider.eventDate!),
                              icon: Icons.calendar_today,
                              onTap: () async {
                                final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2101));
                                if (date != null) provider.setEventDate(date);
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildPickerField(
                              label: 'Time(approx.)*',
                              text: provider.eventTime == null ? 'Select Time' : provider.eventTime!.format(context),
                              icon: Icons.access_time,
                              onTap: () async {
                                final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                if (time != null) provider.setEventTime(time);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // --- VENUE DROPDOWN & ONLINE/OFFLINE ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Add Expanded widget here
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Venue',
                              value: provider.venue,
                              hintText: 'Select a venue',
                              items: ['New SAC', 'Auditorium', 'Lecture Hall 3', 'Online'],
                              onChanged: (val) => provider.toggleState('venue', val),
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            children: [
                              SizedBox(height: 32),
                              ToggleButtons(
                                children: [Text('Online'), Text('Offline')],
                                isSelected: [provider.venueTypeIndex == 0, provider.venueTypeIndex == 1],
                                onPressed: (index) => provider.toggleState('venueType', index),
                                borderRadius: BorderRadius.circular(8),
                                selectedColor: Colors.white,
                                fillColor: Colors.black87,
                                constraints: BoxConstraints(minHeight: 48, minWidth: 70),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // --- VENUE LINK & INSTRUCTIONS ---
                      _buildTextField(
                        label: 'Venue Link',
                        isOptional: true,
                        controller: provider.venueLinkController,
                        hintText: 'e.g., Google Meet link',
                        suffixIcon: Icon(Icons.link),
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        label: 'Venue Instructions',
                        isOptional: true,
                        controller: provider.venueInstructionsController,
                        hintText: 'e.g., Enter from Gate 2',
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
