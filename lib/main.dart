import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lain_dain/screens/buyer-form.dart';
import 'package:lain_dain/screens/add_address_details.dart';
import 'package:lain_dain/screens/delivery_details.dart';
import 'package:lain_dain/screens/notification_screen.dart';
import 'package:lain_dain/screens/order_screen.dart';
import 'package:lain_dain/screens/payment_page.dart';
import 'package:lain_dain/screens/phone.dart';
import 'package:lain_dain/screens/seller-form.dart';
import 'package:lain_dain/screens/seller_orderHistory.dart';
import 'package:lain_dain/screens/verify.dart';

import 'firebase_options.dart';
import 'screens/home.dart';
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async{
  print(message.data.toString());
  print(message.notification!.title);
  //await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'Lain_Dain',
    //   options: const FirebaseOptions(
    //   apiKey: "AIzaSyAE11lJolK8Oyj28ulNVYmn5NJgVJ4E7gI",
    //   appId: "1:336373374817:ios:63a00f685eacf4f4efaf20",
    //   messagingSenderId: "336373374817-b1r6j0d4qpctancpci5dc7bpl5lvj3t0.apps.googleusercontent.com",
    //   projectId: "lain-dain-33f4e",
    // ),
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.getInitialMessage();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(MaterialApp(
        initialRoute: 'phone',
        debugShowCheckedModeBanner: false,
        // routes: {
        //   'phone': (context) => const MyPhone(),
        //   'verify': (context) => const MyVerify(),
        //   'home':   (context) =>  const MyApp(),
        //   'buyer': (context) => const BuyerFormScreen(),
        //   'seller': (context)=> const FormScreen(selectedAddress: selectedAddress)
        // },
        home: PaymentScreen(orderId: 'gfss', amount: 'fgsgda', businessName: 'fgdsg')
      ));

}
