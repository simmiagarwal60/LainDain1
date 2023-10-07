import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // late GoogleMapController googleMapController;
  // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  // late Position position;
  //
  // void getMarkers(double lat, double long){
  //   MarkerId markerId = MarkerId(lat.toString()+ long.toString());
  //   Marker _marker = Marker(
  //     markerId: markerId,
  //     position: LatLng(lat, long),
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
  //     infoWindow: InfoWindow(snippet: 'Address'),
  //   );
  //   setState(() {
  //     markers[markerId] = _marker;
  //   });
  // }
  // void getCurrentLocation() async{
  //   Position currentPosition = await GeolocatorPlatform.instance.getCurrentPosition();
  //   setState(() {
  //     position = currentPosition;
  //   });
  // }
  final Completer<GoogleMapController> _controller = Completer();
  List<Marker> markers = [];
  List<Marker> list = [
    const Marker(
      markerId: MarkerId('1'),
      position: LatLng(20.5937, 78.9629),
      infoWindow: InfoWindow(
        title: "My Position"
      ),
    )
  ];

  @override
  void initState(){
    super.initState();
    markers.addAll(list);
  }


  static const CameraPosition _kGooglePlex = CameraPosition(target: LatLng(20.5937, 78.9629),
  zoom: 14);

  loadData(){
    getUserCurrentLocation().then((value) async{
      print("My current Location");
      print("${value.longitude} ${value.latitude}");

      markers.add(
          Marker(
              markerId: const MarkerId('2'),
              position: LatLng(value.latitude, value.longitude),
              infoWindow:const InfoWindow(title: "My current Location"))
      );

      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude),
          zoom: 14
      );

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    });
  }

  Future<Position> getUserCurrentLocation() async{
    await Geolocator.requestPermission().then((value){

    }).onError((error, stackTrace) {
      print(error.toString());
    });

    return await Geolocator.getCurrentPosition();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              const SizedBox(height: 600,),
              GoogleMap(initialCameraPosition: _kGooglePlex,
              onTap: (tapped){
                //getMarkers(tapped.latitude, tapped.longitude);
              },
              onMapCreated: (GoogleMapController controller){
                _controller.complete(controller);
              },
              myLocationEnabled: true,
              compassEnabled: false,
              mapType: MapType.hybrid,
              markers: Set<Marker>.of(markers),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          loadData();
        },
        child: const Icon(Icons.local_activity),
      ),
    );
  }
}
