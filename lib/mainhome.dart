import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'todo.dart';
//import 'Tickets.dart';
import 'dart:ui' as ui;
//import 'FoodPage.dart';
//import 'CinemaPage.dart';
//import 'TransportationPage.dart';
//import 'DeliveryPage.dart';
//import 'package:flutter/services.dart';
import 'LoginPage.dart';
import 'users.dart';
import 'dart:convert';
import 'package:http/http.dart' as http ;
//import 'main.dart';
//import 'MovieDetail.dart';

class MainHome extends StatefulWidget {
  MainHome({this.auth,this.userId, this.onSignedOut});

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new MainHomeState();
  //MainHomeState createState() => MainHomeState();
}

class MainHomeState extends State<MainHome> {

  String transportOne = 'Accra   >>>>>   Kumasi';
  String transportTwo = 'Accra   >>>>>   Cape Coast';
  String transportThree = 'Accra   >>>>>   Takoradi';
  String transportFour = 'Accra   >>>>>   Suyani';
  String transportFive = 'Accra   >>>>>   Ho';

  String foodOne = 'Fried Rice with Grilled Chicken';
  String foodTwo = 'Jollof rice with Chicken ';
  String foodThree = 'Fries with Chicken Wings';
  String foodFour = 'Meat-Lovers Pizza';
  String foodFive = 'Banku with Tilapia';

  @override
  var movies;
  Color mainColor = const Color(0xff3C3261);

  void getData() async {
    var data = await getJson();
    setState(() {
      movies = data['results'];
    });
  }


  List<Todo> _todoList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _todoQuery;

 int _currentIndex = 0;

