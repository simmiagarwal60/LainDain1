import 'package:flutter/material.dart';
import '../models/orders_model.dart';
import '../services/firebase_auth.dart';
import '../widget/button_widget.dart';

class BuyerOrderScreen extends StatefulWidget {
  const BuyerOrderScreen({super.key});

  @override
  State<BuyerOrderScreen> createState() => _BuyerOrderScreenState();
}

class _BuyerOrderScreenState extends State<BuyerOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buyer Order History'),
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

          if (snapshot.data == null) {
            return Center(child: Text('No orders found.'));
          }

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
                      side: BorderSide(color: Colors.green, width: 2.3)),
                  title: Text(
                    order.customerMobileNumber,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w400),
                  ),
                  children: <Widget>[
                    ListTile(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderId,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Order status: ${order.status}',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          order.status == "Cancelled" ||
                                  order.status == "Pending"
                              ? ButtonWidget(
                                  text: "Cancel Order",
                                  onClicked: () {
                                    AuthService.instance
                                        .updateOrderModel(order, "Cancelled");
                                    order.status = "Cancelled";
                                    setState(() {});
                                  })
                              : SizedBox.fromSize(),
                          order.status == "Accepted"
                              ? ButtonWidget(
                                  text: "Accept order",
                                  onClicked: () {
                                    AuthService.instance
                                        .updateOrderModel(order, "Accepted");
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
