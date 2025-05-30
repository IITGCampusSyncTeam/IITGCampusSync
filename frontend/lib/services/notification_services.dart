import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/screens/explore_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                MaterialPageRoute(builder: (context) => ExploreScreen()),
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
          context, MaterialPageRoute(builder: (context) => ExploreScreen()));
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

  // cancel all notifs
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
