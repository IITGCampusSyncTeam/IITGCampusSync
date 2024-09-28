// import 'dart:io' show Platform;
//
// import 'package:firebase_core/firebase_core.dart';
// import "package:firebase_messaging/firebase_messaging.dart";
// import "package:flutter_local_notifications/flutter_local_notifications.dart";
// import 'package:shared_preferences/shared_preferences.dart';
//
// // Background message handler
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('A background message just showed up: ${message.messageId}');
//
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'iitg_high_importance_channel', // id
//     'IITG High Importance Notifications', // title
//     description:
//         'This channel is used for important notifications related to IITG Campus Sync.', // description
//     importance: Importance.high,
//     playSound: true,
//   );
//
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//
//   AndroidNotificationDetails androidNotificationDetails =
//       AndroidNotificationDetails(
//     channel.id,
//     channel.name,
//     channelDescription: channel.description,
//     importance: Importance.high,
//     playSound: true,
//     icon:
//         'notification_icon', // Make sure to include your notification icon in the assets
//   );
//
//   DarwinNotificationDetails iosNotificationDetails =
//       const DarwinNotificationDetails(
//     presentAlert: true,
//     presentBadge: true,
//     presentSound: true,
//   );
//
//   NotificationDetails notificationDetails = NotificationDetails(
//     android: androidNotificationDetails,
//     iOS: iosNotificationDetails,
//   );
//
//   RemoteNotification? notification = message.notification;
//
//   if (notification != null) {
//     await flutterLocalNotificationsPlugin.show(
//       message.hashCode,
//       notification.title,
//       notification.body,
//       notificationDetails,
//     );
//   }
// }
//
// @pragma('vm:entry-point')
// void onDidReceiveNotificationResponse(
//     NotificationResponse notificationResponse) async {
//   final String? payload = notificationResponse.payload;
//   if (payload != null) {
//     print('Notification payload: $payload');
//   }
//   // Navigate to a specific screen or perform an action based on the payload
// }
// //
// // bool checkNotificationCategory(String type) {
// //   // Define valid categories for IITG notifications
// //   return type == "event" || type == "announcement" || type == "reminder";
// // }
//
// Future<bool> checkForNotifications() async {
//   await FirebaseMessaging.instance.subscribeToTopic('iitg_all');
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   if (Platform.isAndroid) {
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.requestNotificationsPermission();
//   }
//
//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'iitg_high_importance_channel',
//     'IITG High Importance Notifications',
//     description:
//         'This channel is used for important notifications related to IITG Campus Sync.',
//     importance: Importance.high,
//     playSound: true,
//   );
//
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//
//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');
//   const DarwinInitializationSettings initializationSettingsDarwin =
//       DarwinInitializationSettings(
//     requestSoundPermission: true,
//     requestBadgePermission: true,
//     requestAlertPermission: true,
//   );
//
//   const InitializationSettings initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//     iOS: initializationSettingsDarwin,
//   );
//
//   await flutterLocalNotificationsPlugin.initialize(
//     initializationSettings,
//     onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
//   );
//
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//     AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(channel.id, channel.name,
//             channelDescription: channel.description,
//             importance: Importance.high,
//             playSound: true,
//             icon: 'notification_icon');
//
//     DarwinNotificationDetails iosNotificationDetails =
//         const DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );
//
//     NotificationDetails notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//       iOS: iosNotificationDetails,
//     );
//
//     await flutterLocalNotificationsPlugin.show(message.hashCode,
//         message.data['title'], message.data['body'], notificationDetails);
//   });
//
//   final SharedPreferences preferences = await SharedPreferences.getInstance();
//   await preferences.reload();
//   List<String> notifications = preferences.getStringList('notifications') ?? [];
//   preferences.setStringList('notifications', notifications);
//   return true;
// }
