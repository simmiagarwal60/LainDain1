import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lain_dain/services/firebase_auth.dart';
import 'package:lain_dain/services/notification_services.dart';
import 'package:lain_dain/screens/verify.dart';

class MyPhone extends StatefulWidget {
  const MyPhone({Key? key}) : super(key: key);

  static String verify = "";

  @override
  State<MyPhone> createState() => _MyPhoneState();
}

class _MyPhoneState extends State<MyPhone> {
  NotificationServices services = NotificationServices();
  TextEditingController countryController = TextEditingController();
  var phone = "";

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
    if(FirebaseAuth.instance.currentUser != null){
      AuthService.instance.handleAuth();
    }

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
      appBar: AppBar(
        title: const Text("LainDain"),
        backgroundColor: const Color.fromARGB(255, 67, 160, 71),
      ),
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
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Please enter your phone number to verify your account",
                style: TextStyle(
                  fontSize: 18,
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
                      await FirebaseAuth.instance.verifyPhoneNumber(
                        phoneNumber: phoneNum,
                        verificationCompleted:
                            (PhoneAuthCredential credential){
                        },
                        verificationFailed: (FirebaseAuthException e) {},
                        codeSent: (String verificationId, int? resendToken) {
                          MyPhone.verify = verificationId;
                          //storePhoneNumber(phone);
                          //Navigator.pushNamed(context, 'verify');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyVerify()));
                        },
                        codeAutoRetrievalTimeout: (String verificationId) {},
                      );
                      //Navigator.pushNamed(context, 'verify');
                    },
                    child: const Text("Send Verification code")),
              ),
              // Row(
              //   mainAxisSize: MainAxisSize.min,
              //   children: [
              //     Text(
              //     "Already have an account?",
              //     style: TextStyle(color: Colors.black),
              //     ),
              //     TextButton(
              //         onPressed: () {
              //           // Navigator.pushNamedAndRemoveUntil(
              //           //   context,
              //           //   'phone',
              //           //       (route) => false,
              //           // );
              //           Navigator.push(context, MaterialPageRoute(builder: (context)=> SigninPage()));
              //         },
              //         child: const Text(
              //           "Sign in",
              //           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              //         ))
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }
}
