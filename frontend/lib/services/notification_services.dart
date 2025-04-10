import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:frontend/screens/event_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationServices {
  //initialising firebase message plugin
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  bool isInitialized = false;

  //initialising firebase message plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initLocalNotifications(BuildContext context) async {
    if (isInitialized) return;

    // Initialize timezone settings
    // tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // Android settings
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings();

    // Combine init settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    // Create notification channel (Android only)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_channel_id', // MUST match the channel ID used in notificationDetails
      'Daily Notifications',
      description: 'Daily Notification Channel',
      importance: Importance.max,
    );

    // Create the notification channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request exact alarm permission (Android 12+)
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    // Request permissions on iOS
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    // Initialize plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("🔔 Notification clicked: ${response.payload}");

        if (response.payload != null) {
          try {
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            if (data['type'] == 'msj') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventScreen()),
              );
            }
          } catch (e) {
            print("❌ Error decoding notification payload: $e");
          }
        }
      },
    );

    isInitialized = true;
  }

  //function to initialise flutter local notification plugin to show notifications for android when app is active
  // Future<void> initLocalNotifications(BuildContext context) async {
  //   if (isInitialized) return;
  //   final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
  //   tz.setLocalLocation(tz.getLocation(currentTimeZone));
  //   var androidInitializationSettings =
  //       const AndroidInitializationSettings('@mipmap/ic_launcher');
  //   var iosInitializationSettings = const DarwinInitializationSettings();
  //
  //   var initializationSetting = InitializationSettings(
  //       android: androidInitializationSettings, iOS: iosInitializationSettings);
  //   const AndroidNotificationChannel channel = AndroidNotificationChannel(
  //     'daily_channel_id', // Must match the ID in notificationDetails()
  //     'Daily Notifications',
  //     description: 'Daily Notification Channel',
  //     importance: Importance.max,
  //   );
  //
  //   await _flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //           AndroidFlutterLocalNotificationsPlugin>()
  //       ?.createNotificationChannel(channel);
  //
  //   await _flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //           AndroidFlutterLocalNotificationsPlugin>()
  //       ?.requestExactAlarmsPermission();
  //
  //   await _flutterLocalNotificationsPlugin.initialize(
  //     initializationSetting,
  //     onDidReceiveNotificationResponse: (NotificationResponse response) {
  //       print("notif clicked: ${response.payload}");
  //       if (response.payload != null) {
  //         Map<String, dynamic> data = jsonDecode(response.payload!);
  //         if (data['type'] == 'msj') {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => EventScreen()),
  //           );
  //         }
  //       }
  //     },
  //   );
  // }

  void OnNotificationTap(NotificationResponse response) {
    print("notif clicked: ${response.payload}");
  }

  // might be helpful later
  // void firebaseInit(BuildContext context) {
  //   FirebaseMessaging.onMessage.listen((message) {
  //     RemoteNotification? notification = message.notification;
  //     AndroidNotification? android = message.notification!.android;
  //
  //     if (kDebugMode) {
  //       print("notifications title:${notification!.title}");
  //       print("notifications body:${notification.body}");
  //       print('count:${android!.count}');
  //       print('data:${message.data.toString()}');
  //     }
  //
  //     if (Platform.isIOS) {
  //       forgroundMessage();
  //     }
  //
  //     if (Platform.isAndroid) {
  //       initLocalNotifications(context, message);
  //       // showNotification();
  //       showNotification(
  //         title: message.notification?.title,
  //         body: message.notification?.body,
  //       );
  //     }
  //   });
  // }

  void requestNotificationPermission() async {
    // Firebase permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) print('✅ Firebase notification permission granted');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode)
        print('ℹ️ Provisional Firebase notification permission granted');
    } else {
      if (kDebugMode) print('❌ Firebase notification permission denied');
    }

    // Android 13+ post notification permission
    if (Platform.isAndroid) {
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        var result = await Permission.notification.request();
        if (result.isGranted) {
          if (kDebugMode)
            print('✅ Android POST_NOTIFICATION permission granted');
        } else {
          if (kDebugMode)
            print('❌ Android POST_NOTIFICATION permission denied');
        }
      }
    }
  }

  // void requestNotificationPermission() async {
  //   NotificationSettings settings = await messaging.requestPermission(
  //     alert: true,
  //     announcement: true,
  //     badge: true,
  //     carPlay: true,
  //     criticalAlert: true,
  //     provisional: true,
  //     sound: false,
  //   );
  //
  //   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //     if (kDebugMode) {
  //       print('user granted permission');
  //     }
  //   } else if (settings.authorizationStatus ==
  //       AuthorizationStatus.provisional) {
  //     if (kDebugMode) {
  //       print('user granted provisional permission');
  //     }
  //   } else {
  //     //appsetting.AppSettings.openNotificationSettings();
  //     if (kDebugMode) {
  //       print('user denied permission');
  //     }
  //   }
  // }
  //
  // function to show visible notification when app is active
  // Future<void> showNotification(RemoteMessage message) async {
  //   AndroidNotificationChannel channel = AndroidNotificationChannel(
  //     message.notification!.android!.channelId.toString(),
  //     message.notification!.android!.channelId.toString(),
  //     importance: Importance.max,
  //     showBadge: true,
  //     playSound: true,
  //   );
  //
  //   AndroidNotificationDetails androidNotificationDetails =
  //       AndroidNotificationDetails(
  //           channel.id.toString(), channel.name.toString(),
  //           channelDescription: 'your channel description',
  //           importance: Importance.high,
  //           priority: Priority.high,
  //           playSound: true,
  //           ticker: 'ticker',
  //           sound: channel.sound
  //           //     sound: RawResourceAndroidNotificationSound('jetsons_doorbell')
  //           //  icon: largeIconPath
  //           );
  //
  //   const DarwinNotificationDetails darwinNotificationDetails =
  //       DarwinNotificationDetails(
  //           presentAlert: true, presentBadge: true, presentSound: true);
  //
  //   NotificationDetails notificationDetails = NotificationDetails(
  //       android: androidNotificationDetails, iOS: darwinNotificationDetails);
  //
  //   Future.delayed(Duration.zero, () {
  //     _flutterLocalNotificationsPlugin.show(
  //       0,
  //       message.notification!.title.toString(),
  //       message.notification!.body.toString(),
  //       notificationDetails,
  //     );
  //   });
  // }

  //function to get device token on which we will send the notifications
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    final prefs = await SharedPreferences.getInstance();
    return token!;
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      if (kDebugMode) {
        print('refresh');
      }
    });
  }

  //handle tap on notification when app is in background or terminated
  Future<void> setupInteractMessage(BuildContext context) async {
    // when app is terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }

    //when app ins background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'msj') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => EventScreen()));
    }
  }

  Future forgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  //notif details setup
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
          'daily_channel_id', 'Daily Notifications',
          channelDescription: 'Daily Notification Channel',
          importance: Importance.max,
          priority: Priority.high),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification({
    int id = 8,
    String? title,
    String? body,
  }) async {
    return _flutterLocalNotificationsPlugin.show(
        id, title, body, notificationDetails());
  }

  Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {
    try {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin
          ?.requestNotificationsPermission(); // POST_NOTIFICATIONS
      await androidPlugin
          ?.requestExactAlarmsPermission(); // SCHEDULE_EXACT_ALARM
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = tz.TZDateTime.from(scheduledDateTime, tz.local);

      print("scheduled date: $scheduledDate");
      print("Current: ${tz.TZDateTime.now(tz.local)}");
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails(), // using your defined details
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null, // if you want *exact one-time* trigger
      );

      print("notification scheduled ✅");
    } catch (e, stackTrace) {
      print("❌ Error scheduling notification: $e");
      print("📄 Stack trace: $stackTrace");
    }
  }

  // //scheduled notifs
  // Future<void> scheduleLocalNotification({
  //   required int id,
  //   required String title,
  //   required String body,
  //   required DateTime scheduledDateTime,
  // }) async {
  //   final now = tz.TZDateTime.now(tz.local);
  //
  //   var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
  //       scheduledDateTime.hour, scheduledDateTime.minute);
  //   print("scheduled date: $scheduledDate");
  //   //schedule the notif
  //   await _flutterLocalNotificationsPlugin.zonedSchedule(
  //     id,
  //     title,
  //     body,
  //     scheduledDate,
  //     const NotificationDetails(),
  //     androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
  //     matchDateTimeComponents: DateTimeComponents.time,
  //   );
  //   print("notifications scheduled");
  // }

  // cancel all notifs
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
