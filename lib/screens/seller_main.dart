import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lain_dain/screens/buyer_orders.dart';
import 'package:lain_dain/screens/order_screen.dart';
import 'package:lain_dain/screens/profile.dart';
import 'package:lain_dain/screens/profile_screen.dart';
import 'package:lain_dain/screens/seller_orderHistory.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lain_dain/services/firebase_auth.dart';

class SellerMainScreen extends StatefulWidget {
  final String businessName;
  const SellerMainScreen({super.key, required this.businessName});

  @override
  State<SellerMainScreen> createState() => _SellerMainScreenState();
}

class _SellerMainScreenState extends State<SellerMainScreen> {
  int myIndex =0;
  String _businessName = "";
  List tabs=[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _businessName = widget.businessName;
    tabs = [
      OrderScreeen(businessName: _businessName),
      SellerOrderHistory(),
      Profile() ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        return false;
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index){
            setState(() {
              myIndex = index;
            });

          },
          currentIndex: myIndex,
          type: BottomNavigationBarType.fixed,
           backgroundColor: Color.fromARGB(255, 67, 160, 71).withOpacity(0.5),
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_rounded,color: Colors.white,),
            label: 'New Order',),
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard, color: Colors.white,),
                label: 'Orders'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person, color: Colors.white,),
                label: 'Profile'),

          ],
        ),
        body: tabs[myIndex],
      ),
    );
  }
}
