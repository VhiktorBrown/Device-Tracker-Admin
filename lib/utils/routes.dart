import 'package:device_tracker_admin/screens/home_screen.dart';
import 'package:device_tracker_admin/screens/map_screen.dart';
import 'package:flutter/cupertino.dart';

final Map<String, WidgetBuilder> routes = {
  HomeScreen.routeName: (context) => const HomeScreen(),
  MapScreen.routeName: (context) => const MapScreen(),
};