import 'package:flutter/material.dart';
import 'package:frontend/screens/org_screens/event_list_screen.dart';
import 'package:frontend/screens/org_screens/event_planner_screen.dart';
import 'calendar_screen.dart';
import 'club_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    CalendarScreen(),
    EventPlannerScreen(),
    EventListScreen(),
    ClubProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _items = const [
    BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today), label: 'Calendar'),
    BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'Planner'),
    BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
    BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Club'),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _items,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
