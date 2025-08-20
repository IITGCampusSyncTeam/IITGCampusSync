import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/apis/UserTag/userTag_api.dart';

import '../models/event.dart';

String getWeekdayName(int weekday) {
  const weekdayNames = [
    '',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  return weekdayNames[weekday];
}

String getMonthName(int month) {
  const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return monthNames[month - 1];
}

String formatTime(DateTime dateTime) {
  final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
}

Widget buildTimelineView(List<Event> events, userID) {
  Map<String, List<Event>> eventsByDate = {};
  for (var event in events) {
    String dateKey =
        "${event.dateTime.day} ${getMonthName(event.dateTime.month)}";
    if (!eventsByDate.containsKey(dateKey)) {
      eventsByDate[dateKey] = [];
    }
    eventsByDate[dateKey]!.add(event);
  }

  List<String> sortedDates = eventsByDate.keys.toList()
    ..sort((a, b) {
      var dateA = eventsByDate[a]![0].dateTime;
      var dateB = eventsByDate[b]![0].dateTime;
      return dateA.compareTo(dateB);
    });
  eventsByDate.forEach((date, events) {
    events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  });

  return ListView.builder(
    itemCount: sortedDates.length,
    itemBuilder: (context, index) {
      String dateKey = sortedDates[index];
      List<Event> dateEvents = eventsByDate[dateKey]!;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              dateKey,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: dateEvents.length,
            itemBuilder: (context, eventIndex) {
              Event event = dateEvents[eventIndex];
              return _buildEventCard(event, context, userID);
            },
          ),
        ],
      );
    },
  );
}

