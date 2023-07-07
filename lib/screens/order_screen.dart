import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lain_dain/models/category_model.dart';
import 'package:lain_dain/models/orders_model.dart';
import 'package:lain_dain/services/firebase_auth.dart';
import 'package:lain_dain/services/notification_services.dart';
import 'package:lain_dain/widget/button_widget.dart';
import 'package:lain_dain/screens/order_details.dart';
import 'package:lain_dain/models/notification_model.dart' as notify;

import '../services/notification_services.dart';

class OrderScreeen extends StatefulWidget {
  final String businessName;
  final String pickupAddress;

  const OrderScreeen(
      {Key? key, required this.businessName, required this.pickupAddress})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OrderScreenState();
  }
}

class OrderScreenState extends State<OrderScreeen> {
  String _orderValue = '';
  String _orderWeightage = "";
  String _mobileNumber = "";
  String _pkupAddr = "";
  String _delAddr = "";
  String defaultvalue = '';

  String? screenshotUrl;
  String? orderid;

  TextEditingController pickupAddressController = TextEditingController();
  List<CategoryModel> _categoriesList = [];

  List list = [
    {"title": "FASHION", "value": "FASHION"},
    {"title": "CLOTHES", "value": "CLOTHES"},
    {"title": "MOBILE PHONES", "value": "MOBILE PHONES"},
    {"title": "WATCHES", "value": "WATCHES"},
    {"title": "LAPTOPS", "value": "LAPTOPS"}
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // GlobalKey _imageKey = GlobalKey();
  // final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  final AuthService authService = AuthService();
  final NotificationServices notificationServices = NotificationServices();

  void getCategoryList() async {
    _categoriesList = await AuthService().getCategories();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategoryList();
    pickupAddressController.text = widget.pickupAddress;
  }

  void storeNotification(notify.Notification notification) async {
    CollectionReference notificationsRef =
        FirebaseFirestore.instance.collection('notifications');
    await notificationsRef.add(notification.toMap());
  }

  void _createOrder() async {

    orderid = FirebaseAuth.instance.currentUser!.uid;

    if (_orderValue == 0 ||
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

      // FirebaseFirestore.instance
      //     .collection('orders')
      //     .doc(orderid)
      //     .set(order.toJson());
      AuthService.instance.saveOrderDetailsToFirestore(
          "Pending",
          widget.businessName,
          defaultvalue,
          _orderValue,
          _orderWeightage,
          _mobileNumber,
          _pkupAddr,
          _delAddr);


      // Retrieve the FCM token associated with the buyer's mobile number
      String? buyerFCMToken = await authService.getBuyerFCMToken(_mobileNumber);

      // notify.Notification notification = notify.Notification(
      //   id: orderid!,
      //   title: widget.businessName,
      //   amount: _orderValue,
      //   message:
      //       'Category: $defaultvalue\nOrder Weightage: $_orderWeightage\n Customer mobile number: $_mobileNumber\n delivery address: $_delAddr\n Pickup address: $_pkupAddr',
      //   isAccepted: false,
      // );
      // notificationServices.storeNotification(notification);
      //
      // if (buyerFCMToken != null) {
      //   // Send notification to the buyer
      //   String orderDetails =
      //       'Business Name: ${widget.businessName}\nOrder Value: ${_orderValue.toString()}\nCategory: $defaultvalue\nOrder Weightage: $_orderWeightage';
      //   await notificationServices.sendOrderNotification(
      //       buyerFCMToken, orderDetails);
      // }

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
      maxLength: 10,
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
        title: const Text("LainDain"),
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

                // SizedBox(height: 16.0),
                // ButtonWidget(text: 'Select Order Image', onClicked: _selectOrderImage),
                const SizedBox(height: 100),
                ButtonWidget(
                    text: 'PROCEED TO CHECKOUT',
                    onClicked: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      _formKey.currentState!.save();

                      _createOrder();
                      notificationServices.sendNotificationToBuyer(_mobileNumber, 'amount: ${_orderValue}, weightage: ${_orderWeightage}', widget.businessName);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OrderDetails(
                                    orderValue: _orderValue.toString(),
                                    orderWeightage: _orderWeightage,
                                    pkupAddr: _pkupAddr,
                                    delAddr: _delAddr,
                                    category: defaultvalue,
                                    mobileNumber: _mobileNumber,
                                    docid: orderid,
                                  )));
                      // print(_orderValue);
                      // print(_orderWeightage);
                      // print(_mobileNumber);
                      // print(_pkupAddr);
                      // print(_delAddr);
                      //Send to API
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
