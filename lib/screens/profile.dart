import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lain_dain/screens/delivery_details.dart';
import 'package:lain_dain/screens/phone.dart';
import 'package:lain_dain/screens/profile_screen.dart';

import '../models/pickup_address_model.dart';
import '../services/firebase_auth.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show a loading indicator while fetching the data
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                  'User not found'),
            ); // Handle if the user document doesn't exist
          }
          final data = snapshot.data?.data() as Map<String, dynamic>;
          return Scaffold(
            appBar: AppBar(
              title: Text('Profile'),
              backgroundColor: const Color.fromARGB(255, 67, 160, 71),
            ),
            body: Column(
              children: [
                Card(
                    child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                  },
                  child: ListTile(
                    title: Text('Your Account'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                )),
                data['userRole'] == 'Buyer' ? SizedBox.fromSize():
                Card(
                    child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeliveryDetails(
                                savedAddress: PickupAddress(
                                    id: '',
                                    fullName: '',
                                    pincode: '',
                                    houseNumber: '',
                                    city: '',
                                    state: ''))));
                  },
                  child: ListTile(
                    title: Text('Saved Addresses'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                )),
                Card(
                    child: InkWell(
                  onTap: () {
                    AuthService.instance.signOut();
                    //Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logging out')));
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => MyPhone()));
                  },
                  child: ListTile(
                    title: Text('Log out'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                ))
              ],
            ),
          );
        });
  }
}
