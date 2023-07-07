import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lain_dain/models/orders_model.dart';
import 'package:lain_dain/services/firebase_auth.dart';
import 'package:lain_dain/widget/button_widget.dart';

class SellerOrderHistory extends StatefulWidget {
  const SellerOrderHistory({super.key});

  @override
  State<SellerOrderHistory> createState() => _SellerOrderHistoryState();
}

class _SellerOrderHistoryState extends State<SellerOrderHistory> {
  //List<Orders> orders_list = [];

  @override
  void initState() {
    super.initState();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> loadOrders() {
    return FirebaseFirestore.instance.collection('userOrders').doc(FirebaseAuth.instance.currentUser!.uid).collection('order').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
        backgroundColor: const Color.fromARGB(255, 67, 160, 71),
      ),
      body: FutureBuilder(
        future: AuthService.instance.getOrders(context),
        builder: (context, AsyncSnapshot<List<Orders>> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data ==  null ) {
            return Center(child: Text('No orders found.'));
          }

          // orders_list = (snapshot.data as QuerySnapshot)
          //     .docs
          //     .map((e) => Orders.fromJson(
          //     e.data() as Map<String, dynamic>))
          //     .toList() ?? [];
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Orders order = snapshot.data![index];

              return Card(
                child: ExpansionTile(
                  collapsedShape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.green, width: 2.3),
                  ),
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.green, width: 2.3) ),
                  title: Text(order.customerMobileNumber, style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w400),),
                  children: <Widget>[
                    ListTile(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.orderId, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                          Text('Order status: ${order.status}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                          const SizedBox(
                            height: 12,
                          ),
                          order.status == "Cancelled" || order.status == "Pending"
                          ? ButtonWidget(text: "Cancel Order",
                              onClicked: (){
                            AuthService.instance.updateOrderModel(order, "Cancelled");
                            order.status = "Cancelled";
                            setState(() {

                            });
                              })
                              : SizedBox.fromSize(),
                          order.status == "Accepted"
                          ? ButtonWidget(text: "Accept order",
                              onClicked: (){
                                AuthService.instance.updateOrderModel(order, "Accepted");
                                order.status = "Accepted";
                                setState(() {});
                              })
                              : SizedBox.fromSize(),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

}
