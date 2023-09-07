import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../models/orders_model.dart';
import '../services/firebase_auth.dart';

class PendingOrdersRP extends StatefulWidget {
  const PendingOrdersRP({super.key});

  @override
  State<PendingOrdersRP> createState() => _PendingOrdersRPState();
}

class _PendingOrdersRPState extends State<PendingOrdersRP> {
  late var _razorpay = Razorpay();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    print('Payment done');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print('payment failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }

  showAlertDialog(BuildContext context, String title, String content) {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(content),
            ),
            actions: [okButton],
          );
        });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Orders>>(
        future: AuthService.instance.getPendingOrderList(),
        builder: (context, AsyncSnapshot<List<Orders>> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.black),);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null) {
            return Center(child: Text('No orders found.',  style: TextStyle(color: Colors.black)));
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
                        Text(
                          'Order Id: ${order.orderId}',
                          style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Mobile number: ${order.customerMobileNumber}',
                          style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Order status: ${order.status}',
                          style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                AuthService.instance
                                    .updateOrderModel(order, "Rejected");
                                order.status = "Rejected";
                                setState(() {});
                              },
                              child: Text("Cancel Order"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color.fromARGB(255, 67, 160, 71),
                                shape: const StadiumBorder(),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Order Summary'),
                                    content: Column(
                                      children: [
                                        Text(
                                          'Order ID: ${order.orderId}',
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                              fontSize: 20),
                                        ),
                                        SizedBox(height: 16),
                                        Text('Business Name: ${order.businessName}',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                                fontSize: 20)),
                                        SizedBox(height: 16),
                                        Text('Amount: ${order.orderValue}',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                                fontSize: 20)),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          var options = {
                                            'key': 'rzp_test_rHDmZUBxatGaK0',
                                            'amount': (int.parse(order.orderValue) * 100).toString(), //in the smallest currency sub-unit.
                                            'name': order.customerMobileNumber,
                                            'description': 'Demo',
                                            'timeout': 300, // in seconds
                                            'prefill': {
                                              'contact': order.customerMobileNumber,
                                              'email': 'simran07agarwal@gmail.com'
                                            }
                                          };
                                          _razorpay.open(options);
                                          Navigator.pop(
                                              context); // Pop CreateOrderScreen
                                        },
                                        child: Text('PROCEED TO PAYMENT'),
                                      ),
                                    ],
                                  ),
                                );
                                AuthService.instance
                                    .updateOrderModel(order, "Accepted");
                                order.status = "Accepted";
                                setState(() {});
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => PaymentScreen(
                                //             orderId: order.orderId,
                                //             amount: order.orderValue,
                                //             businessName: order.businessName)));
                              },
                              child: Text("Accept Order"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color.fromARGB(255, 67, 160, 71),
                                shape: const StadiumBorder(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _razorpay.clear();
  }
}
