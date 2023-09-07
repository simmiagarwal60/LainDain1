import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lain_dain/screens/order_screen.dart';
import 'package:lain_dain/screens/seller_main.dart';
import 'package:lain_dain/screens/seller_orderHistory.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:lain_dain/widget/button_widget.dart';
import 'dart:ui' as ui;

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class OrderDetails extends StatefulWidget {
  final String? docid;
  final String? orderValue;
  final String? orderWeightage;
  final String? mobileNumber;
  final String? pkupAddr;
  final String? delAddr;
  final String? category;
  final String? businessName;

  OrderDetails(
      {super.key,
      required this.orderValue,
      required this.orderWeightage,
      required this.pkupAddr,
      required this.delAddr,
      required this.category,
      required this.mobileNumber,
      required this.docid,
        required this.businessName});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  String? screenshotUrl;
  Uint8List? screenshotBytes;

  GlobalKey _imageKey = GlobalKey();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<void> convertWidgetToImage() async {
    RenderRepaintBoundary boundary =
        _imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    print(byteData.toString());
    //screenshotBytes = byteData!.buffer.asUint8List();
    if (byteData != null) {
      print('byteData is null');
      setState(() {
        screenshotBytes = byteData!.buffer.asUint8List();
      });
    } else {
      print('byteData is null');
    }

  }

  void shareImage() async {
    convertWidgetToImage();

    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/order_screenshot.png';
    final imageFile = File(imagePath);
    await imageFile.writeAsBytes(screenshotBytes!);

    await Share.shareFiles([imageFile.path]);

    await [Permission.storage].request();
    String screenshotPath =
        'orderScreenshots/${DateTime.now().millisecondsSinceEpoch}.png';
    UploadTask uploadTask =
        _firebaseStorage.ref().child(screenshotPath).putData(screenshotBytes!);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

    screenshotUrl = await taskSnapshot.ref.getDownloadURL();
    FirebaseFirestore.instance
        .collection('userOrders')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('order')
        .doc(widget.docid)
        .update({'ScreenshoutUrl': screenshotUrl});

    //final result = await ImageGallerySaver.saveImage(screenshotBytes!, name: 'screenshot_${DateTime.now().millisecondsSinceEpoch}');
  }

  void downloadImage() async {
    convertWidgetToImage();
    final result = await ImageGallerySaver.saveImage(screenshotBytes!,
        name: 'screenshot_${DateTime.now().millisecondsSinceEpoch}');
    if (result['isSuccess']) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Screenshot Saved'),
              content: Text('Screenshot has been saved to gallery.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    } else {
      // Failed to save
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Failed to Save Screenshot'),
            content: Text('There was an error while saving the screenshot.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    String screenshotPath =
        'orderScreenshots/${DateTime.now().millisecondsSinceEpoch}.png';
    UploadTask uploadTask =
        _firebaseStorage.ref().child(screenshotPath).putData(screenshotBytes!);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

    screenshotUrl = await taskSnapshot.ref.getDownloadURL();
    FirebaseFirestore.instance
        .collection('userOrders')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('order')
        .doc(widget.docid)
        .update({'ScreenshoutUrl': screenshotUrl});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            RepaintBoundary(
              key: _imageKey,
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                          image: DecorationImage(
                            image: AssetImage('asset/images/green_bg.avif'),
                            fit: BoxFit.fill
                          )
                        ),
                      ),
                      Positioned(
                        top: 50,
                        child: Row(
                          children: [
                            IconButton(onPressed: (){
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              //Navigator.of(context).pop();
                            },
                                icon: Icon(Icons.arrow_back_ios_new)),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  'Lain Dain',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 20),
                                ),
                                Text(
                                  'Order Details',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 25),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Customer mobile number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                          Text('${widget.mobileNumber}',  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                          Text('${widget.delAddr}',  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Pickup Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                          Text('${widget.pkupAddr}',  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
                        ],
                      ),
                      SizedBox(height: 10,),
                      Divider(color: Colors.grey,),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                          Text('${widget.category}',  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order Weightage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                          Text('${widget.orderWeightage}',  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                          Text('${widget.orderValue}',  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
                        ],
                      ),
                      SizedBox(height: 10,),
                      Divider(color: Colors.grey,),
                    ],
                  ),
                ),

                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      downloadImage();
                    },
                    icon: Icon(
                      Icons.download,
                      color:
                      Color.fromARGB(255, 67, 160, 71),
                    )),
                IconButton(
                    onPressed: () {
                      shareImage();
                    },
                    icon: Icon(
                      Icons.share,
                      color:
                      Color.fromARGB(255, 67, 160, 71),
                    ))
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Column(
                children: [
                  // SizedBox(height: 20,),
                  // ButtonWidget(text: 'Cancel Order', onClicked: (){}),
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: ButtonWidget(text: 'Create new Order', onClicked: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> SellerMainScreen(businessName: widget.businessName!)));
                    }),
                  ),
                ],
              ),
            ),

          ],
        ));
  }
}
