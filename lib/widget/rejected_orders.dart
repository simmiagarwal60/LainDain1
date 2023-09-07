import 'package:flutter/material.dart';

import '../models/orders_model.dart';
import '../services/firebase_auth.dart';

class RejectedOrders extends StatefulWidget {
  const RejectedOrders({super.key});

  @override
  State<RejectedOrders> createState() => _RejectedOrdersState();
}

class _RejectedOrdersState extends State<RejectedOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: AuthService.instance.getRejectedOrderList(),
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
                  child: ListTile(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Id: ${order.orderId}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                        Text('Mobile number: ${order.customerMobileNumber}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                        Text('Order status: ${order.status}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                      ],
                    ),
                  )
              );
            },
          );
        },
      ),
    );
  }
}
