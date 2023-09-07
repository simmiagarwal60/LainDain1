// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lain_dain/screens/delivery_details.dart';
import 'package:lain_dain/models/pickup_address_model.dart';
import 'package:lain_dain/screens/seller_main.dart';
import 'package:lain_dain/services/firebase_auth.dart';
import 'package:lain_dain/widget/button_widget.dart';
import '../models/aadhaar_data.dart';
import 'order_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;

class FormScreen extends StatefulWidget {
  final PickupAddress? selectedAddress;

  const FormScreen({Key? key, required this.selectedAddress}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FormScreenState();
  }
}

class FormScreenState extends State<FormScreen> {
  String token =
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTY4ODkwMTQ1OSwianRpIjoiYTUwOGRkYTctMjdiNS00NmQ1LWI3YzctMDZjMjVjYjdmN2ZkIiwidHlwZSI6ImFjY2VzcyIsImlkZW50aXR5IjoiZGV2LnZhbGVuY2V3YXJlQHN1cmVwYXNzLmlvIiwibmJmIjoxNjg4OTAxNDU5LCJleHAiOjE2OTY2Nzc0NTksInVzZXJfY2xhaW1zIjp7InNjb3BlcyI6WyJ1c2VyIl19LCJ0ZW5hbnRfaWQiOiJQYWlkIHRlc3QifQ.bkRvUijpFQ5z4eM-hpSRlXwLLvPomWo41PZviwR-p-c";
  String? _aadhaar;
  late String _pan;
  String? _firstName;
  String? _lastName;
  late String _businessName;
  late String _pkupAddress;
  bool showOtpField = false;
  bool isAadhaarValid = false;
  bool isPanValid = false;
  String client_id = '';
  TextEditingController pkupAddressController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.selectedAddress == null? pkupAddressController = TextEditingController(text: ""):pkupAddressController = TextEditingController(
      text:
          '${widget.selectedAddress!.houseNumber}, ${widget.selectedAddress!.city}, ${widget.selectedAddress!.pincode},${widget.selectedAddress!.state}',
    );
  }

  void saveSellerDetails() async {
    AuthService.instance.updateSellerDetails(_aadhaar!, _pan, _firstName!,
        _lastName!, _businessName, pkupAddressController.text);
  }

  void determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied!");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location permissions are permanently denied!, we cannot request permission");
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark placemark = placemarks[0];
    String currentAddress =
        '${placemark.street}, ${placemark.subLocality}, ${placemark.locality},${placemark.postalCode}, ${placemark.administrativeArea}, ${placemark.country}';

    DocumentReference orderDocument = FirebaseFirestore.instance
        .collection('sellerAddresses')
        .doc(FirebaseAuth.instance.currentUser!.uid).collection('address').doc();
    String docId = orderDocument.id;
    final address = PickupAddress(id: docId,fullName: _firstName!, city: '${placemark.locality}', state: '${placemark.administrativeArea}', pincode: '${placemark.postalCode}', houseNumber: '${placemark.street}');

    FirebaseFirestore.instance
        .collection('sellerAddresses')
        .doc(FirebaseAuth.instance.currentUser!.uid).collection('address').doc(docId).set(address.toJson());

    pkupAddressController.text = currentAddress;
  }

  Widget _buildAadhaar() {
    return TextFormField(
      maxLength: 12,
      decoration: InputDecoration(
        counterText: "",
        isDense: true,
          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          labelText: 'AADHAAR NUMBER',
          icon: Icon(Icons.payment),
          iconColor: Color.fromARGB(255, 67, 160, 71),
          suffix: isAadhaarValid ?
          Padding(
            padding: const EdgeInsets.only(bottom: 3.0),
            child: Stack(
              children: [
                IconButton(
                  onPressed: (){},
                    icon: Icon(Icons.verified,
                    color: Color.fromARGB(255, 67, 160, 71),
                    size: 30,)
                  ),
                Positioned(
                   top: 32,
                    left: 8,
                    child: Text('Verified', style: TextStyle(fontSize: 14),))
              ],
            ),
          )
              :Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: Stack(
            children: [
                IconButton(
                  onPressed: () async {
                    client_id = await sendOtp(_aadhaar!);
                  },
                  icon: Icon(
                    Icons.check,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                Positioned(
                    top: 32,
                    left: 10,
                    bottom: 2,
                    child: Text('Verify', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),))
            ],
          ),
              )
    ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onSaved: (value) {
        _aadhaar = value!;
      },
      onChanged: (value) {
        print('Selected value $value');
        setState(() {
          _aadhaar = value!;
        });
      },
    );
  }

  Widget _showOtpField() {
    return Padding(
      padding: const EdgeInsets.only(left: 38, right: 3),
      child: PinCodeTextField(
        pinTheme: PinTheme(
            shape: PinCodeFieldShape.underline,
            inactiveColor: Colors.grey,
            activeColor: Color.fromARGB(255, 67, 160, 71),
        selectedColor: Color.fromARGB(255, 67, 160, 71),
          borderRadius: BorderRadius.circular(10),
        borderWidth: 1,
        inactiveBorderWidth: 1),
        
        appContext: context,
        length: 6,
        onChanged: (String value) {},
        onCompleted: (value) {
          print('clientId check: ${client_id}');
          validateOtp(client_id, value);
          setState(() {
            showOtpField = false;
          });
        },
      ),
    );
  }

  Future<String> sendOtp(String aadhaarNumber) async {
    setState(() {
      showOtpField = true;
    });

    var url = 'https://sandbox.aadhaarkyc.io/api/v1/aadhaar-v2/generate-otp';
    final http.Response response = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': "Bearer $token"
        },
        body: jsonEncode({'id_number': aadhaarNumber}));
    if (response.statusCode == 200) {
      var dataCard = Aadhaardata.fromJson(json.decode(response.body)["data"]);
      String clientID = dataCard.clientId!;
      print('otp sent successfully');
      print('clientId: ${clientID}');
      return clientID;
      //return Aadhaardata.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create event: ${response.body}');
    }
  }

  Future<dynamic> validateOtp(String clientId, String otp) async {
    var url = 'https://sandbox.aadhaarkyc.io/api/v1/aadhaar-v2/submit-otp';
    final http.Response response = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          //'Accept': 'application/json',
          'Authorization': "Bearer $token"
        },
        body: jsonEncode({'client_id': clientId, 'otp': otp}));
    if (response.statusCode == 200) {
      print('otp validated');
      setState(() {
        isAadhaarValid = true;
      });

      Map<String, dynamic> validateOTPResponseJson =
          jsonDecode(response.body)['data'];
      String fullName = validateOTPResponseJson['full_name'];
      firstNameController.text = extractFirstName(fullName);
      _firstName = extractFirstName(fullName);
      lastNameController.text = extractLastName(fullName);
      _lastName = extractLastName(fullName);
      Map<String, dynamic> address = validateOTPResponseJson['address'];
      pkupAddressController.text =
          '${address['house']} ${address['loc']} ${address['dist']} ${validateOTPResponseJson['zip']} ${address['state']}';
    } else {
      print(response.body);
      showInformation(
          message: 'Incorrect OTP',
          messageIcon: Icons.cancel_rounded,
          iconColor: Colors.green,
          showButton: true,
      buttonText: 'Resend OTP');
    }
  }

  showInformation(
      {String? message,
      Color? iconColor,
      IconData? messageIcon,
      bool showButton = false,
      String? buttonText}) {
    showDialog(
        //barrierColor: Colors.white.withOpacity(0),
        context: context,
        builder: (context) {
          return AlertDialog(
            //elevation: 0,
            //backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            // actions: [
            //   showButton
            //       ? TextButton(
            //           onPressed: () {
            //             Navigator.pop(context); // Pop CreateOrderScreen
            //           },
            //           child: Text(buttonText!),
            //         )
            //       : const SizedBox()
            // ],
            //title: Text(message!),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  messageIcon!,
                  size: 80,
                  color: iconColor ?? Colors.green,
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  message!,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 20,
                ),
                showButton
                    ? TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Pop CreateOrderScreen
                  },
                  child: Text(buttonText!),
                )
                    : const SizedBox()
              ],
            ),
          );
        });
  }

  Future<void> verifyPANCard(String panNumber) async {
    try {
      // Make a GET request to the PAN Card verification API endpoint
      final response = await http.post(
        Uri.parse('https://sandbox.aadhaarkyc.io/api/v1/pan/pan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
          body: jsonEncode({'id_number': panNumber})
      );

      if (response.statusCode == 200) {
        // Success! PAN card details retrieved
        setState(() {
          isPanValid = true;
        });
        final panDetails = jsonDecode(response.body);
        print('PAN Card Details: $panDetails');
        if (panDetails["success"] == true) {
        }
      } else {
        // Error occurred while retrieving PAN card details
        print('Failed to retrieve PAN card details: ${response.statusCode}');
        showInformation(
            message: 'Invalid PAN',
            messageIcon: Icons.cancel_rounded,
            iconColor: Colors.green,
            showButton: false,
        buttonText: 'Ok');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Widget _buildPan() {
    return TextFormField(
      decoration: InputDecoration(
          counterText: "",
        isDense: true,
          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        labelText: 'PAN NUMBER',
        icon: Icon(Icons.payment),
        iconColor: Color.fromARGB(255, 67, 160, 71),
          suffix: isPanValid ?
          Padding(
            padding: const EdgeInsets.only(bottom: 3.0),
            child: Stack(
              children: [
                IconButton(
                    onPressed: (){},
                    icon: Icon(Icons.verified,
                      color: Color.fromARGB(255, 67, 160, 71),
                      size: 30,)
                ),
                Positioned(
                    top: 32,
                    left: 10,
                    child: Text('Verified', style: TextStyle(fontSize: 14),))
              ],
            ),
          )
              :Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: Stack(
            children: [
                IconButton(
                  onPressed: () {
                    verifyPANCard(_pan);
                  },
                  icon: Icon(
                    Icons.check,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                Positioned(
                    top: 32,
                    left: 10,
                    child: Text('Verify', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),))
            ],
          ),
              )
      ),
      maxLength: 10,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onSaved: (value) {
        _pan = value!;
      },
      onChanged: (value) {
        print('Selected value $value');
        setState(() {
          _pan = value!;
        });
      },
    );
  }

  Widget _buildFirstName() {
    return TextFormField(
      controller: firstNameController,
      decoration: const InputDecoration(
        labelText: 'FIRST NAME',
        focusColor: Color.fromARGB(255, 67, 160, 71),
        icon: Icon(Icons.person),
        iconColor: Color.fromARGB(255, 67, 160, 71),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onSaved: (value) {
        _firstName = value!;
      },
      onChanged: (value) {
        print('Selected value $value');
        setState(() {
          _firstName = value!;
        });
      },
    );
  }

  Widget _buildLastName() {
    return TextFormField(
      controller: lastNameController,
      decoration: const InputDecoration(
        labelText: 'LAST NAME',
        icon: Icon(Icons.person),
        iconColor: Color.fromARGB(255, 67, 160, 71),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onSaved: (value) {
        _lastName = value!;
      },
      onChanged: (value) {
        print('Selected value $value');
        setState(() {
          _lastName = value!;
        });
      },
    );
  }

  Widget _buildBusinessName() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'BUSINESS NAME',
        icon: Icon(Icons.business_center_sharp),
        iconColor: Color.fromARGB(255, 67, 160, 71),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onSaved: (value) {
        _businessName = value!;
      },
      onChanged: (value) {
        print('Selected value $value');
        setState(() {
          _businessName = value!;
        });
      },
    );
  }

  Widget _buildPkupAdd() {
    return TextFormField(
      controller: pkupAddressController,
      decoration: const InputDecoration(
        labelText: 'PICK-UP ADDRESS',
        icon: Icon(Icons.location_city),
        iconColor: Color.fromARGB(255, 67, 160, 71),
      ),
      keyboardType: TextInputType.streetAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onSaved: (value) {
        _pkupAddress = value!;
      },
    );
  }

  Widget _savedAddresses() {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Icon(
          Icons.location_on,
          color: Color.fromARGB(255, 67, 160, 71),
          size: 20,
        ),
        const SizedBox(
          width: 3,
        ),
        InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DeliveryDetails(
                          savedAddress: PickupAddress(
                              id: '',
                              fullName: '',
                              pincode: '',
                              houseNumber: '',
                              city: '',
                              state: ''))));
            },
            child: const Text(
              "Saved Addresses",
              style: TextStyle(
                  fontWeight: FontWeight.normal, color: Colors.black54),
            ))
      ],
    );
  }

  Widget _useMyLocation() {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Icon(
          Icons.my_location,
          color: Color.fromARGB(255, 67, 160, 71),
          size: 20,
        ),
        const SizedBox(
          width: 3,
        ),
        InkWell(
            onTap: () {
              determinePosition();
            },
            child: const Text(
              "Use my location",
              style: TextStyle(
                  fontWeight: FontWeight.normal, color: Colors.black54),
            ))
      ],
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
                _buildAadhaar(),
                showOtpField ? _showOtpField() : const SizedBox(),
                SizedBox(height: 10,),
                _buildPan(),
                SizedBox(height: 10,),
                _buildFirstName(),
                SizedBox(height: 10,),
                _buildLastName(),
                SizedBox(height: 10,),
                _buildBusinessName(),
                SizedBox(height: 10,),
                _buildPkupAdd(),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _savedAddresses(),
                    _useMyLocation(),
                  ],
                ),
                const SizedBox(height: 100),
                ButtonWidget(
                    text: 'PROCEED',
                    onClicked: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      saveSellerDetails();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SellerMainScreen(businessName: _businessName)),
                      );

                      _formKey.currentState!.save();

                      print(_pan);
                      print(_firstName);
                      print(_lastName);
                      print(_businessName);
                      print(_pkupAddress);
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
