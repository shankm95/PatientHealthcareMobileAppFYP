import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'appointment.dart';
import 'addAppointment.dart';

class ManageAppointmentPage extends StatefulWidget {
  ManageAppointmentPage({Key key, this.uid}) : super(key: key);
  final String uid;
  
  @override
  ManageAppointmentPageState createState() => ManageAppointmentPageState();
}

class ManageAppointmentPageState extends State<ManageAppointmentPage> {
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
          title: Text("Manage Appointments"),
        ),
        body: Center(
          child: Container(
              padding: const EdgeInsets.all(5.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection("users")
                    .document(widget.uid)
                    .collection('appointments')
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
                              return new Appointment(
                                uid            :widget.uid,
                                document       :document,
                                appointmentDate:document['appointmentDate'],
                                appointmentTime:document['appointmentTime'],
                                referredBy     :document['referredBy'],
                                serviceType    :document['typeOfService'],
                                hospital       :document['preferredHospital'],
                                doctor         :document['doctorName'],
                                description    :document['description']
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
                          AddAppointmentPage(uid: widget.uid)
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