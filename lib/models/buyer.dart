
import 'package:cloud_firestore/cloud_firestore.dart';

class Buyer{
  late String buyerId;
  late  String full_name;
  late  String email;
  late  String phoneNumber;
  late  String address;
  late  String pincode;



  Buyer({
    required this.buyerId,
    required this.full_name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.pincode,


  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['buyerId']= buyerId;
    data['full_name']= full_name;
    data['email'] =email;
    data['phoneNumber']= phoneNumber;
    data['address']= address;
    data['pincode'] = pincode;
    data['address'] = address;

    return data;
  }
  Buyer.fromJson(Map<String, dynamic> json){
    buyerId = json['buyerId'] ?? '';
    full_name = json['full_name'] ?? '';
    email = json['email'] ?? '';
    phoneNumber = json['phoneNumber'] ?? '';
    address = json['address'] ?? '';
    pincode = json['pincode'] ?? '';


  }

  static Buyer fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Buyer(
      buyerId: snapshot['buyerId'],
      full_name: snapshot['full_name'],
      email: snapshot['email'],
      phoneNumber: snapshot['phoneNumber'],
      pincode: snapshot['pincode'],
      address: snapshot['address'],

    );
  }
}