import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/event_creation_provider.dart';
import 'package:file_picker/file_picker.dart';

class Step2Form extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const Step2Form({Key? key, required this.formKey}) : super(key: key);

  @override
  _Step2FormState createState() => _Step2FormState();
}

class _Step2FormState extends State<Step2Form> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventCreationProvider>(context);

    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                  child: Icon(Icons.list_alt_rounded, color: Colors.white, size: 24),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Event Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Add agenda, resources, and POCs.', style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),

            // --- DETAILS SECTION ---
            ExpansionTile(
              title: Text('Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              initiallyExpanded: true,
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.only(top: 16),
              children: [
                _buildTextField(label: 'Event Agenda', controller: provider.agendaController, hintText: 'Tell people a little more about your event.', maxLines: 4, maxLength: 800),
                SizedBox(height: 16),
                _buildDynamicList(label: 'Speakers List', list: provider.speakers, hint1: 'Add Name and Details', onAdd: () => provider.addItem(provider.speakers), onRemove: (index) => provider.removeItem(provider.speakers, index), singleField: true),
                SizedBox(height: 16),
                
                // --- ITINERARY / SCHEDULE ---
                _buildItineraryList(provider),
                SizedBox(height: 16),

                // --- PART OF A SERIES ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Part of a Series?'),
                    Switch(value: provider.isPartOfSeries, onChanged: (val) => provider.toggleState('isPartOfSeries', val), activeColor: Colors.orange),
                  ],
                ),
                SizedBox(height: 16),

                // --- RESOURCES / MATERIAL ---
                _buildLabel('Resources / Material'),
                SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        await FilePicker.platform.pickFiles();
                      },
                      child: Text('Choose Files'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(decoration: _inputDecoration(hintText: 'Add file links', suffixIcon: IconButton(icon: Icon(Icons.add), onPressed: () {/* TODO: Add link to a list */}))),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                _buildTextField(label: 'Guidelines / Rules', controller: provider.guidelinesController, hintText: 'Add additional guidelines/rules', isOptional: true),
                SizedBox(height: 16),

                // --- COMMUNITY LINKS ---
                _buildDynamicList(
                  label: 'Community Links',
                  list: provider.communityLinks,
                  hint1: 'Add Discord / WhatsApp community etc.',
                  onAdd: () => provider.addItem(provider.communityLinks),
                  onRemove: (index) => provider.removeItem(provider.communityLinks, index),
                  singleField: true,
                  suffixIcon: Icon(Icons.link),
                ),
                SizedBox(height: 16),

                // --- PAID REGISTRATION ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Paid Registration?'),
                    Switch(value: provider.isPaidRegistration, onChanged: (val) => provider.toggleState('isPaidRegistration', val), activeColor: Colors.orange),
                  ],
                ),
                if (provider.isPaidRegistration) ...[
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(label: 'Registration Fee', controller: provider.registrationFeeController, hintText: 'e.g., 100')),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildPickerField(
                          label: 'Last Date',
                          text: provider.registrationLastDate == null ? 'Select Date' : DateFormat.yMMMd().format(provider.registrationLastDate!),
                          icon: Icons.calendar_today,
                          onTap: () async {
                             final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2101));
                             if (date != null) provider.setRegistrationLastDate(date);
                          },
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildTextField(label: 'Registration Link', controller: provider.registrationLinkController, hintText: 'Enter registration link', suffixIcon: Icon(Icons.link)),
                ],
              ],
            ),
             // --- POCs SECTION ---
            ExpansionTile(
              title: Text('POCs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              initiallyExpanded: true,
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.only(top: 16),
              children: [
                _buildDynamicList(label: 'POC Names', list: provider.pocs, hint1: 'Name', hint2: 'Contact (Optional)', onAdd: () => provider.addItem(provider.pocs), onRemove: (index) => provider.removeItem(provider.pocs, index)),
              ],
            ),
            _buildDynamicList(label: 'Add Co-Host (Club/Board)', list: provider.coHosts, hint1: 'Add', onAdd: () => provider.addItem(provider.coHosts), onRemove: (index) => provider.removeItem(provider.coHosts, index), singleField: true),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildItineraryList(EventCreationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Itinerary / Schedule'),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: provider.itinerary.length,
          itemBuilder: (context, index) {
            final item = provider.itinerary[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: item.time ?? TimeOfDay.now());
                      if (time != null) {
                        setState(() {
                          item.time = time;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Text(item.time?.format(context) ?? 'Time', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 4),
                          Icon(Icons.access_time, size: 20),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(controller: item.textController, decoration: _inputDecoration(hintText: 'Text')),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade400),
                    onPressed: () => provider.removeItineraryItem(index),
                  ),
                ],
              ),
            );
          },
        ),
        _buildAddMoreButton(onPressed: () => provider.addItineraryItem()),
      ],
    );
  }

  Widget _buildDynamicList({
    required String label,
    required List<DynamicListItem> list,
    required String hint1,
    String? hint2,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    bool singleField = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: TextFormField(controller: list[index].controller1, decoration: _inputDecoration(hintText: hint1, suffixIcon: suffixIcon))),
                  if (!singleField) ...[
                    SizedBox(width: 8),
                    Expanded(child: TextFormField(controller: list[index].controller2, decoration: _inputDecoration(hintText: hint2))),
                  ],
                  IconButton(icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade400), onPressed: () => onRemove(index)),
                ],
              ),
            );
          },
        ),
        _buildAddMoreButton(onPressed: onAdd),
      ],
    );
  }
  
  Widget _buildTextField({ required String label, required TextEditingController controller, String? hintText, int? maxLines = 1, int? maxLength, bool isOptional = false, Widget? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isOptional: isOptional),
        SizedBox(height: 8),
        TextFormField(controller: controller, maxLines: maxLines, maxLength: maxLength, decoration: _inputDecoration(hintText: hintText, suffixIcon: suffixIcon)),
      ],
    );
  }

  Widget _buildPickerField({ required String label, required String text, required IconData icon, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text(text, style: TextStyle(fontSize: 16)), Icon(icon, color: Colors.grey.shade700)]),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey.shade200,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2)),
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildLabel(String label, {bool isOptional = false}) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey.shade800)),
        if (isOptional)
          Text(' (optional)', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.grey.shade600)),
      ],
    );
  }
  
  Widget _buildAddMoreButton({required VoidCallback onPressed}) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.add, size: 20),
      label: Text('Add More'),
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
    );
  }
}
