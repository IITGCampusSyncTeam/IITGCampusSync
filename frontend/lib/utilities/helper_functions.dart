import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

String convertToIST(String utcDateTime) {
  DateTime utcDate = DateTime.parse(utcDateTime).toUtc();
  DateTime istDate = utcDate.add(Duration(hours: 5, minutes: 30)); // IST offset
  return '${_formatDate(istDate)} at ${_formatTime(istDate)}';
}

String convertISTtoUTC(String istDateTime) {
  DateTime istDate = DateTime.parse(istDateTime);
  DateTime utcDate = istDate.subtract(Duration(hours: 5, minutes: 30));
  return '${_formatDate(utcDate)} at ${_formatTime(utcDate)}';
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
}

String _formatTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

// for scheduling local reminders
Future<void> requestExactAlarmsPermission() async {
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestExactAlarmsPermission();
}

void initializeTimeZone() {
  tz.initializeTimeZones();
  final String timeZoneName = tz.local.name;
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}
