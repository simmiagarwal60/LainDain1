import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lain_dain/screens/order_screen.dart';
import 'package:lain_dain/screens/profile.dart';
import 'package:lain_dain/screens/seller_landing_page.dart';
import 'package:lain_dain/screens/seller_orderHistory.dart';

class SellerMainScreen extends StatefulWidget {
  final String businessName;

  const SellerMainScreen({super.key, required this.businessName});

  @override
  State<SellerMainScreen> createState() => _SellerMainScreenState();
}

class _SellerMainScreenState extends State<SellerMainScreen>{
  int myIndex = 0;
  String _businessName = "";
  List tabs = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _businessName = widget.businessName;
    tabs = [
      LandingPage(businessName: _businessName),
      SellerOrderHistory(),
      Profile() ];
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child:
        Scaffold(
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
                        icon: Icon(Icons.home,color: Colors.white,),
                        label: 'Home',),
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
        // CupertinoTabScaffold(
        //     tabBar: CupertinoTabBar(
        //       backgroundColor: Color.fromARGB(255, 67, 160, 71).withOpacity(
        //           0.5),
        //       items: [
        //       BottomNavigationBarItem(
        //               icon: Icon(Icons.home,color: Colors.white,),
        //               label: 'Home',),
        //             BottomNavigationBarItem(
        //                 icon: Icon(Icons.dashboard, color: Colors.white,),
        //                 label: 'Orders'),
        //             BottomNavigationBarItem(
        //                 icon: Icon(Icons.person, color: Colors.white,),
        //                 label: 'Profile'),
        //       ],
        //     ),
        //     tabBuilder: (context, index) {
        //       switch (index) {
        //         case 0:
        //           return CupertinoTabView(
        //             builder: (context) {
        //               return CupertinoPageScaffold(
        //                   child: LandingPage(businessName: _businessName));
        //             },
        //           );
        //         case 1:
        //           return CupertinoTabView(
        //             builder: (context) {
        //               return CupertinoPageScaffold(
        //                   child: SellerOrderHistory());
        //             },
        //           );
        //         case 2:
        //           return CupertinoTabView(
        //             builder: (context) {
        //               return CupertinoPageScaffold(
        //                   child: Profile());
        //             },
        //           );
        //       }
        //       return Container();
        //     })

    );
  }
}
