import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:grouped_buttons/grouped_buttons.dart';


class AddMedReminderPage extends StatefulWidget {
  AddMedReminderPage({Key key, this.uid}) : super(key: key);
  final String uid;

  @override
  AddMedReminderPageState createState() => AddMedReminderPageState();
}

class AddMedReminderPageState extends State<AddMedReminderPage> {
  final GlobalKey<FormState> _addMedicineReminderFormKey = GlobalKey<FormState>();
  TextEditingController medNameInputControl;
  TextEditingController instructionsInputControl;
  TextEditingController dosageInputControl;
  TimeOfDay doseTimeInputControl;
  String doseTimeOutput;
  DateTime startDateInputControl;
  String startDateOutput;
  DateTime endDateInputControl;
  String endDateOutput;
  String errorMsg;
  List<String> cbgPicked;

  @override
  initState() {
    medNameInputControl = new TextEditingController();
    instructionsInputControl = new TextEditingController();
    dosageInputControl = new TextEditingController();
    super.initState();
  }
  
  String validateMedName(String value) {
    Pattern pattern =r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]';
    RegExp regex = new RegExp(pattern);
    if (regex.hasMatch(value)) {
      return 'Medicine name is invalid';
    } else {
      return null;
    }
  }

  String validateDosage(String value){
     if(value == "0"){
       return 'Dosage is required';
     } else {
       return null;
     }
  }

  Future createNewAppt(BuildContext context) async {
    Firestore.instance
          .collection("users")
          .document(widget.uid)
          .collection("medicineReminders")
          .add({
            "medicineName"  :medNameInputControl.text.toString(),
            "timeOfDosage"  :doseTimeOutput,
            "dosageAmt"     :dosageInputControl.text.toString(),
            "startDate"     :startDateOutput,
            "endDate"       :endDateOutput,
            "weekly"        :cbgPicked,
            "medInstruction":instructionsInputControl.text.toString()
          })
          .then((result) => {
            print("Medicine Reminder Added " + medNameInputControl.text.toString() + " " + doseTimeOutput + " " + dosageInputControl.text.toString() + 
                  " " + startDateOutput + " " + endDateOutput + " " + cbgPicked.toString() + " " + instructionsInputControl.text.toString()),
          })
          .catchError((error) => print(error));
          setState(() {
            Fluttertoast.showToast(
              msg: "Medicine Reminder Added",
              backgroundColor: Colors.black,
              textColor: Colors.white,
            );
          });
    
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
            tooltip: "Go back to Manage Medicine Reminders",),
            title: Text("Add Medicine Reminder"),
        ),
        body: Container(
          padding: const EdgeInsets.all(5.0),
          child: SingleChildScrollView(
            child: Form(
              key: _addMedicineReminderFormKey,
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  medicineName(),
                  instructions(),
                  timeAndDosage(),
                  startEndDates(),
                  wkSelection(),
                  addMRBtn(context)
                ]
              )
            )
          )
        ),
      );
  }

  Padding medicineName() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: TextFormField(
        decoration:InputDecoration(
          labelText: 'Medicine Name*', 
          hintText: "Panadol"
        ),
        controller: medNameInputControl,
        keyboardType: TextInputType.text,
        validator: validateMedName,
      ),
    );
  }

  Padding instructions(){
    return Padding(
      padding: const EdgeInsets.only(top:120.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Medicine Intake Instructions * "),
          Container(
            height: 150,
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
                  controller: instructionsInputControl,
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding timeAndDosage(){
    return Padding(
      padding: const EdgeInsets.only(top: 300.0),
      child: Row(
        children: <Widget>[
          timeDosePicker(),
          Container(width: 30),
          dosageInput()
        ],
      ),
    );
  }

  Column timeDosePicker(){
    return Column(
        children: <Widget>[
          Text('Choose Dosage Time *'),
          timePicker()
        ],
      );
  }

  RaisedButton timePicker(){
    return RaisedButton(
      child: Text(doseTimeInputControl == null ? 'Set Dosage Time' : '$doseTimeOutput'),
      onPressed: (){
        showTimePicker(
          context: context, 
          initialTime: doseTimeInputControl == null ? TimeOfDay.now() : doseTimeInputControl)
          .then((time){
            setState(() {
              doseTimeInputControl = time;
              doseTimeOutput = new TimeOfDay(hour: doseTimeInputControl.hour, minute: doseTimeInputControl.minute).format(context);
            });
          });
      },
    );
  }

  Container dosageInput() {
    return Container(
        width: 150,
        child: TextFormField(
          decoration:InputDecoration(
            labelText: 'Dosage *', 
            hintText: "2"
          ),
          controller: dosageInputControl,
          keyboardType: TextInputType.number,
          validator: validateDosage,
        ),
      );
  }

  Padding startEndDates(){
    return Padding(
      padding: const EdgeInsets.only(top: 420.0),
      child: Row(
        children: <Widget>[
          chooseStartDate(),
          Container(width: 40),
          chooseEndDate()
        ],
      ),
    );
  }

  Column chooseStartDate(){
    return Column(
          children: [
            Text('Choose Start Date *'),
            startDateButton(),
          ],
        );
  }

  RaisedButton startDateButton() {
    return RaisedButton(
      child: Text(startDateInputControl == null ? 'Set Start Date' : '$startDateOutput'),
      onPressed: () {
        showDatePicker(
                context: context,
                initialDate: startDateInputControl == null ? DateTime.now() : startDateInputControl,
                firstDate: DateTime(1920),
                lastDate: DateTime(2120))
            .then((date) {
          setState(() {
            startDateInputControl = date;
            startDateOutput = new DateFormat.yMMMd().format(startDateInputControl);
          });
        });
      },
    );
  }

  Column chooseEndDate(){
    return Column(
          children: [
            Text('Choose End Date *'),
            endDateButton(),
          ],
        );
  }

  RaisedButton endDateButton() {
    return RaisedButton(
      child: Text(endDateInputControl == null ? 'Set End Date' : '$endDateOutput'),
      onPressed: () {
        showDatePicker(
                context: context,
                initialDate:endDateInputControl == null ? DateTime.now() : endDateInputControl,
                firstDate: DateTime(1920),
                lastDate: DateTime(2120))
            .then((date) {
              if(date.isBefore(startDateInputControl)){
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text("End Date of Dosage is set before Start Date of Dosage. End Date should be later than Start Date"),
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
              } else if(date.isAtSameMomentAs(startDateInputControl)){
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text("End Date of Dosage is set same as Start Date of Dosage. End Date should be later than Start Date"),
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
              }else{
                setState(() {
                  endDateInputControl = date;
                  endDateOutput = new DateFormat.yMMMd().format(endDateInputControl);
                });
              }
            });
      },
    );
  }

  Padding wkSelection(){
    return Padding(
      padding: const EdgeInsets.only(top:520.0),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Days To Take Per Week* :"),
          CheckboxGroup(
            orientation: GroupedButtonsOrientation.VERTICAL,
            labels: <String>['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'],
            onSelected: (List<String> selected){
              setState(() {
                cbgPicked = selected;
                print(cbgPicked);
              });
            },
            checked: cbgPicked,
          ),
        ]
      ),
    );
  }

  Padding addMRBtn(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(top: 900.0),
      child: ButtonTheme(
        minWidth: 200,
        height: 50,
        child: RaisedButton(
          color: Colors.cyan,
          child: Text(
            'Add Medicine Reminder',
            style: TextStyle(
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
                color: Colors.white
            ),
          ),
          onPressed: () {
              if (_addMedicineReminderFormKey.currentState.validate()) {
                if (medNameInputControl.text.isNotEmpty && instructionsInputControl.text.isNotEmpty && doseTimeInputControl != null 
                  && dosageInputControl.text.isNotEmpty && startDateInputControl != null && endDateInputControl != null && cbgPicked != null) {
                  createNewAppt(context);
                  Navigator.of(context).pop();
              } else if (doseTimeInputControl == null || startDateInputControl == null || endDateInputControl == null 
                        || cbgPicked == null || dosageInputControl.text.isEmpty || medNameInputControl.text.isEmpty){
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text("Medicine Reminder can't be added without filling the necessary fields"),
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