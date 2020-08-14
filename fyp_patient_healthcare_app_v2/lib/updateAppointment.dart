import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UpdateAppointmentPage extends StatefulWidget {
  UpdateAppointmentPage({Key key, this.uid, this.document, this.service, this.hospital, this.appointmentDate, this.appointmentTime}) : super(key: key);
  final String uid;
  final document;
  final service;
  final hospital;
  final appointmentDate;
  final appointmentTime;

  @override
  UpdateAppointmentPageState createState() => UpdateAppointmentPageState();
}

class UpdateAppointmentPageState extends State<UpdateAppointmentPage> {
  final GlobalKey<FormState> _updateAppointmentFormKey = GlobalKey<FormState>();
  DateTime apptDateInputControl;
  String apptDateOutput;
  String errorMsg;
  String dropDownApptTime;

  @override
  initState() {
    super.initState();
  }

  Future rescheduleAppt(BuildContext context) async {
    Firestore.instance
          .collection("users")
          .document(widget.uid)
          .collection("appointments")
          .document(widget.document.documentID)
          .updateData({
            "appointmentDate"  :apptDateOutput,
            "appointmentTime"  :dropDownApptTime
          })
          .then((result) => {
            print("Re-Scheduled appointment to $apptDateOutput at $dropDownApptTime"),
          })
          .catchError((error) => print(error));
    Fluttertoast.showToast(
      msg: "Appointment Re-scheduled to $apptDateOutput at $dropDownApptTime",
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
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
            title: Text("Reschedule Appointment",
                        style: TextStyle(fontSize: 15),
                      ),
        ),
        body: Container(
          padding: const EdgeInsets.all(5.0),
          child: SingleChildScrollView(
            child: Form(
              key: _updateAppointmentFormKey,
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  typeOfServiceDisplay(),
                  hospital(),
                  originalApptDate(),
                  originalApptTime(),
                  newApptDate(),
                  newApptTime(),
                  rescheduleApptBtn(context)
                ]
              )
            )
          )
        )
      );
  }

Padding typeOfServiceDisplay(){
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        children: <Widget>[
          Text('Type of Service ',
              style: TextStyle(fontWeight: FontWeight.bold)
          ),
          Text(widget.service)
        ],
      ),
    );
  }

Padding hospital(){
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Row(
        children: <Widget>[
          Text('Hosptial Name ',
              style: TextStyle(fontWeight: FontWeight.bold)
          ),
          getHospNames()
        ],
      ),
    );
  }

  getHospNames(){
    List<Widget> textList = new List<Widget>();
    for(var name in widget.hospital){
      textList.add(new Text(name));
    }
    return new Column(children: textList);
  }

Padding originalApptDate(){
    return Padding(
      padding: const EdgeInsets.only(top: 150.0),
      child: Row(
        children: <Widget>[
          Text('Original Appointment Date ',
              style: TextStyle(fontWeight: FontWeight.bold)
          ),
          Text(widget.appointmentDate)
        ],
      ),
    );
  }

  Padding originalApptTime(){
    return Padding(
      padding: const EdgeInsets.only(top: 200.0),
      child: Row(
        children: <Widget>[
          Text('Original Appointment Time ',
              style: TextStyle(fontWeight: FontWeight.bold)
          ),
          Text(widget.appointmentTime)
        ],
      ),
    );
  }

  Padding newApptDate(){
    return Padding(
      padding: const EdgeInsets.only(top: 250.0),
        child: Column(
          children: [
            Text('Choose Appointment Date* '),
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

  Padding newApptTime() {
    return Padding(
      padding: const EdgeInsets.only(top: 350.0),
      child: Column(
        children: <Widget>[
          Text("Choose Appointment Time* "),
          Container(
            width: 20,
          ),
          SizedBox(
            height:75,
            width: 230,
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

  Padding rescheduleApptBtn(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(top: 450.0),
      child: ButtonTheme(
        minWidth: 200,
        height: 50,
        child: RaisedButton(
          color: Colors.cyan,
          child: Text(
            'Re-schedule Appointment',
            style: TextStyle(
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
                color: Colors.white
            ),
          ),
          onPressed: () {
              if (_updateAppointmentFormKey.currentState.validate()) {
                if (apptDateInputControl != null && dropDownApptTime.isNotEmpty) {
                  rescheduleAppt(context);
                  Navigator.of(context).pop();
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text("Appointment can't be rescheduled without filling the necessary fields"),
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