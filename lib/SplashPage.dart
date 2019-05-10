import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class SplashPage extends StatefulWidget {

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  void navigationToNextPage() {
    Navigator.pushReplacementNamed(context, '/LoginPage');
  }

  startSplashScreenTimer() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, navigationToNextPage);
  }

  @override
  void initState() {
    super.initState();
    startSplashScreenTimer();
  }

  @override
  Widget build(BuildContext context) {

    // To make this screen full screen.
    // It will hide status bar and notch.
    //SystemChrome.setEnabledSystemUIOverlays([]);

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    // full screen image for splash screen.
    return Container(
        padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        color: Colors.white,
        //padding: EdgeInsets.all(20.0),
         child: Image.asset('assets/clogo.jpg'),

    );
  }
}


