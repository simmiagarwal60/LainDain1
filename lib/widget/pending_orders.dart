import 'package:flutter/material.dart';
import 'package:lain_dain/screens/payment_page.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:lain_dain/services/HashService.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
import '../models/orders_model.dart';
import '../services/firebase_auth.dart';

class PendingOrders extends StatefulWidget {
  const PendingOrders({super.key});

  @override
  State<PendingOrders> createState() => _PendingOrdersState();
}

class _PendingOrdersState extends State<PendingOrders> implements PayUCheckoutProProtocol {
  late PayUCheckoutProFlutter _checkoutPro;

  @override
  void initState() {
    super.initState();
    _checkoutPro = PayUCheckoutProFlutter(this);
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
              child: new Text(content),
            ),
            actions: [okButton],
          );
        });
  }


  @override
  generateHash(Map response) {
    // Pass response param to your backend server
    // Backend will generate the hash which you need to pass to SDK
    // hashResponse: is the response which you get from your server
    Map hashResponse =  HashService.generateHash(response);
    //Map hashResponse =  {};
    _checkoutPro.hashGenerated(hash: hashResponse);
  }

  @override
  onPaymentSuccess(dynamic response) {
//Handle Success response
    showAlertDialog(context, "onPaymentSuccess", response.toString());
  }

  @override
  onPaymentFailure(dynamic response) {
//Handle Failure response
    showAlertDialog(context, "onPaymentFailure", response.toString());
  }

  @override
  onPaymentCancel(Map? response) {
//Handle Payment cancel response
    showAlertDialog(context, "onPaymentCancel", response.toString());
  }

  @override
  onError(Map? response) {
//Handle on error response
    showAlertDialog(context, "onError", response.toString());
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
                                      _checkoutPro.openCheckoutScreen(
                                        payUPaymentParams: PayUParams
                                            .createPayUPaymentParams(),
                                        payUCheckoutProConfig:
                                            PayUParams.createPayUConfigParams(),
                                      );
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
}
class PayUTestCredentials {
  static const merchantKey = "H2SXqA";//TODO: Add Merchant Key
  //Use your success and fail URL's.

  static const iosSurl = "https://payu.herokuapp.com/ios_success";//TODO: Add Success URL.
  static const iosFurl = "https://payu.herokuapp.com/ios_failure";//TODO Add Fail URL.
  static const androidSurl = "https://payu.herokuapp.com/success";//TODO: Add Success URL.
  static const androidFurl = "https://payu.herokuapp.com/failure";//TODO Add Fail URL.


  static const merchantAccessKey = "toqbpAR2U9uj9nkyTU8Xa1v1x2HSkgZT";//TODO: Add Merchant Access Key - Optional
  static const sodexoSourceId = ""; //TODO: Add sodexo Source Id - Optional
}

