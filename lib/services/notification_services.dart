import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart' as notify;

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
      handleMessage(context, message);
    });
  }

  void requestNotificationPermissions() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      sound: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("user granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("user granted provisional permission");
    } else {
      print("user denied permission");
    }
  }

  void firebaseInit(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((event) {
      if (kDebugMode) {
        print(event.notification!.title.toString());
        print(event.notification!.body.toString());
        print(event.data.toString());
      }
      initLocalNotification(context, event);
      showNotification(event);
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        "High Importance notification",
        importance: Importance.high);

    AndroidNotificationDetails details = AndroidNotificationDetails(
        channel.id.toString(), channel.name.toString(),
        channelDescription: "Your channel description",
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker');
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);
    NotificationDetails notificationDetails =
        NotificationDetails(android: details, iOS: darwinNotificationDetails);

    Future.delayed(Duration.zero, () {
      flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    });
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'msg') {
      // Navigator.push(context, MaterialPageRoute(builder: (context)=> ));
    }
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  Future<void> sendOrderNotification(String buyerFCMToken, String orderDetails) async {
    messaging.requestPermission();
    // Retrieve the buyer's FCM token from your database using the mobile number
    // Example code for retrieving from Firestore:


    // Use the buyerFCMToken to send the notification to the buyer
    // Customize the notification payload as per your requirements
    // Example code for sending a notification:
    await messaging.sendMessage(
      to: buyerFCMToken,
      data: {
        'title': 'New Order',
        'body': 'You have a new order: $orderDetails',
      }
    );
  }
  void storeNotification(notify.Notification notification) async {
    CollectionReference notificationsRef = FirebaseFirestore.instance.collection('notifications');
    String notificationid = notificationsRef.doc().id;
    await notificationsRef.doc(notificationid).set(notification.toMap());
  }


}



