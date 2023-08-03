import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_tracker_admin/utils/colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';


import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/homeScreen";
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.Location>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    //runChecks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallet.kDarkBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const Text(
                "List of Tracked Devices",
                style: TextStyle(
                    color: AppPallet.kPrimaryColor,
                    fontSize: 16
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('location')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<
                      QuerySnapshot<Map<String, dynamic>>> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator(),);
                    }
                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: (){
                              if(snapshot.data!.docs[index]["isTracking"] == true){
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) =>
                                        MapScreen(
                                          userId: snapshot.data!.docs[index]
                                              .id,))
                                );
                              }else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("You can't track this device. It's tracking feature is not on"))
                                );
                              }
                            },
                            title: Text(
                              snapshot.data!.docs[index]['name'].toString(),
                              style: const TextStyle(
                                  color: AppPallet.kTextColor
                              ),),
                            subtitle: Row(
                              children: [
                                Text(snapshot.data!.docs[index]['latitude']
                                    .toString(),
                                  style: const TextStyle(
                                      color: AppPallet.kTextColor
                                  ),
                                ),
                                SizedBox(width: 20,),
                                Text(snapshot.data!.docs[index]['longitude']
                                    .toString(),
                                  style: const TextStyle(
                                      color: AppPallet.kTextColor
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.directions, color: AppPallet.kTextColor,),
                              onPressed: () {
                                if (kDebugMode) {
                                  print(snapshot.data!.docs[index]["isTracking"]);
                                }
                                if(snapshot.data!.docs[index]["isTracking"] == true){
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) =>
                                          MapScreen(
                                            userId: snapshot.data!.docs[index]
                                                .id,))
                                  );
                                }else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("You can't track this device. It's tracking feature is not on"))
                                  );
                                }
                              },
                            ),
                          );
                        }
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

//   getLocation(String deviceName) async{
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     try{
//       final loc.LocationData locationResult = await location.getLocation();
//       await FirebaseFirestore.instance.collection('location').doc(prefs.getString('userId')).set({
//         'latitude': locationResult.latitude,
//         'longitude': locationResult.longitude,
//         'name' : deviceName,
//       }, SetOptions(merge: true));
//     }catch(e){
//       if (kDebugMode) {
//         print(e);
//       }
//     }
//   }
//
//   Future<void> listenForLocation() async{
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     _locationSubscription = location.onLocationChanged.handleError((onError) {
//       print(onError);
//       _locationSubscription?.cancel();
//       setState(() {
//         _locationSubscription = null;
//       });
//     }).listen((loc.LocationData currentLocation) async {
//       await FirebaseFirestore.instance.collection('location').doc(prefs.getString('userId')).set({
//         'latitude': currentLocation.latitude,
//         'longitude': currentLocation.longitude,
//         'name' : await getDeviceName(context),
//       }, SetOptions(merge: true));
//     }) as StreamSubscription<loc.Location>?;
//   }
//
//   stopListening(){
//     _locationSubscription?.cancel();
//     setState(() {
//       _locationSubscription = null;
//     });
//   }
// }

  requestPermissions() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      if (kDebugMode) {
        print('done');
      }
    } else if (status.isDenied) {
      requestPermissions();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  // Future<void> runChecks() async {
  //   if (!await hasOpenedAppBefore()) {
  //     //Generate a unique ID that will not change for user
  //     //This ID will be used to create the Location document on Firestore
  //     generateUniqueId();
  //   }
  // }
  //
  // Future<bool> hasOpenedAppBefore() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool value;
  //   if (prefs.getBool('openedForFirstTime') != null) {
  //     if (prefs.getBool('openedForFirstTime')!) {
  //       value = true;
  //     } else {
  //       value = false;
  //     }
  //   } else {
  //     value = false;
  //   }
  //   if (kDebugMode) {
  //     print(value);
  //   }
  //   return value;
  // }
  //
  // generateUniqueId() async {
  //   String uuid = const Uuid().v4();
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setBool('openedForFirstTime', true);
  //   prefs.setString('userId', uuid);
  //   if (kDebugMode) {
  //     print(uuid);
  //   }
  // }

  Future<String> getDeviceName(BuildContext context) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String model;
    if (Theme
        .of(context)
        .platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      model = androidInfo.model;
    } else if (Theme
        .of(context)
        .platform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      model = iosInfo.name;
    } else {
      model = "Unknown";
    }
    if (kDebugMode) {
      print(model);
    }
    return model;
  }

  Future<
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>> getSingleUserFromList(
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> shot = snapshot;
    for (int i = 0; i < shot.data!.docs.length; i++) {
      if (shot.data!.docs[i].id != prefs.getString('userId')) {
        shot.data!.docs.removeAt(i);
      }
    }
    return shot;
  }
}