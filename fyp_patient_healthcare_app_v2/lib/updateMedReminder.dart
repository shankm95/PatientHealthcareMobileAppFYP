import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:grouped_buttons/grouped_buttons.dart';

class UpdateMedReminderPage extends StatefulWidget {
  UpdateMedReminderPage({Key key, this.uid, this.document, this.medName, this.dosageTime, this.startDate, this.endDate, this.dosageAmt, this.week}) : super(key: key);
  final String uid;
  final document;
  final medName;
  final dosageTime;
  final startDate;
  final endDate;
  final dosageAmt;
  final week;

  @override
  UpdateMedReminderPageState createState() => UpdateMedReminderPageState();
}

class UpdateMedReminderPageState extends State<UpdateMedReminderPage> {
  final GlobalKey<FormState> _updateMedReminderFormKey = GlobalKey<FormState>();
  TextEditingController instructionsInputControl;
  TextEditingController dosageInputControl;
  TimeOfDay doseTimeInputControl;
  String doseTimeOutput;
  DateTime startDateInputControl;
  String startDateOutput;
  DateTime endDateInputControl;
  String endDateOutput;
  List<String> cbgPicked;

  @override
  initState() {
    instructionsInputControl = new TextEditingController();
    dosageInputControl = new TextEditingController();
    super.initState();
  }

  String validateInstructions(String value){
     if(value.isEmpty){
       return 'Instructions is required';
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

  Future updateMedReminder(BuildContext context) async{
    Firestore.instance
          .collection("users")
          .document(widget.uid)
          .collection("medicineReminders")
          .document(widget.document.documentID)
          .updateData({
            "timeOfDosage"  :doseTimeOutput,
            "dosageAmt"     :dosageInputControl.text.toString(),
            "startDate"     :startDateOutput,
            "endDate"       :endDateOutput,
            "weekly"        :cbgPicked,
          })
          .then((result)=>{
            print("Medicine Reminder Updated $doseTimeOutput ${dosageInputControl.text.toString()} $startDateOutput $endDateOutput $cbgPicked")
          })
          .catchError((error)=>print(error));
    Fluttertoast.showToast(
      msg: "Medicine Reminder Updated",
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
            tooltip: "Go back to Manage Medicine Reminders",),
            title: Text("Update Medicine Reminder",
                        style: TextStyle(fontSize: 15),
                        ),
        ),
        body: Container(
          padding: const EdgeInsets.all(5.0),
          child: SingleChildScrollView(
            child: Form(
              key: _updateMedReminderFormKey,
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  medNameDisplay(),
                  medTimeDisplay(),
                  medDoseDisplay(),
                  datesDisplay(),
                  weekDisplay(),
                  timeAndDosage(),
                  startEndDates(),
                  wkSelection(),
                  rescheduleMRBtn(context)
                ]
              )
            )
          )
        ),
      );
  }

  Padding medNameDisplay(){
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Row(
        children: <Widget>[
          Text('Medicine Name ',
              style: TextStyle(fontWeight: FontWeight.bold)
          ),
          Text(widget.medName)
        ],
      ),
    );
  }

  Padding medTimeDisplay(){
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Row(
        children: <Widget>[
          Text('Original Time of Dosage ',
              style: TextStyle(fontWeight: FontWeight.bold)
          ),
          Text(widget.dosageTime)
        ],
      ),
    );
  }

  Padding medDoseDisplay(){
    return Padding(
      padding: const EdgeInsets.only(top: 55.0),
      child: Row(
        children: <Widget>[
          Text('Original Dosage Amount ',
              style: TextStyle(fontWeight: FontWeight.bold)
          ),
          Text(widget.dosageAmt)
        ],
      ),
    );
  }

 Padding datesDisplay(){
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Text('Original Start Date',
              style: TextStyle(fontWeight: FontWeight.bold)
              ),
              Text(widget.startDate)
            ],
          ),
          spacingContainer(null, 20),
          Column(
            children: <Widget>[
              Text('Original End Date',
              style: TextStyle(fontWeight: FontWeight.bold)
              ),
              Text(widget.endDate)
            ],
          ),
        ],
      ),
    );
  }

  Padding weekDisplay(){
    return Padding(
      padding: const EdgeInsets.only(top: 125.0),
      child: Column(
        children: <Widget>[
          Text('Original Days in Week to Consume ',
              style: TextStyle(fontWeight: FontWeight.bold)
          ),
          getWeekNames()
        ],
      ),
    );
  }

  getWeekNames(){
    List<Widget> textList = new List<Widget>();
    for(var name in widget.week){
      textList.add(new Text(name + ", "));
    }
    return new Column(children: textList);
  }

  Padding timeAndDosage(){
    return Padding(
      padding: const EdgeInsets.only(top: 340.0),
      child: Row(
        children: <Widget>[
          timeDosePicker(),
          spacingContainer(null, 30),
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
      padding: const EdgeInsets.only(top: 440.0),
      child: Row(
        children: <Widget>[
          chooseStartDate(),
          spacingContainer(null, 40),
          chooseEndDate()
        ],
      ),
    );
  }

  Column chooseStartDate(){
    return Column(
          children: [
            Text('Choose Start Date* '),
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
            Text('Choose End Date* '),
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
              } else if(date.isBefore(startDateInputControl) || date.isAtSameMomentAs(startDateInputControl)){
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
      padding: const EdgeInsets.only(top:530.0),
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

  Padding rescheduleMRBtn(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(top: 900.0),
      child: ButtonTheme(
        minWidth: 200,
        height: 50,
        child: RaisedButton(
          color: Colors.cyan,
          child: Text(
            'Update Medicine Reminder',
            style: TextStyle(
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
                color: Colors.white
            ),
          ),
          onPressed: () {
              if (_updateMedReminderFormKey.currentState.validate()) {
                if (doseTimeInputControl != null && dosageInputControl.text.isNotEmpty 
                    && startDateInputControl != null && endDateInputControl != null && cbgPicked != null) {
                  updateMedReminder(context);
                  Navigator.of(context).pop();
              } else if(doseTimeInputControl == null || startDateInputControl == null || endDateInputControl == null 
                  || cbgPicked == null || dosageInputControl.text.isEmpty) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text("Medicine Reminder can't be updated without filling the necessary fields"),
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

  Container spacingContainer(double h, double w){
    return Container(height: h, width: w,);
  } 
}