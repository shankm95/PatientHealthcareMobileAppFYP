import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'updateAppointment.dart';


class Appointment extends StatelessWidget {
  Appointment({@required this.uid, this.document, this.appointmentDate, this.appointmentTime, 
              this.serviceType, this.hospital, this.referredBy, this.doctor, this.description});
  final String uid;
  final document;
  final appointmentDate;
  final appointmentTime;
  final serviceType;
  final hospital;
  final referredBy;
  final doctor;
  final description;

  Future deleteAppt(BuildContext context) async{
    Firestore.instance
          .collection("users")
          .document(uid)
          .collection("appointments")
          .document(document.documentID)
          .delete()
          .then((result){
            print("Appointment deleted: $appointmentDate $appointmentTime $serviceType $hospital $referredBy $doctor $description" );
          })
          .catchError((error) => print(error));
    Fluttertoast.showToast(
      msg: "Appointment Cancelled",
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {

      return Container(
        padding: const EdgeInsets.only(top: 5.0),
        foregroundDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(),
            bottom: BorderSide(),
            left: BorderSide(),
            right: BorderSide()
          )
        ),
        height: 233,
        child: Column(
          children: <Widget>[
            row1(),
            spacingContainer(10, null),
            row2(),
            spacingContainer(10, null),
            row3(context),
            spacingContainer(10, null),
            row4(context)
          ],
        )
      );
  }

  Row row1(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        appointmentDateDisplay(),
        spacingContainer(null, 20),
        appointmentTimeDisplay(),
      ],
    );
  }

  Row row2(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        serviceTypeDisplay(),
        spacingContainer(null, 20),
        referredByDisplay(),
      ],
    );
  }

  Row row3(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        doctorNameDisplay(),
        spacingContainer(null, 20),
        showDetailsBtn(context),
      ],
    );
  }

  Row row4(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        rescheduleAppointmentBtn(context),
        spacingContainer(null, 20),
        cancelAppointmentBtn(context)
      ],
    );
  }

  RaisedButton showDetailsBtn(BuildContext context){
    return RaisedButton(
      child: Text("See More Details"),
      onPressed: (){
        showDetailsDialog(context);
      }, 
    );
  }

  Future showDetailsDialog(BuildContext context) async{
    await showDialog(
      context: context,
      builder: (context){
        return Dialog(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            hospitalNameDisplay(),
            spacingContainer(10, null),
            descriptionDisplay(),
           ],
          ),
        );
      }
    );
  }

  RaisedButton rescheduleAppointmentBtn(BuildContext context){
    return RaisedButton(
      color: Colors.teal,
      child: Text("Reschedule"),
      onPressed: (){
        Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          UpdateAppointmentPage(uid: uid, document: document, service: serviceType, 
                          hospital: hospital, appointmentDate: appointmentDate, appointmentTime: appointmentTime)
                  )
        );
          print('navigate to update appointment');
      },
    );
  }

  RaisedButton cancelAppointmentBtn(BuildContext context){
    return RaisedButton(
      color: Colors.red,
      child: Text("Cancel"),
      onPressed: (){
        showDialog(
          context: context,
          builder: (BuildContext context){
            return SimpleDialog(
              title: Text("Are you sure you want to cancel appointment?"),
              children: <Widget>[
                SimpleDialogOption(
                  child: Text("Yes"),
                  onPressed: () async{
                    print("Yes");
                    await deleteAppt(context);
                    Navigator.of(context).pop();
                  },
                ),
                SimpleDialogOption(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.pop(context,true);
                  },
                )
              ],
            );
          }
        );
      },
    );
  }

  Column appointmentDateDisplay(){
    return Column(
      children: <Widget>[
        Text("Appointment Date",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
        Text(appointmentDate)
      ],
    );
  }

  Column appointmentTimeDisplay(){
    return Column(
      children: <Widget>[
        Text("Appointment Time",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
        Text(appointmentTime)
      ],
    );
  }

  Column serviceTypeDisplay(){
    return Column(
      children: <Widget>[
        Text("Type of Service",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
        Text(serviceType)
      ],
    );
  }

  Column referredByDisplay(){
    return Column(
      children: <Widget>[
        Text("Referred By",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
        Text(referredBy)
      ],
    );
  }

  Column doctorNameDisplay(){
    return Column(
      children: <Widget>[
        Text("Doctor Name",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
        Text(doctor)
      ],
    );
  }

  Column hospitalNameDisplay(){
    return Column(
      children: <Widget>[
        Text("Preferred Hospital",
              style:TextStyle(fontWeight: FontWeight.bold),
            ),
        getHospNames()
      ],
    );
  }

  getHospNames(){
    List<Widget> textList = new List<Widget>();
    for(var name in hospital){
      textList.add(new Text(name));
    }
    return new Column(children: textList);
  }

  Column descriptionDisplay(){
    return Column(
      children: <Widget>[
        Text("Description",
              style:TextStyle(fontWeight: FontWeight.bold),
            ),
        Text(description)
      ],
    );
  }

  Container spacingContainer(double h, double w){
    return Container(height: h, width: w,);
  }

}
