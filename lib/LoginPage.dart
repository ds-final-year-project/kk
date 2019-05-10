import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'users.dart';
import 'package:flutter/services.dart';
import 'package:flutter/animation.dart';
import 'mainhome.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.auth, this.userId, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;
  final String userId;

  @override
  State<StatefulWidget> createState() => new LoginPageState();
}

enum FormType{
  login,
  register
}

class LoginPageState extends State<LoginPage> with TickerProviderStateMixin {


  List<Users> _usersList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _usersQuery;


  int _state = 0;
  Animation _animation;
  AnimationController _controller;
  GlobalKey _globalKey = GlobalKey();
  double _width = double.maxFinite;


  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  final formKey = new GlobalKey<FormState>();
  String _email;
  String _password;
  String _username;
  String _phnumber;

  FormType _formType = FormType.login;


  bool validateAndSave(){
    final form = formKey.currentState;
    if (form.validate()){
      form.save();
      return true;
      print('form is valid, Email: $_email');
    }
    return false;
  }

  void validateAndSubmit() async {

    if (validateAndSave()){

      try{

        if (_formType == FormType.login){
          String userId = await widget.auth.signInWithEmailAndPassword(_email,_password);
          //FirebaseUser user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password);
          print('signed in: $userId');
        } else {
          String userId = await widget.auth.createUserWithEmailAndPassword(_username,_phnumber,_email,_password);
          //FirebaseUser user = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password);
          print('registered user: $userId');
        }


        widget.onSignedIn();

      }
      catch(e){
        print('error $e');
      }

    }

  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
    _controller.dispose();
  }

