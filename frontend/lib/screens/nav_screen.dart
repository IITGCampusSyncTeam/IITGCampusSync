import 'package:flutter/material.dart';
// Import your screen files here
import 'package:frontend/screens/explore_screen.dart';
import 'package:frontend/screens/calendar_screen.dart';
import 'package:frontend/screens/my_events_screen.dart';
import 'package:frontend/screens/user_profile_screen.dart';
import 'package:provider/provider.dart'; // ✅ ADD THIS
import '../providers/eventProvider.dart';



class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({Key? key}) : super(key: key);

  @override
  _MainNavigationContainerState createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _selectedIndex = 0;

  // List of screens to be displayed
  // Replace these with your actual screen widgets
  static final List<Widget> _screens = [
    ExploreScreen(),
    CalendarScreen(),
    MyEventsScreen(),
    UserProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Fetch all necessary data when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).fetchAllData();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: "Calendar"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), activeIcon: Icon(Icons.confirmation_number), label: "My Events"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}