Widget buildGridView(List<Event> events, userID) {
  Map<String, List<Event>> eventsByMonth = {};
  for (var event in events) {
    String monthKey =
        "${getMonthName(event.dateTime.month)} ${event.dateTime.year}";
    if (!eventsByMonth.containsKey(monthKey)) {
      eventsByMonth[monthKey] = [];
    }
    eventsByMonth[monthKey]!.add(event);
  }

  List<String> sortedMonths = eventsByMonth.keys.toList()
    ..sort((a, b) {
      var dateA = eventsByMonth[a]![0].dateTime;
      var dateB = eventsByMonth[b]![0].dateTime;
      return dateA.compareTo(dateB);
    });

  eventsByMonth.forEach((month, monthEvents) {
    monthEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  });

  return ListView.builder(
    itemCount: sortedMonths.length,
    itemBuilder: (context, monthIndex) {
      String month = sortedMonths[monthIndex];
      List<Event> monthEvents = eventsByMonth[month]!;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              month,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemCount: monthEvents.length,
            itemBuilder: (context, index) {
              Event event = monthEvents[index];
              return Card(
                elevation: 2,
                child: InkWell(
                  onTap: () => _showEventDetails(event, context, userID),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                            event.club?.name ?? 'No Club',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${event.dateTime.day} ${getMonthName(event.dateTime.month).substring(0, 3)}, ${formatTime(event.dateTime)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(
                              event.participants.contains(userID)
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}

Widget buildCalendarView(context, List<Event> events, DateTime selectedDate,
    Function(DateTime) onMonthChanged, userID) {
  final now = DateTime.now();
  final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
  final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);

  Map<int, List<Event>> eventsByDay = {};
  for (var event in events) {
    print("Created By: ${event.club?.followers}");
    if (event.dateTime.month == selectedDate.month &&
        event.dateTime.year == selectedDate.year) {
      int day = event.dateTime.day;
      if (!eventsByDay.containsKey(day)) {
        eventsByDay[day] = [];
      }
      eventsByDay[day]!.add(event);
    }
  }

  //Random Events for Testing
  // if (events.isNotEmpty) {
  //   for (var i = 1; i <= lastDay.day; i++) {
  //     // if (event.dateTime.month == selectedDate.month &&
  //     //     event.dateTime.year == selectedDate.year) {
  //       // int day = event.dateTime.day;
  //       // if (!eventsByDay.containsKey(day)) {
  //       //   eventsByDay[day] = [];
  //       // }
  //       // eventsByDay[day]!.add(event);
  //       for (var j = 3; j < Random().nextInt(10); j++) {
  //         if (!eventsByDay.containsKey(i)) { eventsByDay[i] = []; }
  //         eventsByDay[i]!.add(events[0]);
  //       }
  //     // }
  //   }
  // }

  eventsByDay.forEach((day, dayEvents) {
    dayEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  });

  return Column(
    children: [
      _buildCalendarHeader(selectedDate, onMonthChanged),
      _buildCalendarDays(),
      Expanded(
        child: GridView.builder(
          padding: EdgeInsets.all(4),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: (MediaQuery.of(context).size.width / 7) / 125,
          ),
          itemCount: (6 - (lastDay.weekday - 1) % 7) + lastDay.day + firstDay.weekday - 1,
          itemBuilder: (context, index) {
            int dayNumber = index - firstDay.weekday + 2;

            if (dayNumber < 1) {
              return Container(
                decoration: BoxDecoration(
                  border: BorderDirectional(top: BorderSide(color: PageColors.outline.withAlpha(127), width: 1)),
                ),
                child: Column(
                      children: [
                        SizedBox(height: 2,),
                        Text("${(dayNumber - 1) % (DateTime(selectedDate.year, selectedDate.month, 0).day) + 1}", style: TextStyle(color: TextColors.muted),)
                      ],
                    ),
              );
            }

            if (dayNumber > lastDay.day) {
              return Container(
                decoration: BoxDecoration(
                  border: BorderDirectional(top: BorderSide(color: PageColors.outline.withAlpha(127), width: 1)),
                ),
                child: Column(
                      children: [
                        SizedBox(height: 2,),
                        Text("${dayNumber - lastDay.day}", style: TextStyle(color: TextColors.muted),)
                      ],
                    ),
              );
            }

            bool hasEvents = eventsByDay.containsKey(dayNumber);
            bool isToday = now.day == dayNumber;

            Color randomCalanderColor(Event event) => event.createdBy?.id == userID ? CalanderColors.green : event.club?.followers.contains(userID) ?? false ? CalanderColors.yellow : CalanderColors.blue;
            // switch (Random().nextInt(4)) {
            //   0 => CalanderColors.blue,
            //   1 => CalanderColors.green,
            //   2 => CalanderColors.pink,
            //   _ => CalanderColors.yellow,
            // };

            return InkWell(
              onTap: hasEvents
                  ? () => _showDayEvents(eventsByDay[dayNumber]!, context)
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  border: BorderDirectional(top: BorderSide(color: PageColors.outline, width: 1)),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 2,),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: isToday ? OnSurfaceColors.primaryDark : Colors.transparent),
                      child: Center(
                        child: Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontWeight: isToday ? FontWeight.w500 : FontWeight.normal,
                            color: isToday ? TextColors.primaryLight : TextColors.primaryDark,
                            fontSize: 12,
                            height: 1.167
                          ),
                        ),
                      )
                    ),
                    SizedBox(height: 2,),
                    ColoredBox(color: Colors.amber),
                    if (hasEvents)
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: List.generate(
                          eventsByDay[dayNumber]!.length > 3
                            ? 3
                            : eventsByDay[dayNumber]!.length,
                            (eventIndex) => Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 1),
                              margin: EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: randomCalanderColor(eventsByDay[dayNumber]![eventIndex])),
                              child: Text(
                                eventsByDay[dayNumber]![eventIndex].title,
                                // ["Techniche", "Hello World!"].elementAt(Random().nextInt(2)),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: TextColors.primaryDark,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w400
                                ),
                                maxLines: eventsByDay[dayNumber]!.length > 2 ? 1 : 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              )
                            )
                          ),
                        ),
                    ),
                    if (hasEvents && eventsByDay[dayNumber]!.length > 3)
                      Text(
                        '+${eventsByDay[dayNumber]!.length - 3} more',
                        style: TextStyle(fontSize: 8, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildCalendarHeader(
    DateTime selectedDate, Function(DateTime) onMonthChanged) {
  // final now = DateTime.now();
  final monthName = getMonthName(selectedDate.month);

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$monthName, ${selectedDate.year}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            fontFamily: 'Poppins',
            color: Color(0xFF131313)
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () {
                DateTime newDate;
                if (selectedDate.month == 1) {
                  newDate = DateTime(selectedDate.year - 1, 12, 1);
                } else {
                  newDate =
                      DateTime(selectedDate.year, selectedDate.month - 1, 1);
                }
                onMonthChanged(newDate);
              },
            ),
            IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: () {
                DateTime newDate;
                if (selectedDate.month == 12) {
                  newDate = DateTime(selectedDate.year + 1, 1, 1);
                } else {
                  newDate =
                      DateTime(selectedDate.year, selectedDate.month + 1, 1);
                }
                onMonthChanged(newDate);
              },
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildCalendarDays() {
  final days = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map((day) => Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ))
          .toList(),
    ),
  );
}

