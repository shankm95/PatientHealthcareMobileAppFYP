import 'package:flutter/material.dart';
import 'splash.dart';
import 'loginUser.dart';
import 'registerUser.dart';
import 'home.dart';
import 'manageAppointment.dart';
import 'manageMedReminder.dart';
import 'addAppointment.dart';
import 'addMedReminder.dart';
import 'updateAppointment.dart';
import 'updateMedReminder.dart';
import 'appointment.dart';
import 'medReminder.dart';

void main() {
  runApp(
    MyApp()
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashPage(),
      routes: <String, WidgetBuilder>{
        '/login'             : (BuildContext context) => LoginPage(),
        '/register'          : (BuildContext context) => RegisterPage(),
        '/home'              : (BuildContext context) => HomePage(userName: 'user name not logged in'),
        '/manageAppointments': (BuildContext context) => ManageAppointmentPage(),
        '/manageMedReminders': (BuildContext context) => ManageMedReminderPage(),
        '/addAppointment'    : (BuildContext context) => AddAppointmentPage(),
        '/addMedReminder'    : (BuildContext context) => AddMedReminderPage(),
        '/updateAppointment' : (BuildContext context) => UpdateAppointmentPage(),
        '/updateMedReminder' : (BuildContext context) => UpdateMedReminderPage(),
        '/appointment'       : (BuildContext context) => Appointment(uid : 'no appointment'),
        '/medReminder'       : (BuildContext context) => MedReminder(uid : 'no med reminder')
      },
    );
  }
}
