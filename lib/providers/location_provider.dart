import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider with ChangeNotifier{
  double? latitude;
  double? longitude;
  bool permissionAllowed = false;

  Future<void> getCurrentPosition() async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if(position!=null){
      latitude = position.latitude;
      longitude = position.longitude;
      permissionAllowed = true;
      notifyListeners();
    }
    else{
      print('Permission not allowed!');
    }
  }
}