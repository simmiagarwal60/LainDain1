

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lain_dain/services/firebase_auth.dart';
import 'package:lain_dain/services/notification_services.dart';
import 'package:lain_dain/widget/button_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:lain_dain/widget/order_details.dart';
import 'package:lain_dain/models/notification_model.dart' as notify;

class OrderScreeen extends StatefulWidget {
  final String businessName;
  const OrderScreeen({Key? key, required this.businessName}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OrderScreenState();
  }
}

class OrderScreenState extends State<OrderScreeen> {
  String _orderValue=" ";
  String _orderWeightage="";
  String _mobileNumber="";
  String _pkupAddr="";
  String _delAddr="";
  String defaultvalue='';
  //File? _orderImage;
  String? screenshotUrl;
  String? docid ;

  List list = [{"title": "FASHION", "value":"FASHION"},{"title":"CLOTHES", "value":"CLOTHES"},{"title": "MOBILE PHONES", "value": "MOBILE PHONES"},{"title": "WATCHES", "value": "WATCHES"},{"title": "LAPTOPS", "value": "LAPTOPS"}];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey _imageKey = GlobalKey();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  final AuthService authService = AuthService();
  final NotificationServices notificationServices = NotificationServices();


  void storeNotification(notify.Notification notification) async {
    CollectionReference notificationsRef = FirebaseFirestore.instance.collection('notifications');
    await notificationsRef.add(notification.toMap());
  }


  void _createOrder() async {
    if (_orderValue.isEmpty ||
        defaultvalue.isEmpty ||
        _orderWeightage.isEmpty ||
        _mobileNumber.isEmpty ||
        _delAddr.isEmpty ||
        _pkupAddr.isEmpty ) {
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
      // final orderData = {
      //   'orderValue': _orderValue,
      //   'category': defaultvalue,
      //   'delivery address': _delAddr,
      //   'pickup address': _pkupAddr,
      //   'weightage': _orderWeightage,
      //   'customerNumber': _mobileNumber,
      // };

      // convertWidgetToImage();
      docid = DateTime.now().millisecondsSinceEpoch.toString();
      final orderRef = FirebaseFirestore.instance.collection('orders');
      String orderid = orderRef.id;
      await orderRef.doc(orderid).set({
        'order id': orderid,
        'business name' : widget.businessName,
        'orderValue': _orderValue,
        'category': defaultvalue,
        'delivery address': _delAddr,
        'pickup address': _pkupAddr,
        'weightage': _orderWeightage,
        'customerNumber': _mobileNumber,
      });
      // Generate FCM token and associate it with the buyer's mobile number
      //await authService.saveUserDetailsToFirestore(_mobileNumber);

      // Retrieve the FCM token associated with the buyer's mobile number
      String? buyerFCMToken = await authService.getBuyerFCMToken(_mobileNumber);

      notify.Notification notification = notify.Notification(
        id: orderid,
        title: widget.businessName,
        amount: _orderValue,
        message: 'Category: $defaultvalue\nOrder Weightage: $_orderWeightage\n Customer mobile number: $_mobileNumber\n delivery address: $_delAddr\n Pickup address: $_pkupAddr',
        isAccepted: false,
      );
      notificationServices.storeNotification(notification);

      if (buyerFCMToken != null) {
        // Send notification to the buyer
        String orderDetails = 'Business Name: ${widget.businessName}\nOrder Value: $_orderValue\nCategory: $defaultvalue\nOrder Weightage: $_orderWeightage';
        await notificationServices.sendOrderNotification(buyerFCMToken, orderDetails);
      }


      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Order created successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);// Pop CreateOrderScreen
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




  Widget _buildoc(){
    return Row(
      children: [
        const Icon(Icons.shopping_cart, color: Color.fromARGB(255, 67, 160, 71),),
        const SizedBox(width: 13,),
        SizedBox(
          width: 298,
          child: InputDecorator(
          decoration: const InputDecoration(
          //border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
          contentPadding: EdgeInsets.all(10),),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                  isDense: true,
                  value: defaultvalue,
                  //isExpanded: true,
                  menuMaxHeight: 350,
                  items: [
                    const DropdownMenuItem(
                        value: "",
                        child: Text("ORDER CATEGORY", style: TextStyle(color: Colors.black54, fontSize: 16), textAlign: TextAlign.start,)),

                    ...list.map<DropdownMenuItem<String>>((data){
                      return DropdownMenuItem(
                        value: data['value'],
                        child: Text(data['title']),);
                    }).toList(),
                  ],
                  onChanged: (value){
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
      onChanged: (value){
        print('Selected value $value');
        setState(() {
          _orderValue = value;
        });
      },
      onSaved: (value) {
        _orderValue = value!;
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
      onChanged: (value){
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
      onChanged: (value){
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
      onChanged: (value){
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
      onChanged: (value){
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
                ButtonWidget(text: 'PROCEED TO CHECKOUT', onClicked: () {

                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  _formKey.currentState!.save();

                  _createOrder();
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderDetails(orderValue: _orderValue, orderWeightage: _orderWeightage, pkupAddr: _pkupAddr, delAddr: _delAddr, category: defaultvalue, mobileNumber: _mobileNumber, docid: docid,)));
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