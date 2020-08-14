import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'home.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage>{
  @override
  initState() {
    Fluttertoast.showToast(
      msg: 'Finding User Login Status',
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
    Timer(Duration(seconds: 5), loadLoginHomeScreen);
    super.initState();
  }
  
  Future loadLoginHomeScreen() async {
    FirebaseAuth.instance.currentUser().then((currentUser) => {
          if (currentUser == null)
            {
              print('user not found go to login page'),
              Fluttertoast.showToast(
                msg: 'You are not logged in',
                backgroundColor: Colors.black,
                textColor: Colors.white,
              ),
              Navigator.pushReplacementNamed(context, "/login")
            }
            
          else
            {
              print('find user'),
              Fluttertoast.showToast(
                    msg: 'Successfully logged in as ${currentUser.email}',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
              ),
              Firestore.instance
                  .collection("users")
                  .document(currentUser.uid)
                  .get()
                  .then((DocumentSnapshot result) => {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(
                            userName: result["fullname"],
                            uid: currentUser.uid,
                            userPic: result["profilepic"]),
                      )
                    )
                  })
                  .catchError((errorMsg) => print(errorMsg)),
                  
              print('found user home page logged in')
            }
            
        });
  }

@override
  Widget build(BuildContext context) {
      return Scaffold(
        body: Stack(
          children: <Widget>[
            topText(context),
            logoImage(),
            bottomText(context),
            subtitle(context),
            indicator(),
            loading(context),
          ],
        ),
      );
}

  Align topText(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 100.0),
        child: Text(
          'Welcome To',
          style: TextStyle(
              fontSize: 35.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor),
          textAlign: TextAlign.center,
          softWrap: true,
        ),
      ),
    );
  }

  Align logoImage() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 130.0),
        child: Image(
          image: AssetImage('images/logo.png'),
          height: 250,
          width: 250,
        ),
      ),
    );
  }

  Align bottomText(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 350.0),
        child: Text(
          'HealthyBub',
          style: TextStyle(
              fontSize: 45.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor),
          textAlign: TextAlign.center,
          softWrap: true,
        ),
      ),
    );
  }

  Align subtitle(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 450.0),
        child: Text(
          'Your Friendly Patient Health Manager',
          style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor),
          textAlign: TextAlign.center,
          softWrap: true,
        ),
      ),
    );
  }

  Align indicator() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 500.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Align loading(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 550.0),
        child: Text(
          'Loading...',
          style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor),
          textAlign: TextAlign.center,
          softWrap: true,
        ),
      ),
    );
  }
}
