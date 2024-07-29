import 'package:flutter/material.dart';
import 'package:poc_wgj/screens/calling.dart';
import 'package:poc_wgj/screens/contacts.dart';
import 'package:poc_wgj/screens/home.dart';
import 'package:poc_wgj/screens/loading.dart';

class AppRoutes {
  static const String home = '/';
  static const String loading = '/loading';
  static const String calling = '/calling';
  static const String contacts = '/contacts';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const Home());
      case loading:
        return MaterialPageRoute(builder: (_) => const Loading());
      case calling:
        return MaterialPageRoute(builder: (_) => const Calling());
      case contacts:
        return MaterialPageRoute(builder: (_) => Contacts());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