Widget _buildEventCard(Event event, context, userID) {
  return Card(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: InkWell(
      onTap: () => _showEventDetails(event, context, userID),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatTime(event.dateTime),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Lecture Hall',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    event.club?.name ?? 'No Club',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                event.participants.contains(userID)
                    ? Icons.bookmark
                    : Icons.bookmark_border,
              ),
              onPressed: () {
                // bookmark
              },
            ),
          ],
        ),
      ),
    ),
  );
}

void _showEventDetails(Event event, context, userID,) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              event.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(event.description),
            SizedBox(height: 8),
            Text('Date: ${event.dateTime.toString().split('.')[0]}'),
            SizedBox(height: 8),
            Text('Club: ${  event.club?.name ?? 'No Club'}'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
                SizedBox(width: 8),
                
              ],
            ),
          ],
        ),
      );
    },
  );
}

void _showDayEvents(List<Event> events, BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Events on ${events[0].dateTime.day} ${getMonthName(events[0].dateTime.month)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(event.title),
                      subtitle: Text('${formatTime(event.dateTime)} - ${event.club}'),
                      onTap: () {
                        Navigator.pop(context);
                        _showEventDetails(event, context,"");
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.7,
    ),
  );
}

Widget buildWeeklyView(List<Event> events, DateTime selectedDate,
    String organizerID, Function(DateTime) onWeekChanged) {
  DateTime monday =
      selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
  DateTime startOfWeek = DateTime(monday.year, monday.month, monday.day);
  DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

  Map<int, List<Event>> eventsByWeekday = {};
  for (var event in events) {
    if (event.dateTime.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
        event.dateTime.isBefore(endOfWeek.add(Duration(days: 1)))) {
      int weekday = event.dateTime.weekday;
      if (!eventsByWeekday.containsKey(weekday)) {
        eventsByWeekday[weekday] = [];
      }
      eventsByWeekday[weekday]!.add(event);
    }
  }

  eventsByWeekday.forEach((day, dayEvents) {
    dayEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  });

  return Column(
    children: [
      _buildWeekHeader(startOfWeek, endOfWeek, onWeekChanged),
      Expanded(
        child: ListView.builder(
          itemCount: 7,
          itemBuilder: (context, index) {
            int weekday = index + 1;
            DateTime day = startOfWeek.add(Duration(days: index));
            List<Event> dayEvents = eventsByWeekday[weekday] ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey[200],
                  child: Row(
                    children: [
                      Text(
                        getWeekdayName(weekday),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${day.day} ${getMonthName(day.month)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                dayEvents.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('No events scheduled'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: dayEvents.length,
                        itemBuilder: (context, eventIndex) {
                          return _buildWeeklyEventCard(
                              dayEvents[eventIndex], context, organizerID);
                        },
                      ),
              ],
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildWeekHeader(DateTime startOfWeek, DateTime endOfWeek,Function(DateTime) onWeekChanged) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.blue[50],
      border: Border(
        bottom: BorderSide(color: Colors.grey[300]!),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${startOfWeek.day} ${getMonthName(startOfWeek.month)} - ${endOfWeek.day} ${getMonthName(endOfWeek.month)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () {
                DateTime newWeekStart = startOfWeek.subtract(Duration(days: 7));
                onWeekChanged(newWeekStart);
              },
            ),
            IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: () {
                DateTime newWeekStart = startOfWeek.add(Duration(days: 7));
                onWeekChanged(newWeekStart);
              },
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildWeeklyEventCard(
    Event event, BuildContext context, String organizerID) {
  return Card(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: InkWell(
      onTap: () => _showEventDetails(event, context, organizerID),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatTime(event.dateTime),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Venue', // Replace with actual venue when available
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                      event.club?.name ?? 'No Club',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
