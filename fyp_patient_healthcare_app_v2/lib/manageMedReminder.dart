import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'medReminder.dart';
import 'addMedReminder.dart';

class ManageMedReminderPage extends StatefulWidget {
  ManageMedReminderPage({Key key, this.uid}) : super(key: key);
  final String uid;
  
  @override
  ManageMedReminderPageState createState() => ManageMedReminderPageState();
}

class ManageMedReminderPageState extends State<ManageMedReminderPage> {
  FirebaseUser currentUser;

  @override
  initState(){
    this.getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async{
    currentUser = await FirebaseAuth.instance.currentUser();
  }

  Widget build(BuildContext context){
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.of(context).pop();
            },
            tooltip: "Go back to Home Page",
          ),
          title: Text("Manage Medicine Reminders",
                      style: TextStyle(fontSize: 15),
                    ),
        ),
        body: Center(
          child: Container(
              padding: const EdgeInsets.all(5.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection("users")
                    .document(widget.uid)
                    .collection("medicineReminders")
                    .snapshots(),
               builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return new Text('Loading...');
                    default:
                      return new ListView(
                        children: snapshot.data.documents
                            .map((DocumentSnapshot document) {
                              return new MedReminder(
                                uid            :widget.uid,
                                document       :document,
                                medName        :document['medicineName'],
                                medTime        :document['timeOfDosage'],
                                amtOfDose      :document['dosageAmt'],
                                startDate      :document['startDate'],
                                endDate        :document['endDate'],
                                weekly         :document['weekly'],
                                instructions   :document['medInstruction']
                                
                              );
                            }).toList(),
                      );
                    }
                  },
              )
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                          AddMedReminderPage(uid: widget.uid)
                    )
            );
            print('navigate to add appointment');
          },
          tooltip: 'Add new appointment',
          child: Icon(Icons.add),
        ), 
      );
  }
}