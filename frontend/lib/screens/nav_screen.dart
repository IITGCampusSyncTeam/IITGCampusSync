import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
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
      backgroundColor: PageColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: SizedBox(
        width: double.infinity,
        height: 64,
        child: Material(
          color: PageColors.foreground,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {setState(() {
                    _selectedIndex = 0;
                  });},
                  child: SizedBox(
                    width: 96,
                    height: 64,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.explore_outlined, color: _selectedIndex == 0 ? TextColors.primaryDark : TextColors.muted),
                        SizedBox(height: 2,),
                        AnimatedDefaultTextStyle(style: TextStyle(fontSize: _selectedIndex == 0 ? 14 : 12, height: 1, fontWeight: FontWeight.w400, color: _selectedIndex == 0 ? TextColors.primaryDark : TextColors.muted), duration: Duration(milliseconds: 100), child: Text("Explore", maxLines: 1,)),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {setState(() {
                    _selectedIndex = 1;
                  });},
                  child: SizedBox(
                    width: 96,
                    height: 64,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined, color: _selectedIndex == 1 ? TextColors.primaryDark : TextColors.muted),
                        SizedBox(height: 2,),
                        AnimatedDefaultTextStyle(style: TextStyle(fontSize: _selectedIndex == 1 ? 14 : 12, height: 1, fontWeight: FontWeight.w400, color: _selectedIndex == 1 ? TextColors.primaryDark : TextColors.muted), duration: Duration(milliseconds: 100), child: Text("Calender", maxLines: 1,)),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {setState(() {
                    _selectedIndex = 2;
                  });},
                  child: SizedBox(
                    width: 96,
                    height: 64,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.confirmation_number_outlined, color: _selectedIndex == 2 ? TextColors.primaryDark : TextColors.muted),
                        SizedBox(height: 2,),
                        AnimatedDefaultTextStyle(style: TextStyle(fontSize: _selectedIndex == 2 ? 14 : 12, height: 1, fontWeight: FontWeight.w400, color: _selectedIndex == 2 ? TextColors.primaryDark : TextColors.muted), duration: Duration(milliseconds: 100), child: Text("Calender", maxLines: 1,)),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {setState(() {
                    _selectedIndex = 3;
                  });},
                  child: SizedBox(
                    width: 96,
                    height: 64,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline, color: _selectedIndex == 3 ? TextColors.primaryDark : TextColors.muted),
                        SizedBox(height: 2,),
                        AnimatedDefaultTextStyle(style: TextStyle(fontSize: _selectedIndex == 3 ? 14 : 12, height: 1, fontWeight: FontWeight.w400, color: _selectedIndex == 3 ? TextColors.primaryDark : TextColors.muted), duration: Duration(milliseconds: 100), child: Text("Profile", maxLines: 1,)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      )
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
      //     BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendar"),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      //   ],
      //   backgroundColor: PageColors.foreground,
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: Colors.black,
      //   unselectedItemColor: Colors.grey,
        // onTap: _onItemTapped,
      // ),
    );
  }
}