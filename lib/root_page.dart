import 'package:flutter/material.dart';
import 'LoginPage.dart';
//import 'Profile.dart';
import 'auth.dart';
//import 'ServicePage.dart';
import 'mainhome.dart';
//import 'TransportationPage.dart';

class RootPage extends StatefulWidget{
  RootPage({this.auth});
  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();

}

enum AuthStatus{
  notSignedIn,
  signedIn
}

class _RootPageState extends State<RootPage> {

  AuthStatus authStatus = AuthStatus.notSignedIn;
  String _userId = "";
  String _email="";

  initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user){
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus =
        user?.uid == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
       // authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });

    });

  }

  void _signedIn(){
    widget.auth.getCurrentUser().then((user){
      setState(() {
        _userId = user.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.signedIn ;
    });
  }


  void _signedOut(){
    setState(() {
      authStatus = AuthStatus.notSignedIn ;
      _userId = "";
    });
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    switch(authStatus){
      case AuthStatus.notSignedIn:
        return new LoginPage(
          userId: _userId,
          auth: widget.auth,
          onSignedIn: _signedIn,
        );
        break;
      case AuthStatus.signedIn:
        if (_userId.length > 0 && _userId != null) {
          return new MainHome (
            userId: _userId,
            auth: widget.auth,
            onSignedOut: _signedOut,
          );
        } else return _buildWaitingScreen();
        break;

      default:
        return _buildWaitingScreen();
       /* return new MainHome(
          userId: _userId,
          auth: widget.auth,
          onSignedOut: _signedOut,
        );*/



    }



  }

}