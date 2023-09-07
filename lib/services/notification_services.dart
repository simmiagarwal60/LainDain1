import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lain_dain/screens/notification_screen.dart';
import 'package:lain_dain/services/firebase_auth.dart';
import 'package:lain_dain/widget/pending_orders.dart';
import '../models/notification_model.dart' as notify;

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String? buyerfcmToken;

  void initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
      if(payload != null){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> PendingOrders()));
      }

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
        ticker: 'ticker',
    sound: RawResourceAndroidNotificationSound('notification'));
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
          notificationDetails,
      payload: message.data['body']);
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

  void storeNotification(notify.Notification notification) async {
    CollectionReference notificationsRef = FirebaseFirestore.instance.collection('notifications');
    String notificationid = notificationsRef.doc().id;
    await notificationsRef.doc(notificationid).set(notification.toMap());
  }

  Future<void> sendNotificationToBuyer(String buyerMobileNumber, String message, String title) async {
    const String url = 'https://fcm.googleapis.com/fcm/send';
    const String serverKey = 'AAAAp02aT6g:APA91bE00EirjEbwY1VPyySXtWKgJ8yX7YgTRRRIuBuFqjnTi5VWzMR7NiBx14ecjar9S-4OGyv22wr8zSOmumEmxxDObi_eWRasqvyii_oF3wrNPYCqyUZ08T-DUFLzmxGQmlEFfPrE';
    // Obtain your FCM server key from Firebase console

    await AuthService.instance.getBuyerFCMToken(buyerMobileNumber).then((String? result){
      buyerfcmToken = result;
    });
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final Map<String, String> notification = {
      'title': 'New Order',
      'body' : 'You have a new order. Tap to view details.',
      'android_channel_id': 'simran'
    };


    final body = {
      'notification': notification,
      'priority': 'high',
      'body': message,
      'title': title,
      'data': {
        'screen': 'order_acceptance', // Identify the screen to navigate on click
        // Add additional data if required
      },
      'to': buyerfcmToken, // Buyer's device token obtained during login/authentication
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
      print('mobileNumber: ${buyerMobileNumber}');
      print('buyerFcmToken: $buyerfcmToken');

    } else {
      print('Failed to send notification with status: ${response.statusCode}');
    }
  }


}



