import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';



class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  Future<void> signInWithOTP(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> saveUserDetailsToFirestore(String phoneNumber) async {
    try {
      String fcmtoken = await getFCMToken();
      await _firestore.collection('users').doc(phoneNumber).set({
        //'uid': user.uid,
        'phone_number': phoneNumber,
        'fcmToken' : fcmtoken,
      });
    } catch (e) {
      print('Saving user details to Firestore failed: $e');
    }
  }

  Future<String> getFCMToken() async {
    String? fcmToken = await _firebaseMessaging.getToken();
    return fcmToken!;
  }

  Future<String?> getBuyerFCMToken(String buyerMobileNumber) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(buyerMobileNumber).get();
    Map<String, dynamic>? data = snapshot?.data() as Map<String, dynamic>?;
    return data?['fcmToken'] as String?;
  }





  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}