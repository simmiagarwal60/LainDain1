import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:lain_dain/models/category_model.dart';
import 'package:lain_dain/models/orders_model.dart';
import 'package:lain_dain/services/firebase_auth.dart';
import 'package:lain_dain/services/notification_services.dart';
import 'package:lain_dain/widget/button_widget.dart';
import 'package:lain_dain/screens/order_details.dart';
import 'package:lain_dain/models/notification_model.dart' as notify;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:http/http.dart' as http;

class OrderScreeen extends StatefulWidget {
  final String businessName;
  //final String pickupAddress;

  const OrderScreeen(
      {Key? key, required this.businessName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OrderScreenState();
  }
}

class OrderScreenState extends State<OrderScreeen> {
  String userName = 'simran07agarwal@gmail.com';
  String password = 'Simran@2300';
  String adminEmail = 'samairasharmaa20@gmail.com';
  String _orderValue = '';
  String _orderWeightage = "";
  String _mobileNumber = "";
  String _pkupAddr = "";
  String _delAddr = "";
  String defaultvalue = '';
  String countryCode = '+91';

  String? screenshotUrl;
  String? orderid;

  TextEditingController pickupAddressController = TextEditingController();
  List<CategoryModel> _categoriesList = [];

  // List list = [
  //   {"title": "FASHION", "value": "FASHION"},
  //   {"title": "CLOTHES", "value": "CLOTHES"},
  //   {"title": "MOBILE PHONES", "value": "MOBILE PHONES"},
  //   {"title": "WATCHES", "value": "WATCHES"},
  //   {"title": "LAPTOPS", "value": "LAPTOPS"}
  // ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  final AuthService authService = AuthService();
  final NotificationServices notificationServices = NotificationServices();

