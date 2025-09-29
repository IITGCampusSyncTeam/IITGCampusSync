import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_creation_provider.dart';
import 'form_steps/step1_form.dart';
import 'form_steps/step2_form.dart';
import 'form_steps/step3_form.dart';

class EventCreationFormScreen extends StatefulWidget {
  @override
  _EventCreationFormScreenState createState() => _EventCreationFormScreenState();
}

class _EventCreationFormScreenState extends State<EventCreationFormScreen> {
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventCreationProvider(),
      child: Consumer<EventCreationProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                children: [
                  _buildHeader(context, provider.currentPage),
                  Expanded(
                    child: PageView(
                      controller: provider.pageController,
                      physics: NeverScrollableScrollPhysics(), // Disable swiping
                      children: [
                        Step1Form(formKey: _formKeys[0]),
                        Step2Form(formKey: _formKeys[1]),
                        Step3Form(formKey: _formKeys[2]),
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: _buildBottomNavBar(context, provider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int currentPage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Column(
          children: [
            Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: index <= currentPage ? Colors.orange : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 8),
            Text(
              'Step ${currentPage + 1} of 3',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, EventCreationProvider provider) {
    // Style for the top row of buttons ("Save Draft", "Back")
    final secondaryButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.grey.shade200,
      foregroundColor: Colors.black87,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(),
          // Top row for secondary buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () { /* TODO: Save Draft Logic */ },
                  style: secondaryButtonStyle,
                  child: Text('Save Draft'),
                ),
              ),
              // Conditionally show the "Back" button
              if (provider.currentPage > 0) ...[
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => provider.goToPage(provider.currentPage - 1),
                    style: secondaryButtonStyle,
                    child: Text('Back'),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            onPressed: () {
              if (_formKeys[provider.currentPage].currentState!.validate()) {
                if (provider.currentPage < 2) {
                  provider.goToPage(provider.currentPage + 1);
                } else {
                  final allData = provider.toMap();
                  print('Submitting Data: $allData');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Event Published Successfully!')),
                  );
                  Navigator.pop(context);
                }
              }
            },
            child: Text(
              provider.currentPage == 2 ? 'Publish' : 'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
