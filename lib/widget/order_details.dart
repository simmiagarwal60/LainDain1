import 'dart:io';
import 'dart:typed_data';
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
  OrderDetails({super.key, required this.orderValue,required this.orderWeightage,required this.pkupAddr,required this.delAddr, required this.category,required this.mobileNumber, required this.docid});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  String? screenshotUrl;


  GlobalKey _imageKey = GlobalKey();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    convertWidgetToImage();
  }

  void convertWidgetToImage() async{
    RenderRepaintBoundary boundary = _imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List screenshotBytes = byteData!.buffer.asUint8List();

    String screenshotPath = 'orderScreenshots/${DateTime.now().millisecondsSinceEpoch}.png';

    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/order_screenshot.png';
    final imageFile = File(imagePath);
    await imageFile.writeAsBytes(screenshotBytes);

    //await Share.shareFiles([imageFile.path]);


    //await [Permission.storage].request();
    final result = await ImageGallerySaver.saveImage(screenshotBytes, name: 'screenshot_${DateTime.now().millisecondsSinceEpoch}');

    UploadTask uploadTask = _firebaseStorage.ref().child(screenshotPath).putData(screenshotBytes);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

    screenshotUrl = await taskSnapshot.ref.getDownloadURL();
    FirebaseFirestore.instance.collection('orders').doc(widget.docid).update({'ScreenshoutUrl': screenshotUrl});
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
          height:48 ,
        margin: const EdgeInsets.all(40),
        child: ButtonWidget(text: "OK",
            onClicked: (){
          convertWidgetToImage();
            })
        ),
      body: Center(
        child: RepaintBoundary(
          key: _imageKey,
          child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Order Category: ${widget.category}'),
                  Text('Order Value: ${widget.orderValue}'),
                  Text('Order Weightage: ${widget.orderWeightage}'),
                  Text('Customer mobile number : ${widget.mobileNumber}'),
                  Text('Delivery Address : ${widget.delAddr}'),
                  Text('Pickup Address : ${widget.pkupAddr}'),
                  Text('Order has been successfully placed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
                ],
              )),
        ),
      ),
    );
  }
}
