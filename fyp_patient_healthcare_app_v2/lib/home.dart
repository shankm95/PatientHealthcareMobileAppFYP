import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'manageAppointment.dart';
import 'manageMedReminder.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.userName, this.uid, this.userPic}) : super(key: key);
  final String userName;
  final String uid;
  final dynamic userPic;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  FirebaseUser currentUser;
  dynamic drawerUserPic;

  @override
  initState() {
    drawerUserPic = widget.userPic;
    this.getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    currentUser = await FirebaseAuth.instance.currentUser();
  }

  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Home Main Menu"),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              Container(
                height: 300,
                child: DrawerHeader(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      pictureDisplay(),
                      Container(
                        height: 25,
                      ),
                      Text(widget.userName)
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey
                  ),
                  margin: EdgeInsets.all(0),
                  padding: EdgeInsets.all(0),
                )
              ),
              editProfileBtn(),
              Container(
                height: 20,
              ),
              logOutBtn()
            ],
          ),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              manageAppointment(),
              manageMedReminder(),
              managePrescriptions()
            ],
          ),
        ),
      );

  }

  CircleAvatar pictureDisplay(){
    return CircleAvatar(
      radius: 100,
      backgroundColor: Colors.blue,
      child: ClipOval(
        child: new SizedBox(
          width: 190.0,
          height: 190.0,
          child: Image.network('$drawerUserPic'),
        ),
      ),
    );
  }

  OutlineButton editProfileBtn(){
    return OutlineButton(
            child: Text("Edit Profile"),
            borderSide: BorderSide(
              color: Colors.blueGrey,
              width: 2),
            highlightedBorderColor: Colors.black,
            onPressed: (){
              Fluttertoast.showToast(msg: "Future Implementation");
            },
    );
  }

  OutlineButton logOutBtn(){
    return OutlineButton(
            child: Text("Log Out"),
            borderSide: BorderSide(
              color: Colors.blueGrey,
              width: 2),
            highlightedBorderColor: Colors.black,
            onPressed: (){
              FirebaseAuth.instance
                            .signOut()
                            .then((result) => Navigator.pushReplacementNamed(context, "/login"))
                            .catchError((errorMsg) => print(errorMsg));
                            setState(() {
                              print('logged out of home page');
                              Fluttertoast.showToast(
                                msg: "Successfully logged out",
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                              );
                            });
            },
    );
  }

  Padding manageAppointment() {
    return Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: ButtonTheme(
          height: 50,
          child: RaisedButton(
            color: Colors.amber,
            child: Text('Track & manage medical appointments'),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ManageAppointmentPage(uid: widget.uid)
                  )
              );
              print('go to manage appointment page');
            },
          ),
        )
    );
  }

  Padding manageMedReminder() {
    return Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: ButtonTheme(
          height: 50,
          child: RaisedButton(
            color: Colors.amber,
            child: Text('Manage timely notifications for medicine reminder'),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ManageMedReminderPage(uid: widget.uid)
                  )
              );
              print('go to manage med reminder page');
            },
          ),
        )
    );
  }

  Padding managePrescriptions() {
    return Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: ButtonTheme(
          height: 50,
          child: RaisedButton(
            color: Colors.amber,
            child: Text('Track medicine prescriptions'),
            onPressed: () {
              Fluttertoast.showToast(msg: "Future Implementation");
            },
          ),
        )
    );
  }
}
