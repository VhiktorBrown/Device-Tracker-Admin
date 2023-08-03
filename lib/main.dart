import 'package:flutter/material.dart';
import 'package:device_tracker_admin/screens/home_screen.dart';
import 'package:device_tracker_admin/utils/routes.dart';
import 'package:device_tracker_admin/utils/theme.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Device Tracker Admin',
      theme: theme(),
      initialRoute: HomeScreen.routeName,
      routes: routes,
    );
  }
}

