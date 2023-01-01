import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lain_dain/home.dart';
import 'package:lain_dain/phone.dart';
import 'package:lain_dain/verify.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  name: 'Lain_Dain',
      options: const FirebaseOptions(
      apiKey: "AIzaSyAE11lJolK8Oyj28ulNVYmn5NJgVJ4E7gI",
      appId: "1:336373374817:ios:63a00f685eacf4f4efaf20",
      messagingSenderId: "336373374817-b1r6j0d4qpctancpci5dc7bpl5lvj3t0.apps.googleusercontent.com",
      projectId: "lain-dain-33f4e",
    ),
);
  runApp(MaterialApp(
    initialRoute: 'phone',
    debugShowCheckedModeBanner: false,
    routes: {
      'phone': (context) => const MyPhone(),
      'verify': (context) => const MyVerify(),
      'home':   (context) => MyApp() 
    },
  ));
}