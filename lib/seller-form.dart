// ignore_for_file: deprecated_member_use, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lain_dain/delivery/delivery_details.dart';
import 'package:lain_dain/models/pickup_address_model.dart';
import 'package:lain_dain/widget/button_widget.dart';
import 'order_screen.dart';

class FormScreen extends StatefulWidget {
  final PickupAddress selectedAddress;

  //String aadharNumber="";
  const FormScreen({Key? key, required this.selectedAddress}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FormScreenState();
  }
}

class FormScreenState extends State<FormScreen> {
  late String _pan;
  late String _firstName;
  late String _lastName;
  late String _businessName;
  late String _pkupAddress;
  TextEditingController pkupAddressController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // _createSeller() async{
  //   await APIs.createSeller(APIs.auth.currentUser!.uid,widget.aadharNumber, _pan, _firstName, _lastName, _businessName, _pkupAddress);
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pkupAddressController = TextEditingController(
      text:
          '${widget.selectedAddress.houseNumber}, ${widget.selectedAddress.city}, ${widget.selectedAddress.pincode},${widget.selectedAddress.state}',
    );
  }

  void saveSellerDetails() async {
    final SellerRef = FirebaseFirestore.instance.collection('sellers');
    String sellerid = SellerRef.doc().id;
    await SellerRef.doc(sellerid).set({
      'Seller id': sellerid,
      'Pan card': _pan,
      'First name': _firstName,
      'Last name': _lastName,
      'business name': _businessName,
      'pickup address': pkupAddressController.text,
    });
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

    pkupAddressController.text = currentAddress;
  }

  Widget _buildPan() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'PAN NUMBER',
        icon: Icon(Icons.payment),
        iconColor: Color.fromARGB(255, 67, 160, 71),
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
        iconColor: Color.fromARGB(255, 67, 160, 71),),
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=> DeliveryDetails(savedAddress: PickupAddress(id: '', fullName: '', pincode:'', houseNumber: '', city: '', state: ''))));
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
                _buildPan(),
                _buildFirstName(),
                _buildLastName(),
                _buildBusinessName(),
                _buildPkupAdd(),
                const SizedBox(
                  height: 8,
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
                            builder: (context) => OrderScreeen(businessName: _businessName,pickupAddress: _pkupAddress,)),);

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
