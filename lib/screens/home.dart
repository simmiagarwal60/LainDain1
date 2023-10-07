import 'package:lain_dain/screens/buyer-form.dart';
import 'package:lain_dain/models/pickup_address_model.dart';
import 'package:lain_dain/screens/seller-form.dart';
import 'package:lain_dain/widget/button_widget.dart';
import 'package:flutter/material.dart';

import '../services/firebase_auth.dart';


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
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isValid = false;
  bool isSeller = false;
  bool isBuyer = false;
  bool isClicked = false;
  PickupAddress pickupAddress = PickupAddress(id: '', fullName: '', pincode: '', houseNumber: '', city: '', state: '');




  bool validateAadhaarNumber(String aadhaarNumber) {
    // Aadhaar number regex pattern
    //String pattern = r'^[2-9]{1}[0-9]{3}\\s[0-9]{4}\\s[0-9]{4}$';
    String pattern = r'^\d{4}\s\d{4}\s\d{4}$';

    RegExp regex = RegExp(pattern);
    return regex.hasMatch(aadhaarNumber);
  }


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
            const Text("Which one are you?",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: (){
                        setState(() {
                          isSeller = true;
                          isBuyer = false;
                        });
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: isSeller ? BorderSide(
                            color: Colors.green,
                            width: 2.0,
                          ): BorderSide(color: Colors.white,
                            width: 0,),
                        ),
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(100)
                          ),
                          child: Center(
                            child: Image.network('https://cdn-icons-png.flaticon.com/128/506/506185.png', scale: 2,)
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Seller', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                  ],
                ),

                SizedBox(width: 10,),
                Column(
                  children: [
                    InkWell(
                      onTap: (){
                        setState(() {
                          isBuyer = true;
                          isSeller = false;
                        });
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: isBuyer ? BorderSide(
                            color: Colors.green,
                            width: 2.0,
                          ): BorderSide(color: Colors.white,
                            width: 0,),

                        ),
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(100)
                          ),
                          child: Center(
                            child: Image.network('https://cdn-icons-png.flaticon.com/128/5466/5466062.png', scale: 2,)
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Buyer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                  ],
                ),
              ],
            ),
            SizedBox(height: 70,),
            ButtonWidget(text: 'NEXT', onClicked: (){
              if(isSeller){
                AuthService.instance.updateUserRole("Seller");
                Navigator.push(context, MaterialPageRoute(builder: (context)=>FormScreen(selectedAddress: pickupAddress)));
              }
              else if(isBuyer){
                // AuthService().saveUserDetailsToFirestore(
                //     FirebaseAuth.instance.currentUser!.phoneNumber!,
                //     FirebaseAuth.instance.currentUser!.uid);
                AuthService.instance.updateUserRole("Buyer");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BuyerFormScreen()),
                );
              }
            })
            // ButtonWidget(
            //   text: 'Seller',
            //   onClicked: () {
            //     AuthService.instance.updateUserRole("Seller");
            //     Navigator.push(context, MaterialPageRoute(builder: (context)=>FormScreen(selectedAddress: pickupAddress)));
            //   },
            // ),
            // const SizedBox(height: 16),
            // ButtonWidget(
            //   text: 'Buyer',
            //   onClicked: () {
            //     AuthService().saveUserDetailsToFirestore(
            //         FirebaseAuth.instance.currentUser!.phoneNumber!,
            //         FirebaseAuth.instance.currentUser!.uid);
            //     AuthService.instance.updateUserRole("Buyer");
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const BuyerFormScreen()),
                //);
            //   },
            // ),
          ],
        ),
      ));
}
