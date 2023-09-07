import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../widget/button_widget.dart';

class RazorpayScreen extends StatefulWidget {
  final String orderId;
  final String amount;
  final String businessName;
  const RazorpayScreen({super.key, required this.orderId, required this.amount, required this.businessName});

  @override
  State<RazorpayScreen> createState() => _RazorpayScreenState();
}

class _RazorpayScreenState extends State<RazorpayScreen> {
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        backgroundColor: const Color.fromARGB(255, 67, 160, 71),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Order ID: ${widget.orderId}', textAlign: TextAlign.start,style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 20),),
            SizedBox(height: 16),
            Text('Business Name: ${widget.businessName}',textAlign: TextAlign.start,style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 20)),
            SizedBox(height: 16),
            Text('Amount: ${widget.amount}',textAlign: TextAlign.start,style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 20)),
            SizedBox(height: 16),
            ButtonWidget(text: 'Pay now',
              onClicked: (){
                var options = {
                  'key': 'rzp_test_rHDmZUBxatGaK0',
                  'amount': (int.parse(widget.amount) * 100).toString(), //in the smallest currency sub-unit.
                  'name': 'Simran',
                  'description': 'Demo',
                  'timeout': 300, // in seconds
                  'prefill': {
                    'contact': '9906129144',
                    'email': 'simran07agarwal@gmail.com'
                  }
                };
                _razorpay.open(options);

              },)
          ],
        ),
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