  Future sendEmail(String category, String amount, String weightage,
      String pkupAddress, String dlvryAddress, String mobileNumber) async {
    final String serviceId = 'service_9jkbopj';
    final String templateId = 'template_jahjsq5';
    final String userId = 'UfmxQymLjIgb2Vjv2';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'user_name': 'Lain Dain',
            'user_email': userName,
            'user_subject': 'New Order Created',
            'user_message':
                'A new order has been created\nCategory: ${category}\nAmount: ${amount}\nWightage: ${weightage}\nPickup Address: ${pkupAddress}\nDelivery Address: ${dlvryAddress}\nMobile Number: ${mobileNumber}'
          }
        }));
    print(response.body);
  }

  void getCategoryList() async {
    _categoriesList = await AuthService().getCategories();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategoryList();
    //pickupAddressController.text = widget.pickupAddress;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pickupAddressController.clear();
  }


  void storeNotification(notify.Notification notification) async {
    CollectionReference notificationsRef =
        FirebaseFirestore.instance.collection('notifications');
    await notificationsRef.add(notification.toMap());
  }

  void _createOrder() async {
    orderid = FirebaseAuth.instance.currentUser!.uid;

    if (_orderValue.isEmpty ||
        defaultvalue.isEmpty ||
        _orderWeightage.isEmpty ||
        _mobileNumber.isEmpty ||
        _delAddr.isEmpty ||
        _pkupAddr.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please fill in all the fields.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Save order details and image to Firestore
    try {
      AuthService.instance.saveOrderDetailsToFirestore(
          "Pending",
          widget.businessName,
          defaultvalue,
          _orderValue,
          _orderWeightage,
          '$countryCode$_mobileNumber',
          _pkupAddr,
          _delAddr);
      //sendEmail(defaultvalue, _orderValue, _orderWeightage, _pkupAddr, _delAddr, _mobileNumber);


      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Order created successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Pop CreateOrderScreen
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to create order. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildoc() {
    return Row(
      children: [
        const Icon(
          Icons.shopping_cart,
          color: Color.fromARGB(255, 67, 160, 71),
        ),
        const SizedBox(
          width: 13,
        ),
        SizedBox(
          width: 298,
          child: InputDecorator(
            decoration: const InputDecoration(
              //border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
              contentPadding: EdgeInsets.all(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isDense: true,
                value: defaultvalue,
                isExpanded: true,
                menuMaxHeight: 350,
                items: [
                  const DropdownMenuItem(
                      value: "",
                      child: Text(
                        "ORDER CATEGORY",
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                        textAlign: TextAlign.start,
                      )),
                  ..._categoriesList.map<DropdownMenuItem<String>>((data) {
                    return DropdownMenuItem(
                      value: data.name,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(data.image),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Text(data.name,
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 16))
                        ],
                      ),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  print('Selected value $value');
                  setState(() {
                    defaultvalue = value!;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildov() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'ORDER VALUE',
        icon: Icon(Icons.shopping_cart_sharp),
        iconColor: Color.fromARGB(255, 67, 160, 71),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onChanged: (value) {
        print('Selected value $value');
        setState(() {
          _orderValue = (value);
        });
      },
      onSaved: (value) {
        _orderValue = (value!);
      },
    );
  }

  Widget _buildow() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'ORDER WEIGHTAGE',
        icon: Icon(Icons.anchor_outlined),
        iconColor: Color.fromARGB(255, 67, 160, 71),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onChanged: (value) {
        print('Selected value $value');
        setState(() {
          _orderWeightage = value;
        });
      },
      onSaved: (value) {
        _orderWeightage = value!;
      },
    );
  }

  Widget _buildMobileNumber() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'CUSTOMER MOBILE NUMBER',
        icon: Icon(Icons.phone),
        iconColor: Color.fromARGB(255, 67, 160, 71),
      ),
      //maxLength: 10,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onChanged: (value) {
        print('Selected value $value');
        setState(() {
          _mobileNumber = value;
        });
      },
      onSaved: (value) {
        _mobileNumber = value!;
      },
    );
  }

  Widget _buildPkupAddr() {
    return TextFormField(
      controller: pickupAddressController,
      decoration: const InputDecoration(
        labelText: 'PICK-UP ADDRESS',
        icon: Icon(Icons.location_city),
        iconColor: Color.fromARGB(255, 67, 160, 71),
      ),
      keyboardType: TextInputType.url,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onChanged: (value) {
        print('Selected value $value');
        setState(() {
          _pkupAddr = value;
        });
      },
      onSaved: (value) {
        _pkupAddr = value!;
      },
    );
  }

  Widget _buildDelAddr() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'DELIVERY ADDRESS',
        icon: Icon(Icons.location_city),
        iconColor: Color.fromARGB(255, 67, 160, 71),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onChanged: (value) {
        print('Selected value $value');
        setState(() {
          _delAddr = value;
        });
      },
      onSaved: (value) {
        _delAddr = value!;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Order"),
        backgroundColor: const Color.fromARGB(255, 67, 160, 71),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildoc(),
                _buildov(),
                _buildow(),
                _buildMobileNumber(),
                _buildPkupAddr(),
                _buildDelAddr(),
                const SizedBox(height: 100),
                ButtonWidget(
                    text: 'PROCEED TO CHECKOUT',
                    onClicked: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      _formKey.currentState!.save();
                      _formKey.currentState!.reset();

                      _createOrder();
                      notificationServices.sendNotificationToBuyer(
                        '$countryCode$_mobileNumber',
                          'amount: ${_orderValue}, weightage: ${_orderWeightage}',
                          widget.businessName);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OrderDetails(
                                    orderValue: _orderValue.toString(),
                                    orderWeightage: _orderWeightage,
                                    pkupAddr: _pkupAddr,
                                    delAddr: _delAddr,
                                    category: defaultvalue,
                                    mobileNumber: '$countryCode$_mobileNumber',
                                    docid: orderid,
                                businessName: widget.businessName,
                                  )));
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
