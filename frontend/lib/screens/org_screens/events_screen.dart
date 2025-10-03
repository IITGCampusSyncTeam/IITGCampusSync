import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/screens/org_screens/active_events_screen.dart';
import 'package:frontend/screens/org_screens/past_events_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool _onactive = true; // true for Active, false for Past
  late final _screens = [
    ActiveEventsScreen(),
    PastEventsScreen(),
  ];

  // Callback function to be passed to pageSelector
  void _handlePageSelection(bool isActiveSelected) {
    setState(() {
      _onactive = isActiveSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 22, 0, 0),
          child: Text(
            'Events',
            style: TextStyle(
              fontSize: 20,
              // height: 24, // height on TextStyle can sometimes behave unexpectedly, consider LineHeightBehavior or other ways to control line height
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Pass the current state and the callback to pageSelector
          PageSelector(
            isInitiallyActive: _onactive,
            onSelectionChanged: _handlePageSelection,
          ),
          Expanded(
            child: _screens[_onactive ? 0 : 1],
          ),
        ],
      ),
    );
  }
}

class PageSelector extends StatefulWidget {
  // Renamed to PageSelector (UpperCamelCase)
  final bool isInitiallyActive;
  final Function(bool) onSelectionChanged; // Callback function type

  const PageSelector({
    super.key,
    required this.isInitiallyActive,
    required this.onSelectionChanged,
  });

  @override
  State<PageSelector> createState() => _PageSelectorState();
}

class _PageSelectorState extends State<PageSelector> {
  late bool
      _currentlyActive; // Local state to manage the UI of the selector itself

  @override
  void initState() {
    super.initState();
    _currentlyActive = widget.isInitiallyActive;
  }

  // This method is important if the parent might change the initial selection
  // after the widget is built for the first time.
  @override
  void didUpdateWidget(covariant PageSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isInitiallyActive != oldWidget.isInitiallyActive) {
      setState(() {
        _currentlyActive = widget.isInitiallyActive;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              height: 68,
            ),
            Divider(
              height: 2,
              color: TextColors.muted,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  if (!_currentlyActive) {
                    // Only update if the state is actually changing
                    setState(() {
                      _currentlyActive = true;
                    });
                    widget.onSelectionChanged(true); // Call the callback
                  }
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                  child: SizedBox(
                    height: 55,
                    width: 85,
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/events.svg',
                          colorFilter: ColorFilter.mode(
                            _currentlyActive // Use local state for UI
                                ? TextColors.primaryDark
                                : TextColors.muted,
                            BlendMode.srcIn,
                          ),
                        ),
                        Container(
                          height: 26,
                          width: 85,
                          alignment: Alignment.center,
                          child: AnimatedDefaultTextStyle(
                            style: TextStyle(
                                fontSize: _currentlyActive ? 14 : 12,
                                height: 1,
                                fontWeight: FontWeight.w400,
                                color: _currentlyActive
                                    ? TextColors.primaryDark
                                    : TextColors.muted),
                            duration: Duration(milliseconds: 100),
                            child: Text(
                              "Active Events",
                              maxLines: 1,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          height: 3,
                          width: 75,
                          duration: Duration(milliseconds: 100),
                          // Consider changing from microseconds
                          decoration: BoxDecoration(
                            color: _currentlyActive
                                ? TextColors.primaryDark
                                : Colors.transparent,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (_currentlyActive) {
                    // Only update if the state is actually changing
                    setState(() {
                      _currentlyActive = false;
                    });
                    widget.onSelectionChanged(false); // Call the callback
                  }
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
                  child: SizedBox(
                    height: 55,
                    width: 85,
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          color: !_currentlyActive // Use local state for UI
                              ? TextColors.primaryDark
                              : TextColors.muted,
                          size: 26,
                        ),
                        Container(
                          height: 24,
                          width: 85,
                          alignment: Alignment.center,
                          child: AnimatedDefaultTextStyle(
                            style: TextStyle(
                                fontSize: !_currentlyActive ? 14 : 12,
                                height: 1,
                                fontWeight: FontWeight.w400,
                                color: !_currentlyActive
                                    ? TextColors.primaryDark
                                    : TextColors.muted),
                            duration: Duration(milliseconds: 100),
                            child: Text(
                              "Past Events",
                              maxLines: 1,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          height: 3,
                          width: 75,
                          duration: Duration(milliseconds: 100),
                          // Consider changing from microseconds
                          decoration: BoxDecoration(
                            color: !_currentlyActive
                                ? TextColors.primaryDark
                                : Colors.transparent,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
