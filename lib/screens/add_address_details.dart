import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lain_dain/screens/delivery_details.dart';

import '../models/pickup_address_model.dart';
import '../widget/button_widget.dart';

class AddAddressDetails extends StatefulWidget {
  const AddAddressDetails({super.key});

  @override
  State<AddAddressDetails> createState() => _AddAddressDetailsState();
}

class _AddAddressDetailsState extends State<AddAddressDetails> {
  String _fullName="";
  String _pincode="";
  String _state="";
  String _city="";
  String _houseNumber="";
  TextEditingController fullNameController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController houseNumberController = TextEditingController();

  void saveAddress(BuildContext context) async {
    String id = FirebaseFirestore.instance.collection('addresses').doc().id;
    final address = PickupAddress(id: id,fullName: fullNameController.text, city: cityController.text, state: stateController.text, pincode: pincodeController.text, houseNumber: houseNumberController.text);

    if (fullNameController.text.isEmpty ||
        pincodeController.text.isEmpty ||
        houseNumberController.text.isEmpty ||
        cityController.text.isEmpty ||
        stateController.text.isEmpty){
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please fill in all the fields.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;

    }
    try {
      // await FirebaseFirestore.instance.collection('addresses').add({
      //   'Full Name': address.fullName,
      //   'pincode': address.pincode,
      //   'HouseNumber': address.houseNumber,
      //   'city': address.city,
      //   'state': address.state,
      // });
      FirebaseFirestore.instance
          .collection('addresses')
          .doc(id)
          .set(address.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address saved successfully')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DeliveryDetails(savedAddress: address),
        ),
      );

          }
          catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save address')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
          height:48 ,
          margin: const EdgeInsets.all(40),
          child: ButtonWidget(text: "Add Address",
              onClicked: (){
            saveAddress(context);
              })
      ),
      appBar: AppBar(
        title: const Text("Add Delivery address"),
        backgroundColor: const Color.fromARGB(255, 67, 160, 71),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
        TextFormField(
          controller: fullNameController,
        decoration:  InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        labelText: 'Full Name',
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Field is Required';
          }
          return null;
        },
        onSaved: (value) {
          _fullName = value!;
        },
    ),
            const SizedBox(height: 10,),
            TextFormField(
              controller: pincodeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'Pincode',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Field is Required';
                }
                return null;
              },
              onSaved: (value) {
                _pincode = value!;
              },
            ),
            const SizedBox(height: 10,),
            TextFormField(
              controller: stateController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'State',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Field is Required';
                }
                return null;
              },
              onSaved: (value) {
                _state = value!;
              },
            ),
            const SizedBox(height: 10,),
            TextFormField(
              controller: cityController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'City',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Field is Required';
                }
                return null;
              },
              onSaved: (value) {
                _city = value!;
              },
            ),
            const SizedBox(height: 10,),
            TextFormField(
              controller: houseNumberController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'House No., Road name, Area, Colony',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Field is Required';
                }
                return null;
              },
              onSaved: (value) {
                _houseNumber = value!;
              },
            ),
          ],
        ),
      ),
    );
  }
}
