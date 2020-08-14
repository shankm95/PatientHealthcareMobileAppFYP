import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'updateMedReminder.dart';

class MedReminder extends StatelessWidget {
  MedReminder({@required this.uid, this.document, this.medName, this.medTime, this.amtOfDose, this.startDate, this.endDate, this.weekly, this.instructions});
  final String uid;
  final document;
  final medName;
  final medTime;
  final amtOfDose;
  final startDate;
  final endDate;
  final weekly;
  final instructions;

  Future deleteMR(BuildContext context) async{
    Firestore.instance
          .collection("users")
          .document(uid)
          .collection("medicineReminders")
          .document(document.documentID)
          .delete()
          .then((result){
            print("Medicine Reminder Deleted: $medName $medTime $startDate $endDate $weekly $instructions");
          })
          .catchError((error) => print(error));
    Fluttertoast.showToast(
      msg: "Medicine Reminder Deleted",
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );      
  }

@override
  Widget build(BuildContext context) {
        return Container(
          foregroundDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(),
              bottom: BorderSide(),
              left: BorderSide(),
              right: BorderSide()
            )
          ),
          height: 230,
          child: Column(
            children: <Widget>[
              row1(),
              spacingContainer(10, null),
              row2(context),
              spacingContainer(10, null),
              row3(),
              spacingContainer(10, null),
              row4(context),
            ],
          )
        );
  }

  Row row1(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        medicineNameDisplay(),
        spacingContainer(null, 20),
        medTimeDisplay(),
      ],
    );
  }

  Row row2(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        dosageAmtDisplay(),
        spacingContainer(null, 20),
        showDetailsBtn(context),
      ],
    );
  }

  Row row3(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        startDateDisplay(),
        spacingContainer(null, 20),
        endDateDisplay(),
      ],
    );
  }

  Row row4(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        editReminderBtn(context),
        spacingContainer(null, 20),
        deleteReminderBtn(context)
      ],
    );
  }

  Column medicineNameDisplay(){
    return Column(
      children: <Widget>[
        Text("Medicine Name",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
        Text(medName)
      ],
    );
  }

  Column medTimeDisplay(){
    return Column(
      children: <Widget>[
        Text("Time Of Dosage",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
        Text(medTime)
      ],
    );
  }

  Column dosageAmtDisplay(){
    return Column(
      children: <Widget>[
        Text("Amount of Dosage",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
        Text(amtOfDose)
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
           children: <Widget>[
            weekDisplay(),
            spacingContainer(10, null),
            instructionDisplay(),
           ],
          ),
        );
      }
    );
  }

  Column weekDisplay(){
    return Column(
      children: <Widget>[
        Text("Days in Week to Consume",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
        getDaysinWeek()
      ],
    );
  }

  getDaysinWeek(){
    List<Widget> textList = new List<Widget>();
    for(var name in weekly){
      textList.add(new Text(name));
    }
    return new Column(children: textList);
  }

  Column instructionDisplay(){
    return Column(
      children: <Widget>[
        Text("Instructions",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
        Text(instructions)
      ],
    );
  }

  Column startDateDisplay(){
    return Column(
      children: <Widget>[
        Text("Start Date",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
        Text(startDate)
      ],
    );
  }

  Column endDateDisplay(){
    return Column(
      children: <Widget>[
        Text("End Date",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
        Text(endDate)
      ],
    );
  }

  RaisedButton editReminderBtn(BuildContext context){
    return RaisedButton(
      color: Colors.teal,
      child: Text("Edit"),
      onPressed: (){
        Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          UpdateMedReminderPage(uid: uid, document: document, medName: medName, dosageTime: medTime, 
                          startDate: startDate, endDate: endDate, dosageAmt: amtOfDose, week: weekly,)));
          print('navigate to update med reminder');
      },
    );
  }

  RaisedButton deleteReminderBtn(BuildContext context){
    return RaisedButton(
      color: Colors.red,
      child: Text("Delete"),
      onPressed: (){
        showDialog(
          context: context,
          builder: (BuildContext context){
            return SimpleDialog(
              title: Text("Are you sure you want to delete medicine reminder?"),
              children: <Widget>[
                SimpleDialogOption(
                  child: Text("Yes"),
                  onPressed: () async{
                    print("Yes");
                    await deleteMR(context);
                    Navigator.of(context).pop();
                  },
                ),
                SimpleDialogOption(
                  child: Text("No"),
                  onPressed: (){
                    Navigator.pop(context,true);
                  },
                )
              ]
            );
          }
        );
      }
    );
  }

  Container spacingContainer(double h, double w){
    return Container(height: h, width: w,);
  }
}
