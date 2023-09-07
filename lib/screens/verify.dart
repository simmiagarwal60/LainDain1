import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lain_dain/screens/home.dart';
import 'package:lain_dain/screens/phone.dart';
import 'package:lain_dain/screens/seller_main.dart';
import 'package:lain_dain/services/firebase_auth.dart';
import 'package:pinput/pinput.dart';

import 'buyer_main_screen.dart';

class MyVerify extends StatefulWidget {
  const MyVerify({Key? key}) : super(key: key);

  @override
  State<MyVerify> createState() => _MyVerifyState();
}

class _MyVerifyState extends State<MyVerify> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final ValueNotifier<bool> dataLoadedNotifier = ValueNotifier<bool>(false);

  static Stream<DocumentSnapshot<Map<String, dynamic>>> fetchUserDataStream(
      String phoneNumber) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(phoneNumber)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    var code = "";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        elevation: 0,
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
                "LainDain",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Please enter the verification code we've sent you",
                style: TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              Pinput(
                length: 6,
                // defaultPinTheme: defaultPinTheme,
                // focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,

                showCursor: true,
                onChanged: (value) {
                  code = value;
                },
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
                      try {
                        PhoneAuthCredential credential =
                            PhoneAuthProvider.credential(
                                verificationId: MyPhone.verify, smsCode: code);

                        // Sign the user in (or link) with the credential
                        UserCredential userCredential =
                            await auth.signInWithCredential(credential);
                        //if (!context.mounted) return;
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => StreamBuilder<
                                      DocumentSnapshot<Map<String, dynamic>>>(
                                      stream: fetchUserDataStream(
                                          userCredential.user!.phoneNumber!),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }

                                        if((snapshot.hasData || snapshot.data!.exists) && !dataLoadedNotifier.value){
                                          final data = snapshot.data?.data() ;
                                          String userRole = data?['userRole'] ?? '' ;
                                          if (userRole == 'Seller') {
                                            return SellerMainScreen(
                                                businessName:
                                                data?['businessName'] ?? '');
                                          } else if (userRole == 'Buyer') {
                                            return const BuyerMainScreen();
                                          }
                                        }
                                        // else{
                                        //   print('hello');
                                        //   AuthService().saveUserDetailsToFirestore(
                                        //       userCredential.user!.phoneNumber!,
                                        //       userCredential.user!.uid);
                                        //   return const MyApp();
                                        // }
                                        if (!dataLoadedNotifier.value){
                                          // Save user details to Firestore only once
                                          AuthService().saveUserDetailsToFirestore(
                                              userCredential.user!.phoneNumber!,
                                              userCredential.user!.uid);
                                          dataLoadedNotifier.value = true;
                                        }
                                        print('hey');

                                        return const MyApp();


                                      },

                                  ),
                              ));
                        // else {
                        //   await AuthService().saveUserDetailsToFirestore(
                        //       userCredential.user!.phoneNumber!,
                        //       userCredential.user!.uid);
                        //   Navigator.push(context,
                        //       MaterialPageRoute(builder: (context) => MyApp()));
                        // }
                        //await AuthService().saveUserDetailsToFirestore(userCredential.user!.phoneNumber!, userCredential.user!.uid);
                        // Navigator.pushNamedAndRemoveUntil(
                        //     context, "home", (route) => false);

                        //Navigator.push(context, MaterialPageRoute(builder: (context)=>MyApp()));
                      } catch (e) {
                        print("Wrong otp");
                      }
                    },
                    child: const Text("Verify Phone Number")),
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        // Navigator.pushNamedAndRemoveUntil(
                        //   context,
                        //   'phone',
                        //   (route) => false,
                        // );
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => MyPhone()));
                      },
                      child: const Text(
                        "Edit Phone Number ?",
                        style: TextStyle(color: Colors.black),
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
