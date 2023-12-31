import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:lain_dain/models/category_model.dart';
import 'package:lain_dain/screens/buyer-form.dart';
import 'package:lain_dain/screens/buyer_landing_page.dart';
import 'package:lain_dain/screens/phone.dart';
import 'package:lain_dain/screens/seller-form.dart';
import 'package:lain_dain/screens/seller_landing_page.dart';
import '../models/orders_model.dart';
import '../models/pickup_address_model.dart';
import '../models/userOrders.dart';
import '../models/users.dart';
import '../screens/buyer_main_screen.dart';
import '../screens/seller_main.dart';

class AuthService {
  static AuthService instance = AuthService();
  static FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late String orderId;

  static User get currentUser => _firebaseAuth.currentUser!;

  static Users me = Users(
    fullName: '',
    phoneNumber: currentUser.phoneNumber!,
    fcmToken: '',
    userId: currentUser.uid,
    image: currentUser.photoURL.toString(),
  );

  handleAuth() {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
            .snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            Map<String, dynamic> data =
                snapshot.data?.data() as Map<String, dynamic>;
            if (data['userRole'] == 'Seller') {
              if (data['aadhaarNumber'] != null) {
                return SellerMainScreen(
                    businessName: data['businessName'] ?? '');
              }
              return FormScreen(
                  selectedAddress: PickupAddress(
                      id: '',
                      fullName: '',
                      pincode: '',
                      houseNumber: '',
                      city: '',
                      state: ''));
            } else if (data['userRole'] == 'Buyer') {
              if (data['email'] != null) {
                return BuyerMainScreen();
              }
              return BuyerFormScreen();
            }
          }
          return MyPhone();
        });
  }

  Future<void> signInWithOTP(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> saveUserDetailsToFirestore(
      String phoneNumber, String userId) async {
    String fcmToken = await getFCMToken();
    Users user = Users(
        fullName: '',
        phoneNumber: phoneNumber,
        fcmToken: fcmToken,
        userId: userId,
        image: currentUser.photoURL.toString());
    try {
      await _firestore.collection('users').doc(phoneNumber).set(user.toJson());
    } catch (e) {
      print('Saving user details to Firestore failed: $e');
    }
  }

  Future<void> updateUserRole(String userRole) async {
    await _firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.phoneNumber)
        .update({'userRole': userRole});
    //me.userRole = userRole;
  }

  void updateCurrentUserData(Users? user, firstName, lastName) async {
    if (user != null) {
      // DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(_firebaseAuth.currentUser!.phoneNumber);
      // userRef.update(updateData);
      await _firestore
          .collection('users')
          .doc(_firebaseAuth.currentUser!.phoneNumber)
          .update({
        'firstName': firstName,
        'lastName': lastName,
        'fullName': user!.fullName,
      });
    }
  }

  void updateUserProfilePicture(File file, String uid) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_pictures/$uid.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    String imageUrl = await ref.getDownloadURL();
    await _firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.phoneNumber)
        .update({
      'image': imageUrl,
    });
  }

  void updateSellerDetails(String aadhaar, String pan, String firstName,
      String lastName, String businessName, String pkupAddrs) async {
    await _firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.phoneNumber)
        .update({
      'aadhaarNumber': aadhaar,
      'panNumber': pan,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': '$firstName $lastName',
      'businessName': businessName,
      'pickupAddress': pkupAddrs,
    });
    me.fullName = '$firstName $lastName';
  }

  void updateBuyerDetails(String fullName, String email, String phoneNumber,
      String address, String pincode) async {
    await _firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.phoneNumber)
        .update({
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'pincode': pincode,
    });
    me.fullName = fullName;
  }

  //Orders
  Future<void> saveOrderDetailsToFirestore(
      String status,
      String businessName,
      String orderCategory,
      String orderValue,
      String orderWeightage,
      String customerMobileNumber,
      String pickupAddress,
      String deliveryAddress) async {
    DocumentReference orderDocument = FirebaseFirestore.instance
        .collection('userOrders')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('order')
        .doc();
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
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('order')
          .doc(orderId)
          .set(order.toJson());
    } catch (e) {
      print('Saving order details to Firestore failed: $e');
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _firestore.collection('categories').get();

      List<CategoryModel> _categoriesList = querySnapshot.docs
          .map((e) => CategoryModel.fromJson(e.data()))
          .toList();

      return _categoriesList;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<Orders>> getOrders(BuildContext context) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('userOrders')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('order')
          .get();

      List<Orders> ordersList =
          querySnapshot.docs.map((e) => Orders.fromJson(e.data())).toList();

      return ordersList;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }
  Future<List<UserOrders>> getUserList() async{
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore.collection('userOrders').get();
    return querySnapshot.docs.map((e)=> UserOrders.fromJson(e.data())).toList();
  }

  Future<List<Orders>> getPendingOrderList() async {
    try {
      var sellersSnapshot =
      await _firestore.collection('users').where('userRole', isEqualTo: 'Seller').get();
      print(sellersSnapshot.docs.length);
      List<Orders> pendingOrdersData = [];

      for (var sellerDoc in sellersSnapshot.docs) {
        String sellerId = sellerDoc['userId'];
        print(sellerId);
        QuerySnapshot<Map<String, dynamic>> ordersSnapshot = await _firestore
            .collection('userOrders')
            .doc(sellerId)
            .collection('order')
            .where('status', isEqualTo: 'Pending')
            .where('customerMobileNumber', isEqualTo: FirebaseAuth.instance.currentUser!.phoneNumber)
            .get();

        List<Orders> sellerPendingOrders = ordersSnapshot.docs
            .map((doc) => Orders.fromJson(doc.data()))
            .toList();

        pendingOrdersData.addAll(sellerPendingOrders);
      }

      print('Pending Orders Data: $pendingOrdersData');
      return pendingOrdersData;
    } catch (error) {
      print('Error fetching pending orders: $error');
      return []; // Return an empty list in case of an error
    }

  }

  Future<List<Orders>> getAcceptedOrderList() async {
    try {
      var sellersSnapshot =
      await _firestore.collection('users').where('userRole', isEqualTo: 'Seller').get();
      print(sellersSnapshot.docs.length);
      List<Orders> pendingOrdersData = [];

      for (var sellerDoc in sellersSnapshot.docs) {
        String sellerId = sellerDoc['userId'];
        print(sellerId);
        QuerySnapshot<Map<String, dynamic>> ordersSnapshot = await _firestore
            .collection('userOrders')
            .doc(sellerId)
            .collection('order')
            .where('status', isEqualTo: 'Accepted')
            .where('customerMobileNumber', isEqualTo: FirebaseAuth.instance.currentUser!.phoneNumber)
            .get();

        List<Orders> sellerPendingOrders = ordersSnapshot.docs
            .map((doc) => Orders.fromJson(doc.data()))
            .toList();

        pendingOrdersData.addAll(sellerPendingOrders);
      }

      print('Pending Orders Data: $pendingOrdersData');
      return pendingOrdersData;
    } catch (error) {
      print('Error fetching pending orders: $error');
      return []; // Return an empty list in case of an error
    }

  }

  Future<List<Orders>> getRejectedOrderList() async {
    try {
      var sellersSnapshot =
      await _firestore.collection('users').where('userRole', isEqualTo: 'Seller').get();
      print(sellersSnapshot.docs.length);
      List<Orders> pendingOrdersData = [];

      for (var sellerDoc in sellersSnapshot.docs) {
        String sellerId = sellerDoc['userId'];
        print(sellerId);
        QuerySnapshot<Map<String, dynamic>> ordersSnapshot = await _firestore
            .collection('userOrders')
            .doc(sellerId)
            .collection('order')
            .where('status', isEqualTo: 'Rejected')
            .where('customerMobileNumber', isEqualTo: FirebaseAuth.instance.currentUser!.phoneNumber)
            .get();

        List<Orders> sellerPendingOrders = ordersSnapshot.docs
            .map((doc) => Orders.fromJson(doc.data()))
            .toList();

        pendingOrdersData.addAll(sellerPendingOrders);
      }

      print('Pending Orders Data: $pendingOrdersData');
      return pendingOrdersData;
    } catch (error) {
      print('Error fetching pending orders: $error');
      return []; // Return an empty list in case of an error
    }
  }

  Future<void> updateOrderModel(Orders orderModel, String status) async {
    try {
      var sellersSnapshot =
      await _firestore.collection('users').where('userRole', isEqualTo: 'Seller').get();

      for (var sellerDoc in sellersSnapshot.docs) {
        String sellerId = sellerDoc['userId'];
        print(sellerId);
        
        print('Hi..');
        // var snapshot = await _firestore.collection('userOrders').doc(sellerId).collection('order').where('orderId', isEqualTo: orderModel.orderId).get();
        // await _firestore.collection('userOrders').doc(sellerId).collection('order').doc(orderModel.orderId).update({
        //   'status': status,
        // });

              await _firestore.collection('userOrders').doc(sellerId).collection('order').get().then((snapshot) {
            snapshot.docs.forEach((documentsnapshot) async {
              await _firestore.collection('userOrders').doc(sellerId).collection('order').doc(orderModel.orderId).update(
                  {
                    'status': status,
                  }
              );
            });
          });

      }


    } catch (error) {
      print('Error fetching pending orders: $error');
    }
  }

  Future<String> getFCMToken() async {
    String? fcmToken = await _firebaseMessaging.getToken();
    me.fcmToken = fcmToken!;
    return fcmToken!;
  }

  Future<String?> getBuyerFCMToken(String buyerMobileNumber) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(buyerMobileNumber)
        .get();
    if (snapshot.exists && snapshot.data() != null) {
      String? fcmToken = snapshot.data()!['fcmToken'] as String?;
      if (fcmToken != null) {
        return fcmToken;
      } else {
        print("FCM token not found for the buyer.");
        return null;
      }
    } else {
      print("Buyer document not found in Firestore.");
      return null;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
