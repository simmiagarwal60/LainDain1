import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lain_dain/notification_screen.dart';

class BuyerFormScreen extends StatefulWidget {
  const BuyerFormScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BuyerFormScreenState();
  }
}

class BuyerFormScreenState extends State<BuyerFormScreen> {
 int _activeStepIndex = 0;

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController PhoneNumber = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController pincode = TextEditingController();

  void saveBuyerDetails() async{
    final buyerRef = FirebaseFirestore.instance.collection('buyers');
    String buyerid = buyerRef.id;
    await buyerRef.doc(buyerid).set({
      'buyer id': buyerid,
      'Full name' : name.text,
      'Email': email.text,
      'Phone number': PhoneNumber.text,
      'Full House Address': address.text,
      'pincode': pincode.text,
    });
  }

 void determinePosition() async{
   bool serviceEnabled;
   LocationPermission permission;

   serviceEnabled = await Geolocator.isLocationServiceEnabled();
   if(!serviceEnabled){
     return Future.error('Location services are disabled');
   }
   permission = await Geolocator.checkPermission();
   if(permission == LocationPermission.denied){
     permission = await Geolocator.requestPermission();
     if(permission == LocationPermission.denied){
       return Future.error("Location permissions are denied!");
     }
   }
   if(permission == LocationPermission.deniedForever){
     return Future.error("Location permissions are permanently denied!, we cannot request permission");
   }
   Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

   List<Placemark> placemarks = await placemarkFromCoordinates(
       position.latitude, position.longitude);

   Placemark placemark = placemarks[0];
   String currentAddress =
       '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';

   address.text = currentAddress;

   String postalcode = '${placemark.postalCode}';
   pincode.text = postalcode;

 }

  List<Step> stepList() => [
        Step(
          state: _activeStepIndex <= 0 ? StepState.editing : StepState.complete,
          isActive: _activeStepIndex >= 0,
          title: const Text('Account'),
          content: Container(
            child: Column(
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    fillColor:Color.fromARGB(255, 67, 160, 71),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 67, 160, 71)
                      )
                    ),
                    labelText: 'Full Name',
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                
                TextField(
                  controller: email,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 67, 160, 71)
                        )
                    ),
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                                TextField(
                  controller: PhoneNumber,
                  decoration: const InputDecoration(
                    fillColor:Color.fromARGB(255, 67, 160, 71),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 67, 160, 71)
                        )
                    ),
                    labelText: 'Phone Number',
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        ),
        Step(
            state:
                _activeStepIndex <= 1 ? StepState.editing : StepState.complete,
            isActive: _activeStepIndex >= 1,
            title: const Text('Address'),
            content: Container(
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.my_location, color: Color.fromARGB(255, 67, 160, 71), size: 20,),
                      const SizedBox(width: 3,),
                      InkWell(
                          onTap: (){
                            determinePosition();
                          },
                          child: const Text("Use my location", style: TextStyle(fontWeight: FontWeight.bold),))
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextField(
                    controller: address,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 67, 160, 71)
                          )
                      ),
                      labelText: 'Full House Address',
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextField(
                    controller: pincode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 67, 160, 71)
                          )
                      ),
                      labelText: 'Pin Code',
                    ),
                  ),
                ],
              ),
            )),
        Step(
            state: StepState.complete,
            isActive: _activeStepIndex >= 2,
            title: const Text('Confirm'),
            content: Container(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Name: ${name.text}'),
                Text('Email: ${email.text}'),
                Text('PhoneNumber: ${PhoneNumber.text}'),
                Text('Address : ${address.text}'),
                Text('PinCode : ${pincode.text}'),
              ],
            )))
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LainDain"),
        backgroundColor: const Color.fromARGB(255, 67, 160, 71),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color.fromARGB(255, 67, 160, 71))
        ),
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _activeStepIndex,
          steps: stepList(),
          onStepContinue: () {
            if (_activeStepIndex < (stepList().length - 1)) {
              setState(() {
                _activeStepIndex += 1;
              });
            } else {
              print('Submited');
              saveBuyerDetails();
              Navigator.push(context, MaterialPageRoute(builder: (context)=>NotificationScreen()));
            }
          },
          onStepCancel: () {
            if (_activeStepIndex == 0) {
              return;
            }

            setState(() {
              _activeStepIndex -= 1;
            });
          },
          onStepTapped: (int index) {
            setState(() {
              _activeStepIndex = index;
            });
          },
        ),
      ),
    );
  }
}