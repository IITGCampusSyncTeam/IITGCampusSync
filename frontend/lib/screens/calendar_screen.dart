import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/constants/endpoints.dart';
import 'package:frontend/models/event.dart';
import 'package:frontend/screens/calendar_filter_slider.dart';
import 'package:frontend/screens/search_screen.dart';
import 'package:frontend/widgets/calendar_widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/eventProvider.dart';
import 'package:frontend/constants/colors.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

enum ViewType { month, day5, list }

class _CalendarScreenState extends State<CalendarScreen> {
  bool dateSelection = false;
  ViewType _currentView = ViewType.month;
  String? _userId; // Will be loaded from SharedPreferences
  @override
  void initState() {
    super.initState();
    _loadUserId();


    // Initialize the provider by fetching events when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EventProvider>(context, listen: false);
      provider.fetchAllEvents();
    });
  }

  void _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString('user_data');
    print('🔍 user_data from SharedPreferences: $userDataJson');
    if (userDataJson != null) {
      final userMap = jsonDecode(userDataJson);
      setState(() {
        _userId = userMap['_id'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the EventProvider
    print("🧱 Building CalendarScreen | userId: $_userId");
    final eventProvider = Provider.of<EventProvider>(context);
    final monthDays = DateTime(eventProvider.selectedDate.year, eventProvider.selectedDate.month + 1).difference(DateTime(eventProvider.selectedDate.year, eventProvider.selectedDate.month)).inDays;

    return SafeArea(
      child: Scaffold(
        backgroundColor: PageColors.background,
        // body: Column(
        //   children: [
        //     // Toggle buttons for All events and My events
        //     Padding(
        //       padding:
        //           const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        //       child: Container(
        //         decoration: BoxDecoration(
        //           color: PageColors.foreground,
        //           borderRadius: BorderRadius.circular(20),
        //         ),
        //         child: Row(
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             _buildToggleButton('All events', !_showMyEventsOnly),
        //             _buildToggleButton('My events', _showMyEventsOnly),
        //           ],
        //         ),
        //       ),
        //     ),

        //     // Search bar
        //     Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        //       child: Row(
        //         children: [
        //           Expanded(
        //               child: InkWell(
        //             onTap: () {
        //               Navigator.push(
        //                 context,
        //                 MaterialPageRoute(builder: (context) => SearchScreen()),
        //               );
        //             },
        //             child: Container(
        //               height: 44,
        //               decoration: BoxDecoration(
        //                 color: PageColors.foreground,
        //                 borderRadius: BorderRadius.circular(30),
        //               ),
        //               child: Row(
        //                 children: [
        //                   Padding(
        //                     padding:
        //                         const EdgeInsets.symmetric(horizontal: 16.0),
        //                         child: Icon(Icons.search, color: TextColors.muted,),
        //                   ),
        //                   Text('Search Events ...', style: TextStyle(fontFamily: 'Sans', fontSize: 14, letterSpacing: -0.5, color: TextColors.muted),),
        //                 ],
        //               ),
        //             ),
        //           )),
        //           SizedBox(width: 4),
        //           Container(
        //             width: 44,
        //             height: 44,
        //             decoration: BoxDecoration(
        //               color: PageColors.foreground,
        //               borderRadius: BorderRadius.circular(22),
        //             ),
        //             child: IconButton(
        //               icon: Icon(Icons.tune, color: PageColors.icon,),
        //               onPressed: () {},
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),

        //     // View selector buttons
        //     Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.end,
        //         children: [
        //           IconButton(
        //             icon: Icon(Icons.view_agenda),
        //             color: _currentView == ViewType.timeline
        //                 ? Colors.blue
        //                 : Colors.grey,
        //             onPressed: () {
        //               setState(() {
        //                 _currentView = ViewType.timeline;
        //               });
        //             },
        //           ),
        //           IconButton(
        //             icon: Icon(Icons.grid_view),
        //             color: _currentView == ViewType.grid
        //                 ? Colors.blue
        //                 : Colors.grey,
        //             onPressed: () {
        //               setState(() {
        //                 _currentView = ViewType.grid;
        //               });
        //             },
        //           ),
        //           IconButton(
        //             icon: Icon(Icons.calendar_today),
        //             color: _currentView == ViewType.calendar
        //                 ? Colors.blue
        //                 : Colors.grey,
        //             onPressed: () {
        //               setState(() {
        //                 _currentView = ViewType.calendar;
        //               });
        //             },
        //           ),
        //         ],
        //       ),
        //     ),

        //     // Main content with loading state from provider
        //     Expanded(
        //       child: eventProvider.isLoading
        //           ? Center(child: CircularProgressIndicator())
        //           : eventProvider.errorMessage.isNotEmpty
        //               ? Center(child: Text(eventProvider.errorMessage))
        //               : _buildCurrentView(eventProvider),
        //     ),
        //   ],
        // ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                children: [
                  Container(
                    height: 24,
                    padding: EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTapDown: (details) {
                        setState(() {
                          dateSelection = true;
                        });
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(["January", "Febuary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"][eventProvider.selectedDate.month - 1], style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: TextColors.primaryDark),),
                          Icon(Icons.keyboard_arrow_down, color: TextColors.primaryDark, size: 20,)
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    height: 40,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentView = _currentView == ViewType.month ? _currentView = ViewType.day5 : _currentView == ViewType.day5 ? ViewType.list : ViewType.month;
                            });
                          },
                          child: Container(
                            height: 36,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFFE4E4E7),
                              borderRadius: BorderRadius.circular(16)
                            ),
                            child: Text(_currentView == ViewType.month ? "Month" : _currentView == ViewType.day5 ? "5 Day" : "List", style: TextStyle(fontWeight: FontWeight.w500, color: TextColors.primaryDark),),
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          child: Icon(Icons.search, color: Colors.black, size: 24,),
                        ),
                        IconButton(
                          icon: Icon(Icons.tune, color: PageColors.icon), 
                          onPressed: () async {
                            await CalendarFilterSlider.show(context);
                            if (!context.mounted) return;
                            Provider.of<EventProvider>(context, listen: false)
                              .applyFiltersAndNotify(CalendarFilterSlider.lastApplied);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  eventProvider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : eventProvider.errorMessage.isNotEmpty
                    ? Center(child: Text(eventProvider.errorMessage))
                    : _buildCurrentView(eventProvider),

                  if (dateSelection)
                    TapRegion(
                      onTapOutside: (event) {
                        setState(() {
                          dateSelection = false;
                        });
                      },
                      child: Column(
                        children: [
                          ColoredBox(
                            color: PageColors.background,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    for (int i = 0; i < 7; i++)
                                      Container(
                                        height: 40,
                                        alignment: Alignment.center,
                                        child: Text("${['S', 'M', 'T', 'W', 'T', 'F', 'S'][i]}"),
                                      )
                                  ],
                                ),
                                for (int days = -(((DateTime(eventProvider.selectedDate.year, eventProvider.selectedDate.month).weekday + 1) % 7) - 1); days <= monthDays; days += 7)
                                  Row(
                                    children: [
                                      for (int i = 0; i < 7; i++)
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                eventProvider.setSelectedDate(DateTime(eventProvider.selectedDate.year, eventProvider.selectedDate.month, days + i));
                                              });
                                            },
                                            child: Container(
                                              height: 40,
                                              alignment: Alignment.center,
                                              child: Container(
                                                height: 24,
                                                width: 24,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(4),
                                                  color: (days + i == eventProvider.selectedDate.day) && (eventProvider.selectedDate.month == eventProvider.selectedDate.month) ? TextColors.primaryDark : Colors.transparent
                                                ),
                                                alignment: Alignment.center,
                                                child: Text("${days + i > 0 ? days + i <= monthDays ? days + i : "" : ""}".padLeft(2), style: TextStyle(color: (days + i == eventProvider.selectedDate.day) && (eventProvider.selectedDate.month == eventProvider.selectedDate.month) ? TextColors.primaryLight : TextColors.primaryDark),)
                                              ),
                                            ),
                                          ),
                                        )
                                    ],
                                  ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      SizedBox(width: 8,),
                                      for (int month = 1; month <= 12; month++)
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              eventProvider.setSelectedDate(DateTime(eventProvider.selectedDate.year, month, 1));
                                            });
                                          },
                                          child: Container(
                                            height: 28,
                                            margin: EdgeInsets.only(left: 2, right: 2, top: 8, bottom: 16),
                                            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(14),
                                              border: Border.all(color: Color(0xFFE4E4E7)),
                                              color: month == eventProvider.selectedDate.month ? TextColors.primaryDark : Colors.transparent,
                                            ),
                                            child: Text(['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1], style: TextStyle(height: 1.34, fontSize: 12, color: month == eventProvider.selectedDate.month ? TextColors.primaryLight : TextColors.primaryDark),),
                                          ),
                                        ),
                                      SizedBox(width: 8,)
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildToggleButton(String text, bool isSelected) {
  //   return GestureDetector(
  //     onTap: () {
  //       setState(() {
  //         _showMyEventsOnly = text == 'My events';
  //       });
  //     },
  //     child: Container(
  //       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //       decoration: BoxDecoration(
  //         color: isSelected ? OnSurfaceColors.primaryDark : Colors.transparent,
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       child: Text(
  //         text,
  //         style: TextStyle(
  //           color: isSelected ? Colors.white : TextColors.primaryDark,
  //           // fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //           fontWeight: FontWeight.w500
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildCurrentView(EventProvider provider) {
    if (_userId == null) {
      _userId = "";
      // return const Center(
      //   child: CircularProgressIndicator() // Wait for userID
      // );
    }

    // List<Event> filteredEvents = _showMyEventsOnly
    //     ? provider.allEvents
    //         .where((event) => event.participants.contains(_userId))
    //         .toList()
    //     : provider.allEvents;

    List<Event> filteredEvents = provider.allEvents
      // .where((event) => event.participants.contains(_userId))
      .toList();

    switch (_currentView) {
      case ViewType.list:
        return buildTimelineView(filteredEvents, _userId!);
      case ViewType.day5:
        return buildHourlyView(
          events: filteredEvents,
          selectedDate: provider.selectedDate,
          onMonthChanged: (newDate) => provider.setSelectedDate(newDate),
          userID: _userId!
        );
      case ViewType.month:
        return buildMonthView(
          context,
          filteredEvents,
          provider.selectedDate,
          (newDate) => provider.setSelectedDate(newDate),
          _userId!
        );
    }
  }
}
