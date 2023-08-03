import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
class MapScreen extends StatefulWidget {
  static String routeName = "/mapScreen";
  final String? userId;
  const MapScreen({Key? key, this.userId}): super(key: key);

  @override
  State<StatefulWidget> createState() => _MapScreenState();

}

class _MapScreenState extends State<MapScreen> {
  final loc.Location location = loc.Location();
  late GoogleMapController controller;
  bool isAdded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('location').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if(isAdded){
            map(snapshot);
          }
          if(!snapshot.hasData){
            return const Center(child: CircularProgressIndicator(),);
          }
          return GoogleMap(
            mapType: MapType.normal,
              markers: {
              Marker(
                position: LatLng(
                    snapshot.data!.docs.singleWhere(
                            (element) => element.id == widget.userId)['latitude'],
                    snapshot.data!.docs.singleWhere(
                            (element) => element.id == widget.userId)['longitude']
                ),
                markerId: const MarkerId('id'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueMagenta
                )
              )
              },
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                    snapshot.data!.docs.singleWhere(
                            (element) => element.id == widget.userId)['latitude'],
                    snapshot.data!.docs.singleWhere(
                            (element) => element.id == widget.userId)['longitude']
                  ),zoom: 14.47
              ),
            onMapCreated: (GoogleMapController controller)async{
              setState(() {
                this.controller = controller;
                isAdded = true;
              });
            },
          );
        },
      ),
    );
  }

  Future<void> map(AsyncSnapshot<QuerySnapshot> snapshot) async{
    await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(
              snapshot.data!.docs.singleWhere(
                      (element) => element.id == widget.userId)['latitude'],
              snapshot.data!.docs.singleWhere(
                      (element) => element.id == widget.userId)['longitude']
          ), zoom: 14.47
      )
    ));
  }
}