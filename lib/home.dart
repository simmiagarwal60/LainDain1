import 'dart:math';

import 'package:lain_dain/buyer-form.dart';
import 'package:lain_dain/models/pickup_address_model.dart';
import 'package:lain_dain/seller-form.dart';
import 'package:lain_dain/widget/button_widget.dart';
import 'package:flutter/material.dart';


// class Verhoeff {
//   static const List<List<int>> d = [
//     [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
//     [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
//     [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
//     [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
//     [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
//     [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
//     [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
//     [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
//     [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
//     [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
//   ];
//
//   static const List<List<int>> p = [
//     [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
//     [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
//     [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
//     [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
//     [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
//     [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
//     [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
//     [7, 0, 4, 6, 9, 1, 3, 2, 5, 8]
//   ];
//
//   static const int inv = 0;
//   static const int perm = 1;
//
//   static bool validate(String number) {
//     List<int> digits = number
//         .split('')
//         .map(int.parse)
//         .toList()
//         .reversed
//         .toList();
//
//     int checksum = 0;
//     for (int i = 0; i < digits.length; i++) {
//       checksum = d[checksum][p[(i + 1) % 8][digits[i]]];
//     }
//
//     return checksum == 0;
//   }
// }
class MyApp extends StatelessWidget {
  static const String title = 'LainDain';

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MainPage(),
      );
}

class MainPage extends StatefulWidget {
  //final String aadhaarNumber;
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _aadharController = TextEditingController();
  bool _isValid = false;
  PickupAddress pickupAddress = PickupAddress(id: '', fullName: '', pincode: '', houseNumber: '', city: '', state: '');

  @override
  void dispose() {
    _aadharController.dispose();
    super.dispose();
  }

  // void storeAadhaarNumber(String aadhaarNumber) async {
  //   //CollectionReference phoneNumberCollection = FirebaseFirestore.instance.collection('phone_numbers');
  //   String uid = FirebaseAuth.instance.currentUser!.uid;
  //   try {
  //     await APIs.createUser().set({'aadhaar_number': aadhaarNumber});
  //     print('Aadhaar number stored in Firebase successfully');
  //   } catch (e) {
  //     print('Error storing Aadhaar number: $e');
  //   }
  // }

  void _validateAadhaarNumber() {
    String aadhaar = _aadharController.text.trim();

    setState(() {
      _isValid = validateAadhaarNumber(aadhaar);
    });

    if (_isValid) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => FormScreen(aadharNumber: _aadharController.text)));
    } else {
      print("Invalid Aadhar!!!");
    }
  }

  bool validateAadhaarNumber(String aadhaarNumber) {
    // Aadhaar number regex pattern
    //String pattern = r'^[2-9]{1}[0-9]{3}\\s[0-9]{4}\\s[0-9]{4}$';
    String pattern = r'^\d{4}\s\d{4}\s\d{4}$';

    RegExp regex = RegExp(pattern);
    return regex.hasMatch(aadhaarNumber);
  }

  // void authenticatePhoneNumberWithAadhaar(String phoneNumber, String aadhaarNumber) async {
  //   // Construct the API endpoint URL
  //   String apiUrl = 'https://<YOUR_API_ENDPOINT>'; // Replace with your API endpoint URL
  //
  //   // Prepare the request body with the required parameters
  //   String transactionId = '<GENERATE_UNIQUE_TRANSACTION_ID>'; // Replace with your transaction ID
  //   String otp = '<USER_ENTERED_OTP>'; // Replace with the OTP entered by the user
  //   String demographicDetails = '<USER_ENTERED_DEMOGRAPHIC_DETAILS>'; // Replace with the demographic details entered by the user
  //
  //   Map<String, dynamic> requestBody = {
  //     'uid': aadhaarNumber,
  //     'mobile': phoneNumber,
  //     'txn': transactionId,
  //     'otp': otp,
  //     'details': demographicDetails,
  //   };
  //
  //   // Make the API call
  //   http.Response response = await http.post(
  //     Uri.parse(apiUrl),
  //     body: requestBody,
  //   );
  //
  //   // Parse the API response
  //   if (response.statusCode == 200) {
  //     // Authentication successful
  //     // Parse the response and handle accordingly
  //     // Example: Check the 'status' field to determine the authentication status
  //     // Example: String apiResponse = response.body;
  //   } else {
  //     // Error occurred
  //     // Handle the error response
  //     // Example: String errorMessage = response.body;
  //   }
  // }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text(MyApp.title),
        backgroundColor: const Color.fromARGB(255, 67, 160, 71),
        elevation: 50.0,
        /* leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Menu Icon',
          onPressed: () {

          },
        ),*/
        centerTitle: true,
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 67, 160, 71),
              ),
              child: Text('LainDain'),
            ),
            ListTile(
              title: const Text('My Profile'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("I am a",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 25,
            ),
            ButtonWidget(
              text: 'Seller',
              onClicked: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SizedBox(
                        height: 200,
                        child: AlertDialog(
                          title: const Text("Enter your Aadhar number"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          TextFormField(
                            controller: _aadharController,
                          decoration: const InputDecoration(
                          labelText: 'AADHAR NUMBER',
                            icon: Icon(Icons.payment),
                            iconColor: Color.fromARGB(255, 67, 160, 71),
                          ),
                          maxLength: 14,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Field is Required';
                            }

                            return null;
                          },
                        ),
                              const SizedBox(height: 16),
                              ButtonWidget(
                                  text: 'Submit',
                                  onClicked: () {
                                    _validateAadhaarNumber();
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>FormScreen(selectedAddress: pickupAddress)));
                                  })
                            ],
                          ),
                        ),
                      );
                    });
              },
            ),
            const SizedBox(height: 16),
            ButtonWidget(
              text: 'Buyer',
              onClicked: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BuyerFormScreen()),
                );
              },
            ),
          ],
        ),
      ));
}