  _onEntryChanged(Event event) {
    var oldEntry = _usersList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _usersList[_usersList.indexOf(oldEntry)] = Users.fromSnapshot(event.snapshot);
    });
  }

  _onEntryAdded(Event event) {
    setState(() {
      _usersList.add(Users.fromSnapshot(event.snapshot));
    });
  }

  void  moveToRegister(){
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }
  void  moveToLogin(){
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }


  @override
  void initState() {
    super.initState();


    _usersList = new List();
    _usersQuery = _database
        .reference()
        .child("Users")
        .orderByChild("userId")
        .equalTo(widget.userId);
    _onTodoAddedSubscription = _usersQuery.onChildAdded.listen(_onEntryAdded);
    _onTodoChangedSubscription = _usersQuery.onChildChanged.listen(_onEntryChanged);
  }



  //var statusClick = 0;

  //AnimationController animationControllerButton;

 /* @override
  void initState(){
    super.initState();
    animationControllerButton = AnimationController(duration: Duration(seconds: 3),vsync: this );
  }*/

 /* @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    animationControllerButton.dispose();
  }

  Future<Null> _playAnimation() async {
    await animationControllerButton.forward();
  } */

  _addNewTodo(String usernameItem, String phoneItem, String emailItem ) {
    if (usernameItem.length > 0) {

      Users users = new Users(usernameItem.toString(),phoneItem.toString(),emailItem.toString(), widget.userId);
      _database.reference().child("users").push().set(users.toJson());
    }
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(

      body: Stack(
        children: <Widget>[

           Container(
              color: Colors.white,
              child: new Form(
                  key: formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(10.0),
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top:50.0),
                              ),
                              Container(
                                child: Column(
                                  children: buildInputs() + buildSubmitButtons(),
                                ),
                              )
                            ],
                          ),

                          /*statusClick == 0
                      ? new InkWell(
                        onTap: (){
                          setState(() {
                            statusClick = 1;
                          });
                          _playAnimation();
                        },
                        child: Column(
                          children: buildSubmitButtons(),
                        )
                      )
                          :new StartAnimation(buttonControler: animationControllerButton.view ,)*/

                        ],
                      )
                    ],



                  )

              )
          ),

           //_showCircularProgress(),


        ],


      )











    );
  }

 /* Widget _showCircularProgress(){
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } return Container(height: 0.0, width: 0.0,);

  }*/


  List<Widget> buildInputs() {

    if (_formType == FormType.login) {
      return [
        new Hero(
          tag: 'hero',
          child: Padding(
            padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 68.0,
              child: Image.asset('assets/loginlogo.jpg'),
            ),
          ),
        ),

        new Container(
          padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
         child: new TextFormField(
            maxLines: 1,
            keyboardType: TextInputType.emailAddress,
            autofocus: false,
            style: style,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                hintText: "Email",
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
            ),
            validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
            onSaved: (value) => _email = value,
          ),
        ),

        new Container(
          padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
          child:  new TextFormField(
            obscureText: true,
            maxLines: 1,
            autofocus: false,
            style: style,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                hintText: "Password",
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
            ),
            validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
            onSaved: (value) => _password = value,
          ),
        ),



      ];
    }
    else {
      return [
        new Hero(
          tag: 'hero',
          child: Padding(
            padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 68.0,
              child: Image.asset('assets/loginlogo.jpg'),
            ),
          ),
        ),




        new Container(
          padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
          child: new TextFormField(
            maxLines: 1,
            keyboardType: TextInputType.text,
            autofocus: false,
            style: style,
            decoration: new InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: 'Username',
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
            ),
            validator: (value) => value.isEmpty ? 'Username can\'t be empty' : null,
            onSaved: (value) => _username = value,
          ),
        ),


        new Container(
          padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
          child: new TextFormField(
            maxLines: 1,
            keyboardType: TextInputType.phone,
            autofocus: false,
            style: style,
            decoration: new InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                hintText: 'Phone',
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
            ),
            validator: (value) => value.isEmpty ? 'Phone Number can\'t be empty' : null,
            onSaved: (value) => _phnumber = value,
          ),
        ),



        new Container(
          padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
          child: new TextFormField(
            maxLines: 1,
            keyboardType: TextInputType.emailAddress,
            autofocus: false,
            style: style,
            decoration: new InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                hintText: 'Email',
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
            ),
            validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
            onSaved: (value) => _email = value,
          ),
        ),


        new Container(
          padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
          child: new TextFormField(
            maxLines: 1,
            obscureText: true,
            autofocus: false,
            style: style,
            decoration: new InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                hintText: 'Password',
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
            ),
            validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
            onSaved: (value) => _password = value,
          ),
        ),

      ];
    }


  }




  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
         new Container(
           padding: const EdgeInsets.fromLTRB(0.0,15.0,0.0,0.0),
          child: Column(
            children: <Widget>[

              /*Align(
                alignment: Alignment.center,
                child: PhysicalModel(
                  elevation: 8,
                  shadowColor: Colors.lightGreenAccent,
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    key: _globalKey,
                    height: 48,
                    width: _width,
                    child: RaisedButton(
                      animationDuration: Duration(milliseconds: 1000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.all(0),
                      child: setUpButtonChild(),
                      onPressed: validateAndSubmit,
                      /*() {
                        setState(() {
                          if (_state == 0) {
                            animateButton();
                          }
                        });
                      },*/
                      elevation: 4,
                      color: Colors.lightGreen,
                    ),
                  ),
                ),
              ),*/


              Container(
                padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                child: new Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30.0),
                  color: Color(0xff01A0C7),
                  child: MaterialButton(
                    minWidth: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    onPressed: validateAndSubmit,
                    child: Text("Sign In",
                        textAlign: TextAlign.center,
                        style: style.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),

              Container(
                alignment: FractionalOffset.center,
                padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                child: new FlatButton(
                  child: new Text(
                    'Create an account', style: new TextStyle(fontSize: 20.0),),
                  onPressed: ()
                  {
                    moveToRegister();

                  }
                ),
              ),
            ],
          ),

        ),

      ];
    } else {
      return [
        new Container(
          padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
          child: new Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(30.0),
            color: Color(0xff01A0C7),
            child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              onPressed: ()
              {
                validateAndSubmit();
                _addNewTodo(_username,_phnumber,_email);
              },
              child: Text("Create Account",
                  textAlign: TextAlign.center,
                  style: style.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),

        new Container(
          padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
          child: new FlatButton(
            child: new Text(
            'Have an account already?' , style: new TextStyle(fontSize: 20.0),),
            onPressed: moveToLogin,
          ),
        ),

      ];
    }

  }

  _nm(){
    String username = _username;
    return username;
  }

 /* setUpButtonChild() {
    if (_state == 0) {
      return Text(
        "Click Here",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      );
    } else if (_state == 1) {
      return SizedBox(
        height: 36,
        width: 36,
        child: CircularProgressIndicator(
          value: null,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      return Icon(Icons.check, color: Colors.white);
    }
  }*/

  void animateButton() {
    double initialWidth = _globalKey.currentContext.size.width;

    _controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    _animation = Tween(begin: 0.0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {
          _width = initialWidth - ((initialWidth - 48) * _animation.value);
        });
      });
    _controller.forward();

    setState(() {
      _state = 1;
    });

    Timer(Duration(milliseconds: 3300), () {
      setState(() {
        _state = 2;
      });
    });
  }






 }









