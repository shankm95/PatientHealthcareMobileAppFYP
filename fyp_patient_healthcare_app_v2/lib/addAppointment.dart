import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:grouped_buttons/grouped_buttons.dart';

class AddAppointmentPage extends StatefulWidget {
  AddAppointmentPage({Key key, this.uid}) : super(key: key);
  final String uid;

  @override
  AddAppointmentPageState createState() => AddAppointmentPageState();
}

class AddAppointmentPageState extends State<AddAppointmentPage> {
  final GlobalKey<FormState> _addAppointmentFormKey = GlobalKey<FormState>();
  TextEditingController medSymDescriptionInputControl;
  TextEditingController docNameInputControl;
  DateTime apptDateInputControl;
  String apptDateOutput;
  String errorMsg;
  String dropDownTOS;
  String dropDownApptTime;
  String referredByPicked;
  List<String> preferredHospitalPicked;

  @override
  initState() {
    medSymDescriptionInputControl = new TextEditingController();
    docNameInputControl = new TextEditingController();
    super.initState();
  }

  String validateDocName(String value) {
    Pattern pattern =r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]';
    RegExp regex = new RegExp(pattern);
    /*
    if (value.trim().isEmpty) {
      return "Doctor name shouldn't be empty";
    } else 
    */
    if (regex.hasMatch(value)) {
      return 'Doctor name is invalid';
    } else {
      return null;
    }
  }

  Future createNewAppt(BuildContext context) async {
    Firestore.instance
          .collection("users")
          .document(widget.uid)
          .collection("appointments")
          .add({
            "appointmentID"    :Firestore.instance.collection("users").document(widget.uid).collection("appointments").document().documentID,
            "appointmentDate"  :apptDateOutput,
            "appointmentTime"  :dropDownApptTime,
            "referredBy"       :referredByPicked,
            "typeOfService"    :dropDownTOS,
            "preferredHospital":preferredHospitalPicked,
            "doctorName"       :checkDocName(docNameInputControl.text.toString()),
            "description"      :medSymDescriptionInputControl.text.toString()
          })
          .then((result) => {
            print("New Appointment Booked " + apptDateOutput + " " + dropDownApptTime + " " + referredByPicked + 
                  " " + dropDownTOS + " " + preferredHospitalPicked.toString() + " " + docNameInputControl.text.toString()),
          })
          .catchError((error) => print(error));
          setState(() {
            Fluttertoast.showToast(
              msg: "Appointment Booked on $apptDateOutput at $dropDownApptTime",
              backgroundColor: Colors.black,
              textColor: Colors.white,
            );
          });
  }

  String checkDocName(String value){
    if(docNameInputControl.text.endsWith("Dr.") || docNameInputControl.text.isEmpty){
      return value = "Not Assigned";
    }else{
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.of(context).pop();
            },
            tooltip: "Go back to Manage Appointments",),
            title: Text("Add Appointment"),
        ),
        body: Container(
          padding: const EdgeInsets.all(5.0),
          child: SingleChildScrollView(
            child: Form(
              key: _addAppointmentFormKey,
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  referredPerson(),
                  medSymtomDescription(),
                  chosenHospitalList(),
                  registerDocName(),
                  typeOfService(),
                  chooseApptDate(),
                  chooseApptTime(),
                  addApptBtn(context),
                ]
              )
            )
          )
        ),
      );
  }

  Padding referredPerson(){
    return Padding(
      padding: const EdgeInsets.only(top:1.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Referred By* : "),
          RadioButtonGroup(
            orientation: GroupedButtonsOrientation.VERTICAL,
            labels: <String>[
              "GP / Family Doctor",
              "Specialist",
              "Myself",
            ],
            onSelected: (String selected) => setState((){
              referredByPicked = selected;
              print(referredByPicked);
            }),
            picked: referredByPicked,
          )
        ],
      ),
    );
  }

  Padding medSymtomDescription(){
    return Padding(
      padding: const EdgeInsets.only(top:150.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Provide brief description of medical condition/symptom"),
          Container(
            height: 200,
            foregroundDecoration: BoxDecoration(
              border: Border(
                top: BorderSide(),
                bottom: BorderSide(),
                left: BorderSide(),
                right: BorderSide()
              )
            ),
            child: Scrollbar(
                child: SingleChildScrollView(
                  child: TextFormField(
                    controller: medSymDescriptionInputControl,
                    keyboardType: TextInputType.multiline,
                    maxLines: 20,
                  ),
                ),
              ),
          )
        ],
      ),
    );
  }

  Padding chosenHospitalList(){
    return Padding(
      padding: const EdgeInsets.only(top:420.0),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Preferred Hospital* :"),
          CheckboxGroup(
            orientation: GroupedButtonsOrientation.VERTICAL,
            labels: <String>['Singapore General Hospital','Changi General Hospital','Alexandra Hospital','Khoo Teck Puat Hospital','Tan Tock Seng Hospital'],
            onSelected: (List<String> selected){
              setState(() {
                preferredHospitalPicked = selected;
                print(preferredHospitalPicked);
              });
            },
            checked: preferredHospitalPicked,
          ),
        ]
      ),
    );
  }

  Padding registerDocName() {
    return Padding(
      padding: const EdgeInsets.only(top: 680.0),
      child: TextFormField(
        decoration:InputDecoration(
          labelText: 'Name of Preferred Doctor', 
          hintText: "Isabelle Tan",
        ),
        controller: docNameInputControl,
        keyboardType: TextInputType.text,
        validator: validateDocName,
        //onTap: () => docNameInputControl.text = "Dr.",
      ),
    );
  }

  Padding typeOfService() {
    return Padding(
      padding: const EdgeInsets.only(top: 790.0),
      child: Column(
        children: <Widget>[
          Text("Type of Service* "),
          Container(
            width: 20,
          ),
          SizedBox(
            height:80,
            width: 250,
            child: DropdownButtonFormField(
              value: dropDownTOS,
              items: <String>['Cardiology', 'Dentistry', 'Dermatology', 'Emergency Medicine','Others']
                      .map<DropdownMenuItem<String>>((String value){
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(), 
              onChanged: (String newValue){
                setState(() {
                  dropDownTOS = newValue;
                  print(dropDownTOS);
                });
              },
              autovalidate: true,
              isExpanded: false,
              hint: Text("Choose 1 Service"),
            ),
          )
        ],
      )
    );
  }

  Padding chooseApptDate(){
    return Padding(
      padding: const EdgeInsets.only(top: 890.0),
        child: Column(
          children: [
            Text('Appointment Date*'),
            apptDateButton(),
          ],
        )
    );
  }

  RaisedButton apptDateButton() {
    return RaisedButton(
      child: Text(apptDateInputControl == null ? 'Set Appointment Date' : '$apptDateOutput'),
      onPressed: () {
        showDatePicker(
                context: context,
                initialDate:apptDateInputControl == null ? DateTime.now() : apptDateInputControl,
                firstDate: DateTime(1920),
                lastDate: DateTime(2120))
            .then((date) {
          setState(() {
            apptDateInputControl = date;
            apptDateOutput = new DateFormat.yMMMd().format(apptDateInputControl);
          });
        });
      },
    );
  }

  Padding chooseApptTime() {
    return Padding(
      padding: const EdgeInsets.only(top: 970.0),
      child: Column(
        children: <Widget>[
          Text("Appointment Time* "),
          Container(
            width: 20,
          ),
          SizedBox(
            height:75,
            width: 222,
            child: DropdownButtonFormField(
              value: dropDownApptTime,
              items: <String>['8am','9am','10am','11am','1pm','2pm','3pm','4pm']
                      .map<DropdownMenuItem<String>>((String value){
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(), 
              onChanged: (String newValue){
                setState(() {
                  dropDownApptTime = newValue;
                  print(dropDownApptTime);
                });
              },
              autovalidate: true,
              isExpanded: false,
              hint: Text("Choose Appt Time"),

            ),
          )
        ],
      )
    );
  }

  Padding addApptBtn(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(top: 1050.0),
      child: ButtonTheme(
        minWidth: 200,
        height: 50,
        child: RaisedButton(
          color: Colors.cyan,
          child: Text(
            'Book Appointment',
            style: TextStyle(
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
                color: Colors.white
            ),
          ),
          onPressed: () {
              if (_addAppointmentFormKey.currentState.validate()) {
                if (apptDateInputControl != null && medSymDescriptionInputControl.text.isNotEmpty && preferredHospitalPicked.isNotEmpty 
                && dropDownTOS.isNotEmpty && dropDownApptTime.isNotEmpty && referredByPicked.isNotEmpty) {
                  createNewAppt(context);
                  Navigator.of(context).pop();
              } else if (apptDateInputControl == null || medSymDescriptionInputControl.text.isEmpty || preferredHospitalPicked.isEmpty 
              || dropDownTOS.isEmpty || dropDownApptTime.isEmpty || referredByPicked.isEmpty){
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text("Book Appointment can't be added without filling the necessary fields"),
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
              }
            }
          },
        ),
      ),
    );
  }
    
}