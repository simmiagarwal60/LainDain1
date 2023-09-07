import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lain_dain/screens/add_address_details.dart';
import 'package:lain_dain/screens/seller-form.dart';

import '../models/pickup_address_model.dart';
import '../widget/button_widget.dart';

class DeliveryDetails extends StatefulWidget {
  final PickupAddress savedAddress;

  // final String fullName;
  // final String state;
  // final String city;
  // final String pincode;
  // final String houseNumber;
  const DeliveryDetails({super.key, required this.savedAddress});

  @override
  State<DeliveryDetails> createState() => _DeliveryDetailsState();
}

class _DeliveryDetailsState extends State<DeliveryDetails> {
  List<PickupAddress> addresses = [];

  @override
  void initState() {
    super.initState();
    //fetchAddresses();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> fetchAddresses() {
    return FirebaseFirestore.instance
        .collection('sellerAddresses')
        .doc(FirebaseAuth.instance.currentUser!.uid).collection('address').snapshots();
  }

  void printname(String name) {
    print(name);
  }

  // void fetchAddresses() async {
  //   try {
  //     Stream<QuerySnapshot<Map<String, dynamic>>> = FirebaseFirestore.instance.collection('addresses').snapshots();
  //     QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('addresses').get();
  //     print(snapshot.metadata);
  //     List<PickupAddress> loadedAddresses = [];
  //
  //     if (snapshot != null && snapshot.docs.isNotEmpty){
  //       loadedAddresses = snapshot.docs
  //           .map((doc) => PickupAddress.fromJson(doc.data() as Map<String, dynamic>))
  //           .toList();
  //     }
  //
  //
  //     //   for (var doc in snapshot) {
  //     //   final data = doc.data();
  //     //   final address = PickupAddress(
  //     //     fullName: data['fullName'],
  //     //     pincode: data['pincode'],
  //     //     city: data['city'],
  //     //     state: data['state'],
  //     //     houseNumber: data['houseNumber'],
  //     //   );
  //     //   loadedAddresses.add(address);
  //     // }
  //
  //     setState(() {
  //       addresses = loadedAddresses;
  //
  //     });
  //   } catch (error) {
  //     print('Failed to fetch addresses: $error');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
          height: 48,
          margin: const EdgeInsets.all(40),
          child: ButtonWidget(
              text: "Add new Address",
              onClicked: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddAddressDetails()));
              })),
      appBar: AppBar(
        title: const Text("Delivery Details"),
        backgroundColor: const Color.fromARGB(255, 67, 160, 71),
      ),
      body: SafeArea(
        child: StreamBuilder(
            stream: fetchAddresses(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: Text("Loading"),
                  );
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.active:
                case ConnectionState.done:
                  //final data = snapshot.data?.docs;
                  addresses = (snapshot.data as QuerySnapshot)
                          .docs
                          .map((e) => PickupAddress.fromJson(
                              e.data() as Map<String, dynamic>))
                          .toList() ?? [];
                  if (addresses.isNotEmpty) {
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 20),
                      shrinkWrap: true,
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        print('name: ${address.fullName}');
                        return Card(
                          child: ListTile(
                            title: Text(
                              address.fullName,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400),
                            ),
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${address.houseNumber}, ${address.city}, ${address.state} - ${address.pincode}',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FormScreen(selectedAddress: address),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    return Container();
                  }
              }
            }),

        //     if (snapshot.hasError) {
        //       return Center(child: Text('Error retrieving addresses'));
        //     }
        //
        //     return Center(child: CircularProgressIndicator());
        //   },
        // ),
      ),
    );
    // floatingActionButton: FloatingActionButton(
    //   onPressed: () {
    //     saveAddressList(addressList);
    //     Navigator.pop(context, addressList);
    //   },
    //   child: Icon(Icons.save),
    // ),
  }
}
