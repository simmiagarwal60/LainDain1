import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lain_dain/screens/phone.dart';
import 'package:lain_dain/screens/seller_main.dart';
import 'package:lain_dain/services/notification_services.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key}) : super(key: key);

  static String verify = "";

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  NotificationServices services = NotificationServices();
  TextEditingController countryController = TextEditingController();
  var phone = "";

  Future<void> _signInWithPhoneNumber(String phoneNumber) async {
    try {
      // Verify the phone number using FirebaseAuth
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: '', // Not needed for silent authentication
        smsCode: '', // Not needed for silent authentication
      );

      UserCredential authResult =
      await FirebaseAuth.instance.signInWithCredential(credential);

      // If the authentication is successful, navigate to the main orders screen.
      if (authResult.user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellerMainScreen(businessName: 'fndn'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      // Handle sign-in error here
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    countryController.text = "+91";
    super.initState();
    services.requestNotificationPermissions();
    services.firebaseInit(context);
    services.setupInteractMessage(context);
    services.getDeviceToken().then((value) {
      print("device token:");
      print(value);
    });
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> fetchUserDataStream(
      String phoneNumber) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(phoneNumber)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset(
              //   'assets/img1.png',
              //   width: 150,
              //   height: 150,
              // ),
              // SizedBox(
              //   height: 25,
              // ),
              const Text(
                "Lain Dain",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Enter your phone number",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                height: 55,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 40,
                      child: TextField(
                        controller: countryController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Text(
                      "|",
                      style: TextStyle(fontSize: 33, color: Colors.grey),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          onChanged: (value) {
                            phone = value;
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Phone",
                          ),
                        ))
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () async {
                      String phoneNum = countryController.text + phone;
                      _signInWithPhoneNumber(phoneNum);
                    //   await FirebaseAuth.instance.verifyPhoneNumber(
                    //     phoneNumber: phoneNum,
                    //     verificationCompleted:
                    //         (PhoneAuthCredential credential) async {
                    //       await FirebaseAuth.instance
                    //           .signInWithCredential(credential);
                    //       Navigator.of(context).pushReplacement(
                    //           MaterialPageRoute(
                    //               builder: (context) =>
                    //                   StreamBuilder<DocumentSnapshot>(
                    //                       stream: fetchUserDataStream(phoneNum),
                    //                       builder: (context, snapshot) {
                    //                         if (snapshot.connectionState ==
                    //                             ConnectionState.waiting) {
                    //                           return const Center(
                    //                               child:
                    //                               CircularProgressIndicator());
                    //                         }
                    //
                    //                         if (!snapshot.hasData ||
                    //                             !snapshot.data!.exists) {
                    //                           ScaffoldMessenger.of(context)
                    //                               .showSnackBar(SnackBar(
                    //                               content: const Text(
                    //                                   'User not found')));
                    //                           return const Text('');
                    //                         }
                    //                         final data = snapshot.data?.data()
                    //                         as Map<String, dynamic>;
                    //                         String userRole = data['userRole'];
                    //                         if (userRole == 'Seller') {
                    //                           return SellerMainScreen(
                    //                               businessName:
                    //                               data['businessName']);
                    //                         } else if (userRole == 'Buyer') {
                    //                           return const BuyerMainScreen();
                    //                         } else {
                    //                           // Invalid 'userRole', handle accordingly
                    //                           // For example, show an error message or redirect to a default screen
                    //                           return Center(
                    //                               child:
                    //                               Text('Invalid userRole'));
                    //                         }
                    //                       }))
                    //       );
                    //     },
                    //     verificationFailed: (FirebaseAuthException e) {},
                    //     codeSent: (String verificationId, int? resendToken) {
                    //     },
                    //     codeAutoRetrievalTimeout: (String verificationId) {},
                    //   );
                    //   //Navigator.pushNamed(context, 'verify');
                     },
                    child: const Text("Sign in")),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.black),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> MyPhone()));
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
