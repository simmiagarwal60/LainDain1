import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
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

  OrderDetails(
      {super.key,
      required this.orderValue,
      required this.orderWeightage,
      required this.pkupAddr,
      required this.delAddr,
      required this.category,
      required this.mobileNumber,
      required this.docid});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  String? screenshotUrl;
  Uint8List? screenshotBytes;

  GlobalKey _imageKey = GlobalKey();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // void convertWidgetToImage() async {
  //   RenderRepaintBoundary boundary =
  //   _imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  //   ui.Image image = await boundary.toImage(pixelRatio: 3);
  //   ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //   if (byteData != null) {
  //     setState(() {
  //       screenshotBytes = byteData!.buffer.asUint8List();
  //     });
  //   }
  // }
  //
  //
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   convertWidgetToImage();
  // }
  //
  // void shareImage() async {
  //   //convertWidgetToImage();
  //
  //   final directory = await getApplicationDocumentsDirectory();
  //   final imagePath = '${directory.path}/order_screenshot.png';
  //   final imageFile = File(imagePath);
  //   await imageFile.writeAsBytes(screenshotBytes!);
  //
  //   await Share.shareFiles([imageFile.path]);
  //
  //   await [Permission.storage].request();
  //   String screenshotPath =
  //       'orderScreenshots/${DateTime.now().millisecondsSinceEpoch}.png';
  //   UploadTask uploadTask =
  //   _firebaseStorage.ref().child(screenshotPath).putData(screenshotBytes!);
  //   TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
  //
  //   screenshotUrl = await taskSnapshot.ref.getDownloadURL();
  //   FirebaseFirestore.instance
  //       .collection('userOrders')
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .collection('order')
  //       .doc(widget.docid)
  //       .update({'ScreenshoutUrl': screenshotUrl});
  //
  //
  //   //final result = await ImageGallerySaver.saveImage(screenshotBytes!, name: 'screenshot_${DateTime.now().millisecondsSinceEpoch}');
  // }
  //
  // void downloadImage() async {
  //   //convertWidgetToImage();
  //   final result = await ImageGallerySaver.saveImage(screenshotBytes!,
  //       name: 'screenshot_${DateTime.now().millisecondsSinceEpoch}');
  //   if (result['isSuccess']) {
  //     showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: Text('Screenshot Saved'),
  //             content: Text('Screenshot has been saved to gallery.'),
  //             actions: [
  //               TextButton(
  //                 child: Text('OK'),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //             ],
  //           );
  //         });
  //   } else {
  //     // Failed to save
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Failed to Save Screenshot'),
  //           content: Text('There was an error while saving the screenshot.'),
  //           actions: [
  //             TextButton(
  //               child: Text('OK'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  //   String screenshotPath =
  //       'orderScreenshots/${DateTime.now().millisecondsSinceEpoch}.png';
  //   UploadTask uploadTask =
  //   _firebaseStorage.ref().child(screenshotPath).putData(screenshotBytes!);
  //   TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
  //
  //   screenshotUrl = await taskSnapshot.ref.getDownloadURL();
  //   FirebaseFirestore.instance
  //       .collection('userOrders')
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .collection('order')
  //       .doc(widget.docid)
  //       .update({'ScreenshoutUrl': screenshotUrl});
  //
  // }

  void convertWidgetToImage() async{
    RenderRepaintBoundary boundary = _imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if(byteData != null){
      setState(() {
        screenshotBytes = byteData!.buffer.asUint8List();
      });
    }

    String screenshotPath = 'orderScreenshots/${DateTime.now().millisecondsSinceEpoch}.png';

    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/order_screenshot.png';
    final imageFile = File(imagePath);
    await imageFile.writeAsBytes(screenshotBytes!);

    await Share.shareFiles([imageFile.path]);


    await [Permission.storage].request();
    final result = await ImageGallerySaver.saveImage(screenshotBytes!, name: 'screenshot_${DateTime.now().millisecondsSinceEpoch}');
    if(result['isSuccess']){
      showDialog(context: context,
          builder: (BuildContext context){
        return AlertDialog(
          title: Text('Screenshot Saved'),
          content:Text('Screenshot has been saved to gallery.') ,
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
    }
    else {
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

    UploadTask uploadTask = _firebaseStorage.ref().child(screenshotPath).putData(screenshotBytes!);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

    screenshotUrl = await taskSnapshot.ref.getDownloadURL();
    FirebaseFirestore.instance.collection('userOrders').doc(FirebaseAuth.instance.currentUser!.uid).collection('order').doc(widget.docid).update({'ScreenshoutUrl': screenshotUrl});
  }

  // Widget _buildOrderImagePreview() {
  //   return RepaintBoundary(
  //     key: _imageKey,
  //     child: Container(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             Text('Order Category: ${defaultvalue}'),
  //             Text('Order Value: ${_orderValue}'),
  //             Text('Order Weightage: ${_orderWeightage}'),
  //             Text('Customer mobile number : ${_mobileNumber}'),
  //             Text('Delivery Address : ${_delAddr}'),
  //             Text('Pickup Address : ${_pkupAddr}'),
  //             Text('Order has been placed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
  //           ],
  //         )),
  //   );
  //
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
          height: 48,
          margin: const EdgeInsets.all(40),
          child: ButtonWidget(
              text: "Save Order",
              onClicked: () {
                convertWidgetToImage();
                Navigator.push(context, MaterialPageRoute(builder: (context)=>SellerOrderHistory()));
              })),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RepaintBoundary(
              key: _imageKey,
              child: Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Order Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text('Order Category: ${widget.category}'),
                  Text('Order Value: ${widget.orderValue}'),
                  Text('Order Weightage: ${widget.orderWeightage}'),
                  Text('Customer mobile number : ${widget.mobileNumber}'),
                  Text('Delivery Address : ${widget.delAddr}'),
                  Text('Pickup Address : ${widget.pkupAddr}'),
                  SizedBox(
                    height: 10,
                  ),
                ],
              )),
            ),
            Text(
              'Order has been successfully created!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(
              height: 10,
            ),
            screenshotBytes != null
                ? Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Image.memory(
                          screenshotBytes!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {
                                //downloadImage();
                              },
                              icon: Icon(
                                Icons.download,
                                color: Color.fromARGB(255, 67, 160, 71),
                              )),
                          IconButton(
                              onPressed: () {
                                //shareImage();
                              },
                              icon: Icon(
                                Icons.share,
                                color: Color.fromARGB(255, 67, 160, 71),
                              ))
                        ],
                      )
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