class PayUParams {
  static Map createPayUPaymentParams() {

    var siParams = {
      PayUSIParamsKeys.isFreeTrial: true,
      PayUSIParamsKeys.billingAmount: '1',              //Required
      PayUSIParamsKeys.billingInterval: 1,              //Required
      PayUSIParamsKeys.paymentStartDate: '2024-07-09',  //Required
      PayUSIParamsKeys.paymentEndDate: '2024-07-10',    //Required
      PayUSIParamsKeys.billingCycle: 'daily', //Can be any of 'daily','weekly','yearly','adhoc','once','monthly'
      PayUSIParamsKeys.remarks: 'Test SI transaction',
      PayUSIParamsKeys.billingCurrency: 'INR',
      PayUSIParamsKeys.billingLimit: 'ON', //ON, BEFORE, AFTER
      PayUSIParamsKeys.billingRule: 'MAX', //MAX, EXACT
    };

    var additionalParam = {
      PayUAdditionalParamKeys.udf1: "udf1",
      PayUAdditionalParamKeys.udf2: "udf2",
      PayUAdditionalParamKeys.udf3: "udf3",
      PayUAdditionalParamKeys.udf4: "udf4",
      PayUAdditionalParamKeys.udf5: "udf5",
      PayUAdditionalParamKeys.merchantAccessKey:
      PayUTestCredentials.merchantAccessKey,
      PayUAdditionalParamKeys.sourceId:PayUTestCredentials.sodexoSourceId,
    };


    var spitPaymentDetails =
    {
      "type": "absolute",
      "splitInfo": {
        PayUTestCredentials.merchantKey: {
          "aggregatorSubTxnId": "1234567540099887766650092", //unique for each transaction
          "aggregatorSubAmt": "1"
        },
        /* "qOoYIv": {
          "aggregatorSubTxnId": "12345678",
          "aggregatorSubAmt": "40"
       },*/
      }
    };


    var payUPaymentParams = {
      PayUPaymentParamKey.key: PayUTestCredentials.merchantKey,
      PayUPaymentParamKey.amount: "1",
      PayUPaymentParamKey.productInfo: "Info",
      PayUPaymentParamKey.firstName: "Abc",
      PayUPaymentParamKey.email: "test@gmail.com",
      PayUPaymentParamKey.phone: "9906129144",
      PayUPaymentParamKey.ios_surl: PayUTestCredentials.iosSurl,
      PayUPaymentParamKey.ios_furl: PayUTestCredentials.iosFurl,
      PayUPaymentParamKey.android_surl: PayUTestCredentials.androidSurl,
      PayUPaymentParamKey.android_furl: PayUTestCredentials.androidFurl,
      PayUPaymentParamKey.environment: "1", //0 => Production 1 => Test
      PayUPaymentParamKey.userCredential: null, //TODO: Pass user credential to fetch saved cards => A:B - Optional
      PayUPaymentParamKey.transactionId:
      DateTime.now().millisecondsSinceEpoch.toString(),
      PayUPaymentParamKey.additionalParam: additionalParam,
      PayUPaymentParamKey.enableNativeOTP: false,
      // PayUPaymentParamKey.splitPaymentDetails:json.encode(spitPaymentDetails),
      PayUPaymentParamKey.userToken:"", //TODO: Pass a unique token to fetch offers. - Optional
    };

    return payUPaymentParams;
  }
  static Map createPayUConfigParams() {
    var paymentModesOrder = [
      {"Wallets": "PHONEPE"},
      {"UPI": "TEZ"},
      {"Wallets": ""},
      {"EMI": ""},
      {"NetBanking": ""},
    ];

    var cartDetails = [
      {"GST": "5%"},
      {"Delivery Date": "25 Dec"},
      {"Status": "In Progress"}
    ];
    var enforcePaymentList = [
      {"payment_type": "CARD", "enforce_ibiboCode": "UTIBENCC"},
    ];

    var customNotes = [
      {
        "custom_note": "Its Common custom note for testing purpose",
        "custom_note_category": [PayUPaymentTypeKeys.emi,PayUPaymentTypeKeys.card]
      },
      {
        "custom_note": "Payment options custom note",
        "custom_note_category": null
      }
    ];

    var payUCheckoutProConfig = {
      PayUCheckoutProConfigKeys.primaryColor: "#4994EC",
      PayUCheckoutProConfigKeys.secondaryColor: "#FFFFFF",
      PayUCheckoutProConfigKeys.merchantName: "Simran Agarwal",
      PayUCheckoutProConfigKeys.merchantLogo: "logo",
      PayUCheckoutProConfigKeys.showExitConfirmationOnCheckoutScreen: true,
      PayUCheckoutProConfigKeys.showExitConfirmationOnPaymentScreen: true,
      PayUCheckoutProConfigKeys.cartDetails: cartDetails,
      PayUCheckoutProConfigKeys.paymentModesOrder: paymentModesOrder,
      PayUCheckoutProConfigKeys.merchantResponseTimeout: 30000,
      PayUCheckoutProConfigKeys.customNotes: customNotes,
      PayUCheckoutProConfigKeys.autoSelectOtp: false,
      // PayUCheckoutProConfigKeys.enforcePaymentList: enforcePaymentList,
      PayUCheckoutProConfigKeys.waitingTime: 30000,
      PayUCheckoutProConfigKeys.autoApprove: false,
      PayUCheckoutProConfigKeys.merchantSMSPermission: true,
      PayUCheckoutProConfigKeys.showCbToolbar: true,
    };
    return payUCheckoutProConfig;
  }
}