 Widget callPage(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return _servicePage();
      case 1:
        return _proFile();

        break;
      default:
        return _servicePage();
    }
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    _todoList = new List();
    _todoQuery = _database
        .reference()
        .child("todo")
        .orderByChild("userId")
        .equalTo(widget.userId);
    _onTodoAddedSubscription = _todoQuery.onChildAdded.listen(_onEntryAdded);
    _onTodoChangedSubscription = _todoQuery.onChildChanged.listen(_onEntryChanged);
  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  _onEntryChanged(Event event) {
    var oldEntry = _todoList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _todoList[_todoList.indexOf(oldEntry)] = Todo.fromSnapshot(event.snapshot);
    });
  }

  _onEntryAdded(Event event) {
    setState(() {
      _todoList.add(Todo.fromSnapshot(event.snapshot));
    });
  }


  _addNewTodo(String todoItem) {
    if (todoItem.length > 0) {

      Todo todo = new Todo(todoItem.toString(), widget.userId, false);
      _database.reference().child("todo").push().set(todo.toJson());
    }
  }

  _updateTodo(Todo todo){
    //Toggle completed
    todo.completed = !todo.completed;
    if (todo != null) {
      _database.reference().child("todo").child(todo.key).set(todo.toJson());
    }
  }

  _deleteTodo(String todoId, int index) {
    _database.reference().child("todo").child(todoId).remove().then((_) {
      print("Delete $todoId successful");
      setState(() {
        _todoList.removeAt(index);
      });
    });
  }

  _showTransportTicketDialog(String location) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new Text(
                      'Do you want to buy Ticket',
                    )
                )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Buy'),
                  onPressed: () {
                    _addNewTodo(location.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        }
    );
  }

  _showMovieTicketDialog(String title) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new Text(
                      'Do you want to buy Movie Ticket',
                    )
                )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Buy'),
                  onPressed: () {
                    _addNewTodo(title.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        }
    );
  }

  _showFoodTicketDialog(String food) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new Text(
                      'Do you want to buy Ticket',
                    )
                )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Buy'),
                  onPressed: () {
                    _addNewTodo(food.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        }
    );
  }


  Widget _showTicketList() {
    if (_todoList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _todoList.length,
          itemBuilder: (BuildContext context, int index) {
            String todoId = _todoList[index].key;
            String subject = _todoList[index].subject;
            bool completed = _todoList[index].completed;
            String userId = _todoList[index].userId;
            return Dismissible(
              key: Key(todoId),
              background: Container(color: Colors.red),
              onDismissed: (direction) async {
                _deleteTodo(todoId, index);
              },
              child: ListTile(
                title: Text(
                  subject,
                  style: TextStyle(fontSize: 20.0),
                ),
                trailing: IconButton(
                    icon: (completed)
                        ? Icon(
                      Icons.done_outline,
                      color: Colors.green,
                      size: 20.0,
                    )
                        : Icon(Icons.done, color: Colors.grey, size: 20.0),
                    onPressed: () {
                      _updateTodo(_todoList[index]);
                    }),
              ),
            );
          });
    } else {
      return Center(child: Text("Welcome. Your list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),));
    }
  }

  Widget _showUsername() {

    if (_todoList.length > 0) {
      return ListView.builder(
          itemCount: _todoList.length,
      itemBuilder: (BuildContext context, int index) {
        String todoId = _todoList[index].key;
        String subject = _todoList[index].subject;
        bool completed = _todoList[index].completed;
        String userId = _todoList[index].userId;

        return Text("   Welcome " +  subject,
          style: new TextStyle(color: Colors.white ,fontFamily: 'Arvo',
              fontWeight: FontWeight.bold,fontStyle: FontStyle.italic)
          ,);



      });
    } else {
      return Center(child: Text("Welcome. Your list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),));
    }

  }



  Widget _showContact() {
   {
      return Container(
        color: Colors.white,
        margin: const EdgeInsets.all(2.0),
        child: Column(
          children: <Widget>[
            new ListTile(
                leading: Icon(Icons.call),
                title: Text('Contact 0248560299 for delivery within Accra'),
                onTap: () {}
            ),
            Container(
              width: 300.0,
              height: 0.5,
              color: const Color(0xD2D2E1ff),
              margin: const EdgeInsets.fromLTRB(4.0,0.0,4.0,0.0),
            ),
            new ListTile(
                leading: Icon(Icons.call),
                title: Text('Contact 055560255 for delivery outside Accra'),
                onTap: () {}
            ),
            Container(
              width: 300.0,
              height: 0.5,
              color: const Color(0xD2D2E1ff),
              margin: const EdgeInsets.fromLTRB(4.0,0.0,4.0,0.0),
            ),

          ],
        ),
      );
    }
  }


  Widget _proFile() {

        return new Scaffold(

          body: new Container(
            color: Colors.white,

            child: new Column(
              children: <Widget>[

                Expanded(
                  flex: 3, // 40%
                  child: Container(
                      color: Color(0xff01A0C7),

                      child: new Column(
                        children: <Widget>[


                          Expanded(flex: 3,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                              color: Color(0xff01A0C7),
                              child: Center(
                                child: _showUsername(),
                              ),
                            ),
                          ),

                          Expanded(flex: 7,
                            child: Container(
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: 50.0,
                                child: Icon(Icons.person, size: 100.0, color: Colors.white.withOpacity(0.5) ,  ),
                              ),
                            ),
                          ),




                        ],
                      )

                  ),
                ),


                Expanded(
                  flex: 6, // 60%
                  child: Container(
                    color: Colors.white,
                    margin: const EdgeInsets.all(2.0),
                    child: Column(
                      children: <Widget>[
                        new ListTile(
                          leading: Icon(Icons.confirmation_number),
                          title: Text('My Tickets'),
                          onTap: () => _tickEts(context)
                        ),
                        Container(
                          width: 300.0,
                          height: 0.5,
                          color: const Color(0xD2D2E1ff),
                          margin: const EdgeInsets.fromLTRB(4.0,0.0,4.0,0.0),
                        ),
                        new ListTile(
                          leading: Icon(Icons.call),
                          title: Text('Contact us'),
                            onTap: () => _contactUs(context)
                        ),
                        Container(
                          width: 300.0,
                          height: 0.5,
                          color: const Color(0xD2D2E1ff),
                          margin: const EdgeInsets.fromLTRB(4.0,0.0,4.0,0.0),
                        ),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );



  }


  Widget _servicePage() {

    _moviePage (BuildContext context) async {

      await showDialog(
          context: context,
          builder: (BuildContext context){
            return new Scaffold(

                appBar: new AppBar(
                  centerTitle: true,
                  backgroundColor: Color(0xff01A0C7),
                  title: new Text(
                    ' Cinema ',
                    style: new TextStyle(color: Colors.white,
                      fontFamily: 'Arvo',
                      fontWeight: FontWeight.bold,),
                  ),

                ),

                body: new Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new MovieTitle(mainColor),
                      new Expanded(
                        child: new ListView.builder(
                            itemCount: movies == null ? 0 : movies.length,
                            itemBuilder: (context, i) {
                              return  new FlatButton(

                                child: new MovieCell(movies,i),
                                padding: const EdgeInsets.all(0.0),
                                onPressed: () => _movieDetails(movies[i])/*{
                                  Navigator.push(context, new MaterialPageRoute(builder: (context){
                                    return new MovieDetail(movies[i]);
                                  }));
                                },*/
                                //color: Colors.white,
                              );           }),
                      )
                    ],
                  ),
                )


            );

          }
      );

    }

    _transportationPage(BuildContext context) async {
      await showDialog(
          context: context,
          builder: (BuildContext context) {

            return new Scaffold(

              appBar: new AppBar(
                centerTitle: true,
                backgroundColor: Color(0xff01A0C7),
                title: new Text(
                  ' Transportation Service ',
                  style: new TextStyle(color: Colors.white,
                    fontFamily: 'Arvo',
                    fontWeight: FontWeight.bold,),
                ),

              ),


              body: new Container(
                child: SingleChildScrollView(
                  child: new Column(
                    children: <Widget>[
                      new GestureDetector(
                        child: new Row(
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: new Container(
                                margin: const EdgeInsets.all(16.0),
                                child: new Container(
                                  width: 70.0,
                                  height: 70.0,
                                ),
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  image: new DecorationImage(
                                      image: new AssetImage(
                                          'assets/location.jpg'),
                                      fit: BoxFit.cover),
                                  boxShadow: [
                                    new BoxShadow(
                                        color: mainColor,
                                        blurRadius: 5.0,
                                        offset: new Offset(2.0, 5.0))
                                  ],
                                ),
                              ),
                            ),
                            new Expanded(
                                child: new Container(
                                  margin: const
                                  EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                  child: new Column(children: [
                                    new Text(
                                      transportOne + ' 45GHC',
                                      style: new TextStyle(
                                          fontSize: 20.0,
                                          fontFamily: 'Arvo',
                                          fontWeight: FontWeight.bold,
                                          color: mainColor),
                                    ),
                                  ],
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,),
                                )
                            ),
                          ],
                        ),
                          onTap: () => _showTransportTicketDialog(transportOne.toString())
                      ),
                      new Container(
                        width: 300.0,
                        height: 0.5,
                        color: const Color(0xD2D2E1ff),
                        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      ),

                      new GestureDetector(
                        child: new Row(
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: new Container(
                                margin: const EdgeInsets.all(16.0),
                                child: new Container(
                                  width: 70.0,
                                  height: 70.0,
                                ),
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  image: new DecorationImage(
                                      image: new AssetImage(
                                          'assets/location.jpg'),
                                      fit: BoxFit.cover),
                                  boxShadow: [
                                    new BoxShadow(
                                        color: mainColor,
                                        blurRadius: 5.0,
                                        offset: new Offset(2.0, 5.0))
                                  ],
                                ),
                              ),
                            ),
                            new Expanded(
                                child: new Container(
                                  margin: const
                                  EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                  child: new Column(children: [
                                    new Text(
                                      transportTwo + ' 30GHC',
                                      style: new TextStyle(
                                          fontSize: 20.0,
                                          fontFamily: 'Arvo',
                                          fontWeight: FontWeight.bold,
                                          color: mainColor),
                                    ),
                                  ],
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,),
                                )
                            ),
                          ],
                        ),
                          onTap: () => _showTransportTicketDialog(transportTwo.toString())
                      ),
                      new Container(
                        width: 300.0,
                        height: 0.5,
                        color: const Color(0xD2D2E1ff),
                        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      ),

                      new GestureDetector(
                        child: new Row(
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: new Container(
                                margin: const EdgeInsets.all(16.0),
                                child: new Container(
                                  width: 70.0,
                                  height: 70.0,
                                ),
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  image: new DecorationImage(
                                      image: new AssetImage(
                                          'assets/location.jpg'),
                                      fit: BoxFit.cover),
                                  boxShadow: [
                                    new BoxShadow(
                                        color: mainColor,
                                        blurRadius: 5.0,
                                        offset: new Offset(2.0, 5.0))
                                  ],
                                ),
                              ),
                            ),
                            new Expanded(
                                child: new Container(
                                  margin: const
                                  EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                  child: new Column(children: [
                                    new Text(
                                      transportThree + ' 40GHC',
                                      style: new TextStyle(
                                          fontSize: 20.0,
                                          fontFamily: 'Arvo',
                                          fontWeight: FontWeight.bold,
                                          color: mainColor),
                                    ),
                                  ],
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,),
                                )
                            ),
                          ],
                        ),
                          onTap:() => _showTransportTicketDialog(transportThree.toString())
                      ),
                      new Container(
                        width: 300.0,
                        height: 0.5,
                        color: const Color(0xD2D2E1ff),
                        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      ),

                      new GestureDetector(
                        child: new Row(
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: new Container(
                                margin: const EdgeInsets.all(16.0),
                                child: new Container(
                                  width: 70.0,
                                  height: 70.0,
                                ),
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  image: new DecorationImage(
                                      image: new AssetImage(
                                          'assets/location.jpg'),
                                      fit: BoxFit.cover),
                                  boxShadow: [
                                    new BoxShadow(
                                        color: mainColor,
                                        blurRadius: 5.0,
                                        offset: new Offset(2.0, 5.0))
                                  ],
                                ),
                              ),
                            ),
                            new Expanded(
                                child: new Container(
                                  margin: const
                                  EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                  child: new Column(children: [
                                    new Text(
                                      transportFour + ' 55GHC',
                                      style: new TextStyle(
                                          fontSize: 20.0,
                                          fontFamily: 'Arvo',
                                          fontWeight: FontWeight.bold,
                                          color: mainColor),
                                    ),
                                  ],
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,),
                                )
                            ),
                          ],
                        ),
                          onTap: () => _showTransportTicketDialog(transportFour.toString())
                      ),
                      new Container(
                        width: 300.0,
                        height: 0.5,
                        color: const Color(0xD2D2E1ff),
                        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      ),

                      new GestureDetector(
                        child: new Row(
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: new Container(
                                margin: const EdgeInsets.all(16.0),
                                child: new Container(
                                  width: 70.0,
                                  height: 70.0,
                                ),
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  image: new DecorationImage(
                                      image: new AssetImage(
                                          'assets/location.jpg'),
                                      fit: BoxFit.cover),
                                  boxShadow: [
                                    new BoxShadow(
                                        color: mainColor,
                                        blurRadius: 5.0,
                                        offset: new Offset(2.0, 5.0))
                                  ],
                                ),
                              ),
                            ),
                            new Expanded(
                                child: new Container(
                                  margin: const
                                  EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                  child: new Column(children: [
                                    new Text(
                                      transportFive + ' 40GHC',
                                      style: new TextStyle(
                                          fontSize: 20.0,
                                          fontFamily: 'Arvo',
                                          fontWeight: FontWeight.bold,
                                          color: mainColor),
                                    ),
                                  ],
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,),
                                )
                            ),
                          ],
                        ),
                        onTap: () => _showFoodTicketDialog(transportFive.toString()),
                      ),
                      new Container(
                        width: 300.0,
                        height: 0.5,
                        color: const Color(0xD2D2E1ff),
                        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      ),

                    ],
                  ),
                ),
            )


            );
          }
      );
    }

    _foodPage(BuildContext context) async {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return new Scaffold(

              appBar: new AppBar(
                centerTitle: true,
                backgroundColor: Color(0xff01A0C7),
                title: new Text(
                  ' Food Service ',
                  style: new TextStyle(color: Colors.white,
                    fontFamily: 'Arvo',
                    fontWeight: FontWeight.bold,),
                ),

              ),

              body: new Container(

                child:SingleChildScrollView(
                  child: new Column(
                    children: <Widget>[
                      new GestureDetector(
                        child: new Row(
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: new Container(
                                margin: const EdgeInsets.all(16.0),
                                child: new Container(
                                  width: 70.0,
                                  height: 70.0,
                                ),
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  image: new DecorationImage(
                                      image: new AssetImage(
                                          'assets/Friedrice&grilledchicken.jpg'),
                                      fit: BoxFit.cover),
                                  boxShadow: [
                                    new BoxShadow(
                                        color: mainColor,
                                        blurRadius: 5.0,
                                        offset: new Offset(2.0, 5.0))
                                  ],
                                ),
                              ),
                            ),
                            new Expanded(
                                child: new Container(
                                  margin: const
                                  EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                  child: new Column(children: [
                                    new Text(
                                      foodOne + ' 25GHC',
                                      style: new TextStyle(
                                          fontSize: 20.0,
                                          fontFamily: 'Arvo',
                                          fontWeight: FontWeight.bold,
                                          color: mainColor),
                                    ),
                                  ],
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,),
                                )
                            ),
                          ],
                        ),
                        onTap: () => _showFoodTicketDialog(foodOne.toString()),
                      ),
                      new Container(
                        width: 300.0,
                        height: 0.5,
                        color: const Color(0xD2D2E1ff),
                        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      ),

                      new GestureDetector(
                        child: new Row(
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: new Container(
                                margin: const EdgeInsets.all(16.0),
                                child: new Container(
                                  width: 70.0,
                                  height: 70.0,
                                ),
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  image: new DecorationImage(
                                      image: new AssetImage(
                                          'assets/jollof&chicken.jpg'),
                                      fit: BoxFit.cover),
                                  boxShadow: [
                                    new BoxShadow(
                                        color: mainColor,
                                        blurRadius: 5.0,
                                        offset: new Offset(2.0, 5.0))
                                  ],
                                ),
                              ),
                            ),
                            new Expanded(
                                child: new Container(
                                  margin: const
                                  EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                  child: new Column(children: [
                                    new Text(
                                      foodTwo + ' 30GHC',
                                      style: new TextStyle(
                                          fontSize: 20.0,
                                          fontFamily: 'Arvo',
                                          fontWeight: FontWeight.bold,
                                          color: mainColor),
                                    ),
                                  ],
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,),
                                )
                            ),
                          ],
                        ),
                        onTap: () => _showFoodTicketDialog(foodTwo.toString()),
                      ),
                      new Container(
                        width: 300.0,
                        height: 0.5,
                        color: const Color(0xD2D2E1ff),
                        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      ),

                      new GestureDetector(
                        child: new Row(
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: new Container(
                                margin: const EdgeInsets.all(16.0),
                                child: new Container(
                                  width: 70.0,
                                  height: 70.0,
                                ),
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  image: new DecorationImage(
                                      image: new AssetImage(
                                          'assets/fries&chickenwings.jpg'),
                                      fit: BoxFit.cover),
                                  boxShadow: [
                                    new BoxShadow(
                                        color: mainColor,
                                        blurRadius: 5.0,
                                        offset: new Offset(2.0, 5.0))
                                  ],
                                ),
                              ),
                            ),
                            new Expanded(
                                child: new Container(
                                  margin: const
                                  EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                  child: new Column(children: [
                                    new Text(
                                      foodThree + ' 20GHC',
                                      style: new TextStyle(
                                          fontSize: 20.0,
                                          fontFamily: 'Arvo',
                                          fontWeight: FontWeight.bold,
                                          color: mainColor),
                                    ),
                                  ],
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,),
                                )
                            ),
                          ],
                        ),
                        onTap: () =>
                            _showFoodTicketDialog(foodThree.toString()),
                      ),
                      new Container(
                        width: 300.0,
                        height: 0.5,
                        color: const Color(0xD2D2E1ff),
                        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      ),

                      new GestureDetector(
                        child: new Row(
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: new Container(
                                margin: const EdgeInsets.all(16.0),
                                child: new Container(
                                  width: 70.0,
                                  height: 70.0,
                                ),
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  image: new DecorationImage(
                                      image: new AssetImage(
                                          'assets/meatloverspizza.jpg'),
                                      fit: BoxFit.cover),
                                  boxShadow: [
                                    new BoxShadow(
                                        color: mainColor,
                                        blurRadius: 5.0,
                                        offset: new Offset(2.0, 5.0))
                                  ],
                                ),
                              ),
                            ),
                            new Expanded(
                                child: new Container(
                                  margin: const
                                  EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                  child: new Column(children: [
                                    new Text(
                                      foodFour + ' 40GHC',
                                      style: new TextStyle(
                                          fontSize: 20.0,
                                          fontFamily: 'Arvo',
                                          fontWeight: FontWeight.bold,
                                          color: mainColor),
                                    ),
                                  ],
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,),
                                )
                            ),
                          ],
                        ),
                        onTap: () => _showFoodTicketDialog(foodFour.toString()),
                      ),
                      new Container(
                        width: 300.0,
                        height: 0.5,
                        color: const Color(0xD2D2E1ff),
                        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      ),

                      new GestureDetector(
                        child: new Row(
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: new Container(
                                margin: const EdgeInsets.all(16.0),
                                child: new Container(
                                  width: 70.0,
                                  height: 70.0,
                                ),
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  image: new DecorationImage(
                                      image: new AssetImage(
                                          'assets/BankuTilapia.jpg'),
                                      fit: BoxFit.cover),
                                  boxShadow: [
                                    new BoxShadow(
                                        color: mainColor,
                                        blurRadius: 5.0,
                                        offset: new Offset(2.0, 5.0))
                                  ],
                                ),
                              ),
                            ),
                            new Expanded(
                                child: new Container(
                                  margin: const
                                  EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                  child: new Column(children: [
                                    new Text(
                                      foodFive + ' 20GHC',
                                      style: new TextStyle(
                                          fontSize: 20.0,
                                          fontFamily: 'Arvo',
                                          fontWeight: FontWeight.bold,
                                          color: mainColor),
                                    ),
                                  ],
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,),
                                )
                            ),
                          ],
                        ),
                        onTap: () => _showFoodTicketDialog(foodFive.toString()),
                      ),
                      new Container(
                        width: 300.0,
                        height: 0.5,
                        color: const Color(0xD2D2E1ff),
                        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      ),

                    ],
                  ),
                ),



              ),




            );
          }
      );
    }

    _deliveryPage(BuildContext context) async {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return new Scaffold(

              appBar: new AppBar(
                centerTitle: true,
                backgroundColor: Color(0xff01A0C7),
                title: new Text(
                  ' Delivery Service ',
                  style: new TextStyle(color: Colors.white,
                    fontFamily: 'Arvo',
                    fontWeight: FontWeight.bold,),
                ),

              ),

              body: new Container(
                color: Colors.white,
                margin: const EdgeInsets.all(2.0),
                child: Column(
                  children: <Widget>[
                    new ListTile(
                      leading: Icon(Icons.place),
                      title: Text('Within Accra'),
                      subtitle: Text("charge based on destination in Accra"),
                      trailing: Icon(Icons.keyboard_arrow_right),
                      contentPadding: EdgeInsets.fromLTRB(
                          5.0, 10.0, 20.0, 10.0),
                        onTap: () => _showContact()
                    ),
                    Container(
                      width: 400.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
                    ),
                    new ListTile(
                      leading: Icon(Icons.place),
                      title: Text('Outside Accra'),
                      subtitle: Text(
                          "charge based on destination outside Accra"),
                      trailing: Icon(Icons.keyboard_arrow_right),
                      contentPadding: EdgeInsets.fromLTRB(
                          1.0, 10.0, 10.0, 10.0),
                        onTap: () => _showContact()
                    ),
                    Container(
                      width: 400.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
                    ),


                  ],
                ),
              ),


            );
          }
      );
    }


      return new Scaffold(

          body:

          new GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20.0),
            crossAxisSpacing: 10.0,
            crossAxisCount: 2,

            children: <Widget>[

              new GestureDetector(
                child: new Card(
                  color: Color(0xff01A0C7),
                  elevation: 5.0,
                  child: new Container(
                      alignment: Alignment.centerLeft,
                      margin: new EdgeInsets.only(
                          top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        verticalDirection: VerticalDirection.down,
                        children: <Widget>[
                          new Icon(
                            Icons.movie, size: 100.0, color: Colors.white,),
                          new Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Text('Cinema', style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.8))),
                              ],
                            ),
                          )
                        ],
                      )
                  ),
                ),
                onTap:() => _moviePage(context) /*{

                  Navigator.push(context, new MaterialPageRoute(
                      builder: (context) =>
                      new CinemaPage())
                  );

                },*/
              ),

              new GestureDetector(
                  child: new Card(
                    color: Color(0xff01A0C7),
                    elevation: 5.0,
                    child: new Container(
                        alignment: Alignment.centerLeft,
                        margin: new EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          verticalDirection: VerticalDirection.down,
                          children: <Widget>[
                            new Icon(Icons.directions_bus, size: 100.0,
                              color: Colors.white,),
                            new Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text('Bus Transportation',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white.withOpacity(
                                              0.8))),
                                ],
                              ),
                            )
                          ],
                        )
                    ),
                  ),
                  onTap: () => _transportationPage(context)
              ),

              new GestureDetector(
                  child: new Card(
                    color: Color(0xff01A0C7),
                    elevation: 5.0,
                    child: new Container(
                        alignment: Alignment.centerLeft,
                        margin: new EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          verticalDirection: VerticalDirection.down,
                          children: <Widget>[
                            new Icon(Icons.fastfood, size: 100.0,
                              color: Colors.white,),
                            new Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text('Food', style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withOpacity(0.8))),
                                ],
                              ),
                            )
                          ],
                        )
                    ),
                  ),

                  onTap: () => _foodPage(context)

              ),

              new GestureDetector(
                  child: new Card(
                    color: Color(0xff01A0C7),
                    elevation: 5.0,
                    child: new Container(
                        alignment: Alignment.centerLeft,
                        margin: new EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          verticalDirection: VerticalDirection.down,
                          children: <Widget>[
                            new Icon(Icons.motorcycle, size: 100.0,
                              color: Colors.white,),
                            new Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text('Courier', style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withOpacity(0.8))),
                                ],
                              ),
                            )
                          ],
                        )
                    ),
                  ),
                  onTap: () => _deliveryPage(context)
              ),

            ],
          )
      );

  }

  _tickEts (BuildContext context) async {

    await showDialog(
        context: context,
        builder: (BuildContext context){
          return new Scaffold(
            appBar: new AppBar(
              centerTitle: true,
              backgroundColor: Color(0xff01A0C7),
              title: new Text(
                ' Tickets ',
                style: new TextStyle(color: Colors.white,
                  fontFamily: 'Arvo',
                  fontWeight: FontWeight.bold,),
              ),

            ),

            body:  _showTicketList(),


          );

        }
    );

  }

  _contactUs (BuildContext context) async {

    await showDialog(
        context: context,
        builder: (BuildContext context){
          return new Scaffold(
            appBar: new AppBar(
              centerTitle: true,
              backgroundColor: Color(0xff01A0C7),
              title: new Text(
                ' Contact Us ',
                style: new TextStyle(color: Colors.white,
                  fontFamily: 'Arvo',
                  fontWeight: FontWeight.bold,),
              ),

            ),

            body:  _showContact(),


          );

        }
    );

  }

  Future<Map> getJson() async {
    var url = 'http://api.themoviedb.org/3/movie/now_playing?api_key=4d9f16101775dd8297a527c24262292e';

    http.Response response = await http.get(url);
    return json.decode(response.body);
  }


  _movieDetails (movie) async {
    var image_url = 'https://image.tmdb.org/t/p/w500/';
    await showDialog(
        context: context,
        builder: (BuildContext context){

          return new Scaffold(


              body: new Container(
                child: new Column(
                  children: <Widget>[

                    Expanded(
                      flex: 4, // 40%

                      child: new Stack(
                        fit: StackFit.expand,
                        children: <Widget>[

                          new SizedBox.expand(
                            child: new Image.network(
                              image_url + movie['poster_path'],
                              fit: BoxFit.fill,
                            ),
                          ),

                          new BackdropFilter(
                            filter: new ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                            child: new Container(
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),

                          new Container(
                            child: new Row(
                              children: <Widget>[
                                new Expanded(
                                    flex: 5,
                                    child: new Image.network(
                                      image_url + movie['poster_path'],
                                    )
                                ),
                                new Expanded(
                                    flex: 5,
                                    child: Container(
                                      child: new Column(
                                        children: <Widget>[
                                          new ListTile(
                                            title: Text(movie['title'],style: new TextStyle(color: Colors.white,fontSize: 20.0,fontFamily: 'Arvo')),
                                          ),
                                          new ListTile(
                                            title: Text('${movie['vote_average']}/10',style: new TextStyle(color: Colors.white,fontSize: 20.0,fontFamily: 'Arvo')),
                                          ),
                                        ],
                                      ),
                                    ),
                                    /*child: new Text(
                                      '${movie['vote_average']}/10',
                                      style: new TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontFamily: 'Arvo'),
                                    )*/
                                )
                              ],
                            ),
                          )


                        ],
                      ),

                    ),


                    Expanded(
                      flex: 2, // 40%
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                        color: Colors.white,
                        child: new Column(
                          children: <Widget>[
                            new Expanded(
                                flex: 2,
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: new Text(
                                      'Trailer',
                                      style: new TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Arvo'),
                                      textAlign: TextAlign.left,
                                    ))),
                            new Expanded(
                              flex: 8,
                              child: Container(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3, // 40%
                      child: new Container(
                        margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                        child: new Column(
                          children: <Widget>[
                            new Expanded(
                                flex: 2,
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: new Text(
                                      movie['title'],
                                      style: new TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Arvo'),
                                      textAlign: TextAlign.left,
                                    ))),
                            new Expanded(
                              flex: 8,
                              child: new Text(movie['overview'],
                                  style: new TextStyle(
                                      color: Colors.black, fontFamily: 'Arvo')),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1, // 40%
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            flex: 9,
                            child: new RaisedButton(
                                color: Colors.redAccent,
                                child: new Text('Book',
                                    style: new TextStyle(
                                        fontSize: 20.0, color: Colors.white)),
                                onPressed: () => _showMovieTicketDialog(movie['title'].toString())
                                ),
                          ),
                          Expanded(
                            flex: 1,
                            child: new RaisedButton(
                                color: Colors.redAccent,
                                child: new Text('',
                                    style: new TextStyle(
                                        fontSize: 20.0, color: Colors.white)),
                                onPressed: () {}),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )

          );

        }
    );

  }









  @override
  Widget build(BuildContext context) {
    getData();
    return new MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
            length: 3,
            child: new Scaffold(
              appBar: new AppBar(
                centerTitle: true,
                backgroundColor: Color(0xff01A0C7),
                title: new Text(
                  ' SERVICES  ',
                  style: new TextStyle(color: Colors.white,
                    fontFamily: 'Arvo',
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,),
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text('Logout', style: new TextStyle(
                        fontSize: 17.0, color: Colors.white)),
                    onPressed: _signOut,
                  )
                ],
              ),


              body: callPage(_currentIndex),


              bottomNavigationBar: BottomNavigationBar(

                currentIndex: _currentIndex,
                // this will be set when a new tab is tapped
                onTap: (value) {
                  _currentIndex = value;
                  setState(() {

                  });
                },

                items: [
                  new BottomNavigationBarItem(
                    icon: new Icon(Icons.class_),
                    title: new Text('Services'),
                  ),
                  new BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      title: Text('Profile')
                  )
                ],

              ),


            )
        )
    );
  }



}





/*class CinemaPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }

}*/

/*class _HomePageState extends State<CinemaPage> {
  @override

  var movies;
  Color mainColor = const Color(0xff3C3261);

  void getData() async {
    var data = await getJson();
    setState(() {
      movies = data['results'];
    });
  }


  Widget build(BuildContext context) {
    getData();

    return new Scaffold(

        appBar: new AppBar(
          centerTitle: true,
          backgroundColor: Color(0xff01A0C7),
          title: new Text(
            ' Cinema ',
            style: new TextStyle(color: Colors.white,
              fontFamily: 'Arvo',
              fontWeight: FontWeight.bold,),
          ),

        ),

        body: new Padding(
          padding: const EdgeInsets.all(1.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new MovieTitle(mainColor),
              new Expanded(
                child: new ListView.builder(
                    itemCount: movies == null ? 0 : movies.length,
                    itemBuilder: (context, i) {
                      return  new FlatButton(

                        child: new MovieCell(movies,i),
                        padding: const EdgeInsets.all(0.0),
                        onPressed: (){
                          Navigator.push(context, new MaterialPageRoute(builder: (context){
                            return new MovieDetail(movies[i]);
                          }));
                        },
                        color: Colors.white,
                      );           }),
              )
            ],
          ),
        )


    );

  }

}*/


/*class MovieDetail extends StatelessWidget {
  final movie;
  var image_url = 'https://image.tmdb.org/t/p/w500/';

  MovieDetail(this.movie);

  Color mainColor = const Color(0xff01A0C7);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(


        body: new Container(
          child: new Column(
            children: <Widget>[

              Expanded(
                flex: 4, // 40%

                child: new Stack(
                  fit: StackFit.expand,
                  children: <Widget>[

                    new SizedBox.expand(
                      child: new Image.network(
                        image_url + movie['poster_path'],
                        fit: BoxFit.fill,
                      ),
                    ),

                    new BackdropFilter(
                      filter: new ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: new Container(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),

                    new Container(
                      child: new Row(
                        children: <Widget>[
                          new Expanded(
                              flex: 5,
                              child: new Image.network(
                                image_url + movie['poster_path'],
                              )
                          ),
                          new Expanded(
                              flex: 5,
                              child: new Text(
                                '${movie['vote_average']}/10',
                                style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontFamily: 'Arvo'),
                              )
                          )
                        ],
                      ),
                    )


                  ],
                ),

              ),


              Expanded(
                flex: 2, // 40%
                child: Container(
                  margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  color: Colors.white,
                  child: new Column(
                    children: <Widget>[
                      new Expanded(
                          flex: 2,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: new Text(
                                'Trailer',
                                style: new TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Arvo'),
                                textAlign: TextAlign.left,
                              ))),
                      new Expanded(
                        flex: 8,
                        child: Container(),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3, // 40%
                child: new Container(
                  margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  child: new Column(
                    children: <Widget>[
                      new Expanded(
                          flex: 2,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: new Text(
                                movie['title'],
                                style: new TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Arvo'),
                                textAlign: TextAlign.left,
                              ))),
                      new Expanded(
                        flex: 8,
                        child: new Text(movie['overview'],
                            style: new TextStyle(
                                color: Colors.black, fontFamily: 'Arvo')),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1, // 40%
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 9,
                      child: new RaisedButton(
                          color: Colors.redAccent,
                          child: new Text('Book',
                              style: new TextStyle(
                                  fontSize: 20.0, color: Colors.white)),
                          onPressed: () {}),
                    ),
                    Expanded(
                      flex: 1,
                      child: new RaisedButton(
                          color: Colors.redAccent,
                          child: new Text('',
                              style: new TextStyle(
                                  fontSize: 20.0, color: Colors.white)),
                          onPressed: () {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )

    );
  }
}*/



class MovieTitle extends StatelessWidget{

  final Color mainColor;

  MovieTitle(this.mainColor);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
      child: new Text(
        'Now Showing',
        style: new TextStyle(
            fontSize: 16.0,
            color: mainColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arvo'
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

}

Future<Map> getJson() async {
  var url = 'http://api.themoviedb.org/3/movie/now_playing?api_key=4d9f16101775dd8297a527c24262292e';

  http.Response response = await http.get(url);
  return json.decode(response.body);
}

class MovieCell extends StatelessWidget{

  final movies;
  final i;
  Color mainColor = const Color(0xff01A0C7);
  var image_url = 'https://image.tmdb.org/t/p/w500/';
  MovieCell(this.movies,this.i);

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(0.0),
              child: new Container(
                margin: const EdgeInsets.all(16.0),
                child: new Container(
                  width: 70.0,
                  height: 70.0,
                ),
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.circular(10.0),
                  color: Colors.white ,
                  image: new DecorationImage(
                      image: new NetworkImage(
                          image_url + movies[i]['poster_path']),
                      fit: BoxFit.cover),
                  boxShadow: [
                    new BoxShadow(
                        color: mainColor,
                        blurRadius: 5.0,
                        offset: new Offset(2.0, 5.0))
                  ],
                ),
              ),
            ),
            new Expanded(

                child: new Container(
                  margin: const      EdgeInsets.fromLTRB(8.0,0.0,8.0,0.0),
                  child: new Column(children: [
                    new Text(
                      movies[i]['title'],
                      style: new TextStyle(
                          fontSize: 20.0,
                          fontFamily: 'Arvo',
                          fontWeight: FontWeight.bold,
                          color: mainColor),
                    ),
                    new Padding(padding: const EdgeInsets.all(2.0)),
                    new Text(movies[i]['overview'],
                      maxLines: 3,
                      style: new TextStyle(
                          color: const Color(0xff8785A4),
                          fontFamily: 'Arvo'
                      ),)
                  ],
                    crossAxisAlignment: CrossAxisAlignment.start,),
                )
            ),
          ],
        ),
        new Container(
          width: 300.0,
          height: 0.5,
          color: const Color(0xD2D2E1ff),
          margin: const EdgeInsets.fromLTRB(16.0,8.0,16.0,8.0),
        )
      ],
    );

  }

}
