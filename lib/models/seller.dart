


import 'package:cloud_firestore/cloud_firestore.dart';

class Seller{
  late String sellerId;
  late  String aadhar;
  late  String pan;
  late  String first_name;
  late  String last_name;
  late  String business_name;
  late String address;


  Seller({
    required this.sellerId,
    required this.aadhar,
    required this.pan,
    required this.first_name,
    required this.last_name,
    required this.business_name,
    required this.address,

  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['sellerId']= sellerId;
    data['aadhar']= aadhar;
    data['pan'] =pan;
    data['first_name']= first_name;
    data['last_name']= last_name;
    data['business_name'] = business_name;
    data['address'] = address;

    return data;
  }
  Seller.fromJson(Map<String, dynamic> json){
    sellerId = json['sellerId'] ?? '';
    aadhar = json['aadhar'] ?? '';
    pan = json['pan'] ?? '';
    first_name = json['first_name'] ?? '';
    last_name = json['last_name'] ?? '';
    business_name = json['business_name'] ?? '';
    address = json['address'] ?? '';

  }

  static Seller fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Seller(
      sellerId: snapshot['sellerId'],
      aadhar: snapshot['aadhar'],
      pan: snapshot['pan'],
      first_name: snapshot['first_name'],
      last_name: snapshot['last_name'],
      business_name: snapshot['business_name'],
      address: snapshot['address'],

    );
  }
}