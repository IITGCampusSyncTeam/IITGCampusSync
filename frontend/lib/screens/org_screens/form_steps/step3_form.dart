import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../providers/event_creation_provider.dart';

class Step3Form extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const Step3Form({Key? key, required this.formKey}) : super(key: key);

  @override
  _Step3FormState createState() => _Step3FormState();
}

class _Step3FormState extends State<Step3Form> {

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
                  child: Icon(Icons.description_outlined, color: Colors.white, size: 24),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Additional Data', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Optional details for internal planning.', style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),

            // --- INTERNAL BODY DATA SECTION ---
            ExpansionTile(  
              title: Text('Internal Body Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              initiallyExpanded: true,
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.only(top: 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [ 
                _buildDynamicList(label: 'Event Team Details', list: provider.eventTeam, hint1: 'Name', hint2: 'Contact (Optional)', onAdd: () => provider.addItem(provider.eventTeam), onRemove: (index) => provider.removeItem(provider.eventTeam, index)),
                SizedBox(height: 16),
                _buildLabel('Internal Material'),
                SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton(onPressed: () async => await FilePicker.platform.pickFiles(), child: Text('Choose Files')),
                    SizedBox(width: 16),
                    Expanded(child: TextFormField(decoration: _inputDecoration(hintText: 'Add file links', suffixIcon: IconButton(icon: Icon(Icons.add), onPressed: () {})))),
                  ],
                ),
                SizedBox(height: 4),
                Text('Max file size: 20MB', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
            SizedBox(height: 16),

            // --- INFRA AND OTHER REQUIREMENTS ---
            Text('Infra and Other Requirements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async => await FilePicker.platform.pickFiles(),
              child: Text('Choose Files'),
            ),
            SizedBox(height: 4),
            Text('Max file size: 20MB', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            SizedBox(height: 16),
            _buildTextField(label: '', controller: provider.otherRequirementsController, hintText: 'Other Instructions'),
            SizedBox(height: 16),

            // --- SPONSOR LIST SECTION ---
            _buildSponsorInput(context, provider),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Helper for the unique sponsor input style
  Widget _buildSponsorInput(BuildContext context, EventCreationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Sponsors'),
        SizedBox(height: 8),
        // Display added sponsors as deletable chips
        if (provider.sponsors.isNotEmpty)
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: provider.sponsors.map((sponsor) => Chip(
              label: Text(sponsor),
              onDeleted: () => provider.removeSponsor(sponsor),
              deleteIconColor: Colors.red.shade400,
            )).toList(),
          ),
        SizedBox(height: 8),
        // The input field to add new sponsors
        TextFormField(
          controller: provider.sponsorInputController,
          decoration: _inputDecoration(
            hintText: 'Add',
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: () => provider.addSponsor(),
            ),
          ),
          onFieldSubmitted: (_) => provider.addSponsor(), // Allows adding with 'enter' key
        ),
      ],
    );
  }

  // --- HELPER WIDGETS ---
  
  Widget _buildDynamicList({ required String label, required List<DynamicListItem> list, required String hint1, String? hint2, required VoidCallback onAdd, required Function(int) onRemove, bool singleField = false }) {
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
                  Expanded(child: TextFormField(controller: list[index].controller1, decoration: _inputDecoration(hintText: hint1))),
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

  Widget _buildTextField({required String label, required TextEditingController controller, String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[ _buildLabel(label), SizedBox(height: 8) ],
        TextFormField(controller: controller, decoration: _inputDecoration(hintText: hintText)),
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

  Widget _buildLabel(String label) => Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey.shade800));
  
  Widget _buildAddMoreButton({required VoidCallback onPressed}) => TextButton.icon(onPressed: onPressed, icon: Icon(Icons.add, size: 20), label: Text('Add More'), style: TextButton.styleFrom(padding: EdgeInsets.zero));
}
