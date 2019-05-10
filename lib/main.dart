import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'SplashPage.dart';
//import 'CinemaPage.dart';
//import 'Profile.dart';
import 'root_page.dart';
import 'auth.dart';
import 'mainhome.dart';
//import 'Tickets.dart';
//import 'ServicePage.dart';
//import 'TransportationPage.dart';
//import 'FoodPage.dart';
//import 'DeliveryPage.dart';
//import 'amz.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinema Project',
      debugShowCheckedModeBanner: false,
      home: new SplashPage(),
      routes: <String, WidgetBuilder>{
        '/mainhome': (BuildContext context) => new MainHome(),
        //'/Profile': (BuildContext context) => new Profile(),
        //'/Tickets': (BuildContext context) => new Tickets(),
        //'/ServicePage': (BuildContext context) => new ServicePage(),
        //'/CinemaPage': (BuildContext context) => new CinemaPage(),
        //'/TransportationPage': (BuildContext context) => new TransportationPage(),
        //'/FoodPage': (BuildContext context) => new FoodPage(),
        //'/New': (BuildContext context) => new New(),
        //'/DeliveryPage': (BuildContext context) => new DeliveryPage(),
        '/LoginPage': (BuildContext context) => new RootPage(auth: new Auth()),

      },
    );
  }
}


