import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:move_to_background/move_to_background.dart';
import 'home.dart';


class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  String emailInput, passwordInput, errorMsg;
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  TextEditingController emailInputControl;
  TextEditingController resetPasswordLinkEmailInputControl;
  TextEditingController passwordInputControl;

  @override
  initState() {
    emailInputControl = new TextEditingController();
    passwordInputControl = new TextEditingController();
    resetPasswordLinkEmailInputControl = new TextEditingController();
    super.initState();
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty) {
      return "Email shouldn't be empty";
    } else if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String validatePassword(String value) {
    if ((value.length < 8)&&(value.length >= 1)) {
      return 'Password must be at least 8 characters';
    } else if (value.isEmpty) {
      return "Password shouldn't be empty";
    } else {
      return null;
    }
  }

  bool validateLogin() {
    final form = _loginFormKey.currentState;
    form.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Future loginAccount(BuildContext context) async{
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
          email: emailInputControl.text,
          password: passwordInputControl.text)
        .catchError((onError) async => {
          print(onError),
          setState((){
            errorMsg = onError.message;
          }),
          await showDialog(
            context: context,
            builder: (BuildContext context){
              return AlertDialog(
                title: Text("Error"),
                content: Text(onError.message),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            }
          )
        })
        .then((currentUser) => {
          Firestore.instance
            .collection("users")
            .document(currentUser.user.uid)
            .get()
            .then((DocumentSnapshot result) =>
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    userName: result["fullname"],
                    uid: currentUser.user.uid,
                    userPic: result["profilepic"],
                  )
                )
              )
            )
            .catchError((errorMsg) => print(errorMsg)),
          setState((){
            print("User Logged In");
            Fluttertoast.showToast(
              msg: 'Successfully logged in as $emailInput',
              backgroundColor: Colors.black,
              textColor: Colors.white,
            );
          })
        });
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
          body: WillPopScope(
            child: Container(
              padding: const EdgeInsets.all(1.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _loginFormKey,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        logoImage(),
                        loginEmail(),
                        loginPassword(),
                        loginButton(context),
                        forgotPassword(context),
                        registerUser(),
                      ],
                    ),
                  ),
                ),
            ),
            onWillPop: () async {
              MoveToBackground.moveTaskToBack();
              return true;
            },
          )
        );
  }

  Padding logoImage() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Image(
        image: AssetImage('images/logo.png'),
        height: 250,
        width: 1000,
      ),
    );
  }

  Padding loginEmail() {
    return Padding(
      padding: const EdgeInsets.only(top: 280.0),
      child: TextFormField(
        decoration: InputDecoration(
            labelText: 'Email*', hintText: "john.wick@gmail.com"),
        controller: emailInputControl,
        keyboardType: TextInputType.emailAddress,
        validator: validateEmail,
        onSaved: (input) => emailInput = input,
      ),
    );
  }

  Padding loginPassword() {
    return Padding(
      padding: const EdgeInsets.only(top: 370.0),
      child: TextFormField(
        decoration:
            InputDecoration(labelText: 'Password*', hintText: "********"),
        controller: passwordInputControl,
        obscureText: true,
        validator: validatePassword,
        onSaved: (input) => passwordInput = input,
      ),
    );
  }

  Padding loginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 480.0),
      child: ButtonTheme(
        minWidth: 200,
        height: 50,
        child: RaisedButton(
          color: Colors.cyan,
          child: Text(
            'Login',
            style: TextStyle(
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          onPressed: () {
            if (_loginFormKey.currentState.validate()) {
              _loginFormKey.currentState.save();
              loginAccount(context); 
            } /*
            else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Error"),
                      content: Text("User doesn't exist"),
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  }
              );
            }*/
          },
        ),
      ),
    );
  }

  Padding forgotPassword(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 580.0),
      child: FlatButton(
        onPressed: () {
          showResetPasswordDialog(context);
          print('forgot password');
        },
        child: Text(
          'Forgot Password?',
          style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey),
          textAlign: TextAlign.center,
          softWrap: true,
        ),
      ),
    );
  }

  Future showResetPasswordDialog(BuildContext context) async{
    await showDialog(
      context: context,
      builder: (context){
        return Dialog(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("Type your email to receive password reset link",
              style:TextStyle(fontWeight: FontWeight.bold),
            ),
            emailTextbox(),
            spacingContainer(10, null),
            sendEmailPasswordResetLinkBtn(context)
           ],
          ),
        );
      }
    );
  }

  Padding emailTextbox() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: TextFormField(
        decoration: InputDecoration(
            labelText: 'Email*', 
            hintText: "john.wick@gmail.com"
          ),
        controller: resetPasswordLinkEmailInputControl,
        keyboardType: TextInputType.emailAddress,
        validator: validateEmail,
        onSaved: (input) => emailInput = input,
        autovalidate: true,
      ),
    );
  }

  Padding sendEmailPasswordResetLinkBtn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ButtonTheme(
        minWidth: 200,
        height: 50,
        child: RaisedButton(
          color: Colors.cyan,
          child: Text(
            'Send Password Reset Link',
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white
            ),
          ),
          onPressed: () async {
              FirebaseAuth.instance
                  .sendPasswordResetEmail(email: resetPasswordLinkEmailInputControl.text)
                  .then((value) => {
                    Navigator.of(context).pop(),
                    Fluttertoast.showToast(
                      msg: "Reset Password Link successfully sent to " + resetPasswordLinkEmailInputControl.text.toString(),
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                    )
                  });
          },
        ),
      ),
    );
  }

  Padding registerUser() {
    return Padding(
      padding: const EdgeInsets.only(top: 650.0),
      child: FlatButton(
        onPressed: () {
          Navigator.pushNamed(context, "/register");
          print('register page');
        },
        child: Text(
          'Not a member? Click Here to Register',
          style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey),
          textAlign: TextAlign.center,
          softWrap: true,
        ),
      ),
    );
  }

  Container spacingContainer(double h, double w){
    return Container(height: h, width: w);
  }
}
