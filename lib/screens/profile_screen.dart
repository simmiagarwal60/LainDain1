import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lain_dain/services/firebase_auth.dart';
import 'package:lain_dain/widget/button_widget.dart';

import '../models/users.dart';


class ProfileScreen extends StatefulWidget {
  //final Users user;

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _firstName ='a';
  String _lastName ='a';
  String fullName = '';
  Users? _user;
  String? email;
  String? _image;

  String extractFirstName(String fullName) {
    List<String> nameParts = fullName.split(' ');
    if (nameParts.isNotEmpty) {
      return nameParts.first;
    }
    return '';
  }

  String extractLastName(String fullName) {
    List<String> nameParts = fullName.split(' ');
    if (nameParts.length > 1) {
      return nameParts.last;
    }
    return '';
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _user = AuthService.me;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show a loading indicator while fetching the data
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text(
                'User not found'); // Handle if the user document doesn't exist
          }
          final data = snapshot.data?.data() as Map<String, dynamic>;
          _firstName = data['firstName'] ?? '';
          _lastName = data['lastName'] ?? '';
          fullName = data['fullName'];


          return Scaffold(
            appBar: AppBar(
              title: Text('Profile'),
              backgroundColor: const Color.fromARGB(255, 67, 160, 71),
            ),
            // floatingActionButton: FloatingActionButton.extended(
            //   onPressed: () {
            //     AuthService.instance.signOut();
            //     //Navigator.of(context).pop();
            //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> MyPhone()));
            //   },
            //   label: Text('Logout'),
            //   icon: Icon(Icons.logout),
            //   backgroundColor: Colors.green.shade900,
            // ),
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).width * 0.03,
                    ),
                    Stack(
                      children: [
                        _image != null ?
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                              MediaQuery.sizeOf(context).height * 0.1),
                          child: Image.file(File(_image!),
                            //color: Colors.green,
                            width: MediaQuery.sizeOf(context).height * 0.2,
                            height: MediaQuery.sizeOf(context).height * 0.2,
                            fit: BoxFit.cover,

                          ),
                        ) :
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                              MediaQuery.sizeOf(context).height * 0.1),
                          child: CachedNetworkImage(
                            //color: Colors.green,
                            width: MediaQuery.sizeOf(context).height * 0.2,
                            height: MediaQuery.sizeOf(context).height * 0.2,
                            fit: BoxFit.fill,
                            imageUrl: data['image'],
                            errorWidget: (context, url, error) => const CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: MaterialButton(onPressed: (){
                            _showBottomSheet(data['userId']);
                          },
                          color: Colors.white,
                            shape: CircleBorder(),
                          child: Icon(Icons.edit, color: Colors.green,),),
                        )
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).width * 0.03,
                    ),
                    Text(
                      data['phoneNumber'],
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    data['userRole'] == 'Seller'
                        ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                              children: [
                                TextFormField(
                                  initialValue: '${data['firstName']}',
                                  decoration: const InputDecoration(
                                    labelText: 'First Name',
                                    focusColor: Color.fromARGB(255, 67, 160, 71),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Field is Required';
                                    }
                                    return null;
                                  },
                                  onChanged: (value){
                                    _firstName = value;
                                  },
                                ),
                                TextFormField(
                                  initialValue: '${data['lastName']}',
                                  decoration: const InputDecoration(
                                    labelText: 'Last Name',
                                    focusColor: Color.fromARGB(255, 67, 160, 71),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Field is Required';
                                    }

                                    return null;
                                  },
                                  onChanged: (value){
                                    _lastName = value;
                                  },
                                ),
                                SizedBox(
                                  height: MediaQuery.sizeOf(context).width * 0.03,
                                ),
                                TextFormField(
                                  readOnly: true,
                                  initialValue: '${data['aadhaarNumber']}',
                                  decoration: const InputDecoration(
                                    labelText: 'Aadhaar Number',
                                    focusColor: Color.fromARGB(255, 67, 160, 71),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Field is Required';
                                    }

                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: MediaQuery.sizeOf(context).width * 0.03,
                                ),
                                TextFormField(
                                  readOnly: true,
                                  initialValue: '${data['panNumber']}',
                                  decoration: const InputDecoration(
                                    labelText: 'PAN Number',
                                    focusColor: Color.fromARGB(255, 67, 160, 71),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Field is Required';
                                    }

                                    return null;
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, right: 40, left: 40),
                                  child: ButtonWidget(text: 'SUBMIT', onClicked: (){
                                    _user?.fullName = '$_firstName $_lastName';
                                    AuthService.instance.updateCurrentUserData(_user, _firstName, _lastName);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
                                  }),
                                )
                              ],
                            ),
                        )
                        : const SizedBox(),
                    data['userRole'] == 'Buyer'
                        ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                              children: [
                                SizedBox(
                                  height: MediaQuery.sizeOf(context).width * 0.03,
                                ),
                                TextFormField(
                                  initialValue: '${data['fullName']}',
                                  decoration: const InputDecoration(
                                    labelText: 'Full Name',
                                    focusColor: Color.fromARGB(255, 67, 160, 71),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Field is Required';
                                    }
                                    return null;
                                  },
                                  onChanged: (value){
                                    fullName = value;
                                  },
                                ),
                                TextFormField(
                                  initialValue: '${data['email']}',
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    focusColor: Color.fromARGB(255, 67, 160, 71),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Field is Required';
                                    }
                                    return null;
                                  },
                                  onChanged: (value){
                                    email = value;
                                  },
                                ),

                                SizedBox(
                                  height: MediaQuery.sizeOf(context).width * 0.03,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, right: 40, left: 40),
                                  child: ButtonWidget(text: 'SUBMIT', onClicked: (){
                                    _firstName = extractFirstName(fullName);
                                    _lastName = extractLastName(fullName);
                                    _user?.fullName = fullName;
                                    AuthService.instance.updateCurrentUserData(_user, _firstName, _lastName);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
                                  }),
                                )
                              ],
                            ),
                        )
                        : SizedBox()
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _showBottomSheet(String uid){
    showModalBottomSheet(
      context: context,
      //backgroundColor: Colors.green.withOpacity(0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20)
        )
      ),
      builder: (_){
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 20, bottom: 20, left: 10),
          children: [
            Text('Profile photo',style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(MediaQuery.of(context).size.width * 0.3,MediaQuery.of(context).size.width * 0.15),
                    side: BorderSide(width: 1, color: Colors.green.withOpacity(0.4))),
                    onPressed: () async{
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery,  imageQuality: 80);

                      if(image != null){
                        setState(() {
                          _image = image.path;
                        });
                        AuthService.instance.updateUserProfilePicture(File(_image!), uid);
                        Navigator.pop(context);
                      }

                    },
                    child: Icon(Icons.image, color: Colors.green, size: 30,)),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(MediaQuery.of(context).size.width * 0.3,MediaQuery.of(context).size.width * 0.15),
                        side: BorderSide(width: 1, color: Colors.green.withOpacity(0.4))),
                    onPressed: () async{
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);

                      if(image != null){
                        setState(() {
                          _image = image.path;
                        });
                        AuthService.instance.updateUserProfilePicture(File(_image!), uid);
                        Navigator.pop(context);
                      }
                    },
                    child: Icon(Icons.camera_alt, color: Colors.green, size: 30,))
              ],
            )
          ],
        );
      }
    );
  }
}
