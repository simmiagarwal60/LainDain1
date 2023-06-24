import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lain_dain/models/buyer.dart';


class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // String uid = FirebaseAuth.instance.currentUser!.uid;
  static User get user => auth.currentUser!;

  // static DocumentReference<Map<String, dynamic>> createUser() {
  //   return FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
  // }

  // static Future<void> createSeller() async {
  //   final seller = Seller(sellerId: user.uid, aadhar: '', pan: '', first_name: user.displayName.toString(), last_name: '', business_name: '', address: '');
  //
  //   return await firestore
  //       .collection('seller')
  //       .doc(user.uid)
  //       .set(seller.toJson());
  // }
  static Future<String> createSeller(sellerId, aadhar, pan, firstName, lastName,
      businessName, address) async {
    String res = "";
    try {
      await firestore.collection('seller').doc(user.uid).set({
        'seller id': sellerId,
        'aaadhar': aadhar,
        'pan': pan,
        'first_name': firstName,
        'last_name': lastName,
        'business_name': businessName,
        'address': address,
      });

      res = "success";
    } catch (e) {}
    return res;
  }

  static Future<void> createBuyer() async {
    final buyer = Buyer(
        full_name: '',
        email: user.email.toString(),
        phoneNumber: user.phoneNumber.toString(),
        address: '',
        pincode: '');
    return await firestore
        .collection('buyer')
        .doc(user.uid)
        .set(buyer.toJson());
  }
}
