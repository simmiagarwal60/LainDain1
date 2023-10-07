import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lain_dain/screens/profile.dart';
import 'buyer_main_screen.dart';

class BuyerLandingPage extends StatefulWidget {
  const BuyerLandingPage({super.key});

  @override
  State<BuyerLandingPage> createState() => _BuyerLandingPageState();
}

class _BuyerLandingPageState extends State<BuyerLandingPage> {
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
            return Center(child: CircularProgressIndicator()); // Show a loading indicator while fetching the data
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text(
                'User not found'); // Handle if the user document doesn't exist
          }
          final data = snapshot.data?.data() as Map<String, dynamic>;

          return Scaffold(
            appBar: AppBar(
              title: Text('Hi ${data['fullName']}'),
              backgroundColor: const Color.fromARGB(255, 67, 160, 71),
              actions: [Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile()));
                        },
                        child: Icon(Icons.person)),
                  )),],
            ),
            // floatingActionButton: Padding(
            //   padding: const EdgeInsets.only(bottom: 10),
            //   child: FloatingActionButton.extended(
            //     label: Text('View orders'),
            //     onPressed: (){
            //       Navigator.push(context, MaterialPageRoute(builder: (context)=> BuyerMainScreen()));
            //     },
            //     icon: Icon(Icons.add),
            //     backgroundColor: const Color.fromARGB(255, 67, 160, 71),
            //   ),
            //),
            body: Container(
              decoration: BoxDecoration(
                //gradient: LinearGradient(colors: [Colors.grey, Colors.grey])
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 30),
                  child: Column(
                    children: [
                      Container(
                        height: 300,
                        child: Image.network('https://previews.123rf.com/images/unitonevector/unitonevector1909/unitonevector190901138/130455281-banner-mobile-banking-in-phone-cartoon-flat-financial-transactions-via-mobile-phones-men.jpg',fit: BoxFit.fill,) ,
                      ),
                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text('Lain Dain', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),),
                            SizedBox(height: 20,),
                            Text("Unlock Trust, Empower Commerce \n Your Safest Path to Secure Transactions!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black54), textAlign: TextAlign.center,),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });


  }
}
