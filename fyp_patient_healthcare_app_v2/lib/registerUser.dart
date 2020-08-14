import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key}) : super(key: key);
  
  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  File profilePic;
  String uploadedURL;
  TextEditingController fullNameInputControl;
  TextEditingController emailInputControl;
  DateTime dobInputControl;
  String dobOutput;
  TextEditingController phoneNumberInputControl;
  TextEditingController passwordInputControl;
  TextEditingController confirmPasswordInputControl;
  String genderPicked;
  String errorMsg;

  @override
  initState() {
    fullNameInputControl = new TextEditingController();
    emailInputControl = new TextEditingController();
    phoneNumberInputControl = new TextEditingController();
    passwordInputControl = new TextEditingController();
    confirmPasswordInputControl = new TextEditingController();
    super.initState();
  }

  String validateFullName(String value) {
    Pattern pattern =r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]';
    RegExp regex = new RegExp(pattern);
    if (value.trim().isEmpty) {
      return "Full name shouldn't be empty";
    } else if (regex.hasMatch(value)) {
      return 'Full name is invalid';
    } else {
      return null;
    }
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

  String validateMobile(String value) {
    if ((value.length >= 1)&&(value.length < 8)) {
      return 'Mobile Number must be of 8 digit';
    } else if (value.isEmpty) {
      return "Mobile Number shouldn't be empty";
    } else {
      return null;
    }
  }

  String validatePassword(String value) {
    if ((value.length >= 1)&&(value.length < 8)) {
      return 'Password must be at least 8 characters';
    } else if (value.isEmpty) {
      return "Password shouldn't be empty";
    } else {
      return null;
    }
  }

  Future choosePic() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      profilePic = image;
      print('Image Path $profilePic');
    });
  }

  Future clearProfilePic() async {
    setState(() {
      profilePic = null;
    });
  }

  Future uploadProfilePic() async{
    String fileName = basename(profilePic.path);
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child('${fullNameInputControl.text.toString()} (${emailInputControl.text.toString()}) / $fileName');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(profilePic);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    uploadedURL = await firebaseStorageRef.getDownloadURL();
    print("profile pic uploaded $uploadedURL");
    
    Fluttertoast.showToast(
      msg: "Profile Picture uploaded",
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
    
  }

  Future createNewAccount(BuildContext context) async {
    return FirebaseAuth.instance
        .createUserWithEmailAndPassword(
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
              })
          })
        .then((currentUser) async => {
          await uploadProfilePic(),
          Firestore.instance
              .collection("users")
              .document(currentUser.user.uid)
              .setData({
                "uid"       : currentUser.user.uid,
                "fullname"  : fullNameInputControl.text.toString(),
                "gender"    : genderPicked,
                "email"     : emailInputControl.text.toString(),
                "dob"       : dobOutput,
                "phone"     : phoneNumberInputControl.text.toString(),
                "profilepic": uploadedURL
              }),
          setState(() {
            print("User Account Created " + emailInputControl.text.toString() + " " + passwordInputControl.text.toString() 
                  + " " + fullNameInputControl.text.toString() + " " + phoneNumberInputControl.text.toString() + " " + currentUser.user.uid 
                  + " " + dobOutput + " " + uploadedURL + " " + genderPicked);
          }),
          Fluttertoast.showToast(
              msg: "User Account Created as " + emailInputControl.text.toString(),
              backgroundColor: Colors.black,
              textColor: Colors.white,
            )
        });
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/login");
                print('go back to login');
              }),
          title: Text('Register Page'),
        ),
        body: Container(
          padding: const EdgeInsets.all(5.0),
          child: SingleChildScrollView(
            child: Form(
              key: _registerFormKey,
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  registerPicture(context),
                  registerFullName(),
                  registerEmail(),
                  registerGender(),
                  registerDOB(context),
                  registerPhoneNumber(),
                  registerPassword(),
                  confirmPassword(),
                  tcText(),
                  registerButton(context),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Padding registerPicture(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1.0),
      child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              pictureDisplay(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  chooseFileBtn(),
                  spacingContainer(null, 50),
                  clearProfilePicBtn(),
                ],
              )
            ],
          ),
    );
  }

  CircleAvatar pictureDisplay(){
    return CircleAvatar(
      radius: 70,
      backgroundColor: Colors.blue,
      child: ClipOval(
        child: new SizedBox(
          width: 130.0,
          height: 130.0,
          child: (profilePic!=null) ? 
                  Image.file(
                    profilePic,
                    fit: BoxFit.fill,
                  ):Image.asset(
                    'images/profile.png',
                    fit: BoxFit.fill,
                  ),
        ),
      ),
    );
  }

  RaisedButton chooseFileBtn() {
    return RaisedButton(
      child: Text('Select Picture'),
      onPressed: choosePic,
      color: Colors.cyan,
    );
  }

  RaisedButton clearProfilePicBtn() {
    return RaisedButton(
      child: Text('Clear Profile Pic'),
      onPressed: clearProfilePic,
      color: Colors.blueGrey,
    );
  }

  Padding registerFullName() {
    return Padding(
      padding: const EdgeInsets.only(top: 180.0),
      child: TextFormField(
        decoration:InputDecoration(
          labelText: 'Full Name*', 
          hintText: "John Wick"
        ),
        controller: fullNameInputControl,
        keyboardType: TextInputType.text,
        validator: validateFullName,
      ),
    );
  }

  Padding registerEmail() {
    return Padding(
      padding: const EdgeInsets.only(top: 280.0),
      child: TextFormField(
        decoration: InputDecoration(
            labelText: 'Email*', 
            hintText: "john.wick@gmail.com"
          ),
        controller: emailInputControl,
        keyboardType: TextInputType.emailAddress,
        validator: validateEmail,
      ),
    );
  }

  Padding registerGender(){
    return Padding(
      padding: const EdgeInsets.only(top:390.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Gender* : "),
          RadioButtonGroup(
            orientation: GroupedButtonsOrientation.VERTICAL,
            labels: <String>[
              "Male",
              "Female",
            ],
            onSelected: (String selected) => setState((){
              genderPicked = selected;
              print(genderPicked);
            }),
            picked: genderPicked,
          )
        ],
      ),
    );
  }

  Padding registerDOB(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 480.0),
        child: Row(
          children: [
            Text('Date of Birth* '),
            dobButton(context),
          ],
        )
    );
  }

  RaisedButton dobButton(BuildContext context) {
    //String formattedDOB;
    return RaisedButton(
      child: Text(dobInputControl == null ? 'Tap to Set DOB' : '$dobOutput'),
      onPressed: () {
        showDatePicker(
                context: context,
                initialDate:
                    dobInputControl == null ? DateTime.now() : dobInputControl,
                firstDate: DateTime(1920),
                lastDate: DateTime(2120))
            .then((date) {
          setState(() {
            dobInputControl = date;
            dobOutput = new DateFormat.yMMMd().format(dobInputControl);
          });
        });
      },
    );
  }

  Padding registerPhoneNumber() {
    return Padding(
      padding: const EdgeInsets.only(top: 520.0),
      child: TextFormField(
        decoration:InputDecoration(
          labelText: 'Phone Number*', 
          hintText: "65623535"
        ),
        controller: phoneNumberInputControl,
        keyboardType: TextInputType.phone,
        validator: validateMobile,
      ),
    );
  }

  Padding registerPassword() {
    return Padding(
      padding: const EdgeInsets.only(top: 620.0),
      child: TextFormField(
        decoration:InputDecoration(
          labelText: 'Password*', 
          hintText: "********"
        ),
        controller: passwordInputControl,
        obscureText: true,
        validator: validatePassword,
      ),
    );
  }

  Padding confirmPassword() {
    return Padding(
      padding: const EdgeInsets.only(top: 720.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Confirm Password*', 
          hintText: "********"
        ),
        controller: confirmPasswordInputControl,
        obscureText: true,
        validator: validatePassword,
      ),
    );
  }

  Padding tcText() {
    return Padding(
      padding: const EdgeInsets.only(top: 850.0),
      child: Text(
        'By registering, you agree to the Terms & Conditions',
        style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey),
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    );
  }

  Padding registerButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 900.0),
      child: ButtonTheme(
        minWidth: 200,
        height: 50,
        child: RaisedButton(
          color: Colors.cyan,
          child: Text(
            'Create Account',
            style: TextStyle(
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
                color: Colors.white
            ),
          ),
          onPressed: () async {
              if (_registerFormKey.currentState.validate()) {
                if ((passwordInputControl.text == confirmPasswordInputControl.text) && dobInputControl != null && genderPicked.isNotEmpty) {
                  await createNewAccount(context);
                  Navigator.pushReplacementNamed(context, '/login');
              } else if (passwordInputControl.text != confirmPasswordInputControl.text){
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text("The passwords do not match. Please check & retype correct passwords."),
                        actions: <Widget>[
                          IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    });
                }
                
            }
          },
        ),
      ),
    );
  }

  Container spacingContainer(double h, double w){
    return Container(height: h, width: w);
  }
}