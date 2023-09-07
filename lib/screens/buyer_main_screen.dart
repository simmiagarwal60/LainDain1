import 'package:flutter/material.dart';
import 'package:lain_dain/screens/buyer_orderScreen.dart';
import 'package:lain_dain/screens/buyer_orders.dart';
import 'package:lain_dain/screens/profile.dart';
import 'package:lain_dain/screens/profile_screen.dart';

class BuyerMainScreen extends StatefulWidget {
  const BuyerMainScreen({super.key});

  @override
  State<BuyerMainScreen> createState() => _BuyerMainScreenState();
}

class _BuyerMainScreenState extends State<BuyerMainScreen> {
  int myIndex = 0;
  List tabs = [BuyerOrder(), Profile()];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        return false;
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              myIndex = index;
            });
          },
          currentIndex: myIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color.fromARGB(255, 67, 160, 71).withOpacity(0.5),
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.dashboard,
                  color: Colors.white,
                ),
                label: 'Orders'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                label: 'Profile', ),
          ],
        ),
        body: tabs[myIndex],
      ),
    );
  }
}
