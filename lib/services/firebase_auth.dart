import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:lain_dain/models/category_model.dart';

import '../models/orders_model.dart';
import '../models/users.dart';



class AuthService {
  static AuthService instance = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late String orderId;


  Future<void> signInWithOTP(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> saveUserDetailsToFirestore(String phoneNumber, String userId) async {
    String fcmToken = await getFCMToken();
    Users user = Users(phoneNumber: phoneNumber, fcmToken: fcmToken, userId:userId, userRole: "user" );
    try {

      await _firestore.collection('users').doc(phoneNumber).set(user.toJson());
    } catch (e) {
      print('Saving user details to Firestore failed: $e');
    }
  }
  Future<void> updateUserRole(String userRole) async {

    await _firestore.collection('users').doc(_firebaseAuth.currentUser!.phoneNumber).update(
        {'userRole': userRole});
  }

  void updateSellerDetails(String aadhaar, String pan, String firstName, String lastName, String businessName, String pkupAddrs) async {

    await _firestore.collection('users').doc(_firebaseAuth.currentUser!.phoneNumber).update({
      'aadhaarNumber': aadhaar,
      'panNumber': pan,
      'firstName': firstName,
      'lastName': lastName,
      'businessName': businessName,
      'pickupAddress': pkupAddrs,
    });
  }

  void updateBuyerDetails(String fullName, String email, String phoneNumber, String address, String pincode) async {
    await _firestore.collection('users').doc(_firebaseAuth.currentUser!.phoneNumber).update({
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'pincode': pincode,
    });
  }
  //Orders
  Future<void> saveOrderDetailsToFirestore(String status, String businessName, String orderCategory, String orderValue, String orderWeightage, String customerMobileNumber,
  String pickupAddress, String deliveryAddress) async {
    DocumentReference orderDocument = FirebaseFirestore.instance
        .collection('userOrders')
        .doc(FirebaseAuth.instance.currentUser!.uid).collection('order').doc();
    orderId = orderDocument.id;
    final order = Orders(
        status: status,
        orderId: orderId,
        businessName: businessName,
        orderCategory: orderCategory,
        orderValue: orderValue,
        orderWeightage: orderWeightage,
        customerMobileNumber: customerMobileNumber,
        pickupAddress: pickupAddress,
        deliveryAddress: deliveryAddress);
    try {

      FirebaseFirestore.instance
          .collection('userOrders')
          .doc(FirebaseAuth.instance.currentUser!.uid).collection('order').doc(orderId)
          .set(order.toJson());
    } catch (e) {
      print('Saving order details to Firestore failed: $e');
    }
  }

  Future<List<CategoryModel>> getCategories() async{
    try{
      QuerySnapshot<Map<String,dynamic>> querySnapshot = await _firestore.collection('categories').get();

      List<CategoryModel> _categoriesList = querySnapshot.docs.map((e) => CategoryModel.fromJson(e.data())).toList();

      return _categoriesList;
    }
    catch(e){
      print(e.toString());
      return [];
    }
  }
   Future<List<Orders>> getOrders(BuildContext context) async{
    try{
      QuerySnapshot<Map<String,dynamic>> querySnapshot = await _firestore.collection('userOrders').doc(FirebaseAuth.instance.currentUser!.uid).collection('order').get();

      List<Orders> _ordersList = querySnapshot.docs.map((e) => Orders.fromJson(e.data())).toList();

      return _ordersList;
    }
    catch(e){
      print(e.toString());
      return [];
    }
  }


  Future<String> getFCMToken() async {
    String? fcmToken = await _firebaseMessaging.getToken();
    return fcmToken!;
  }

  Future<String?> getBuyerFCMToken(String buyerMobileNumber) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(buyerMobileNumber).get();
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    return data?['fcmToken'] as String?;
  }

  Future<void> updateOrderModel(Orders orderModel, String status) async{
    await _firestore.collection('userOrders').doc(_firebaseAuth.currentUser!.uid).collection('order').doc(orderModel.orderId).update(
        {'status': status});
  }





  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}