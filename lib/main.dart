import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'dart:io';
import 'package:hubify/pages/CreateAccountComponent.dart';
import 'package:hubify/pages/LoginScreen.dart';
import 'package:hubify/pages/academiccalendar.dart';
import 'package:hubify/admin/adminloginpage.dart';
import 'package:hubify/pages/calendar.dart';
import 'package:hubify/pages/chatgpt.dart';
import 'package:hubify/pages/chatpage.dart';
import 'package:hubify/pages/contact.dart';
import 'package:hubify/pages/dasboard.dart';
import 'package:hubify/pages/eventpage.dart';
import 'package:hubify/pages/hub%20center.dart';
import 'package:hubify/pages/hub_center/CGPA.dart';
import 'package:hubify/pages/hub_center/Firstyrattendance.dart';
import 'package:hubify/pages/hub_center/Mynotes.dart';
import 'package:hubify/pages/hub_center/Result.dart';
import 'package:hubify/pages/hub_center/attendance.dart';
import 'package:hubify/pages/hub_center/classSchedular.dart';
import 'package:hubify/pages/hub_center/links.dart';
import 'package:hubify/pages/hub_center/notesadder.dart';
import 'package:hubify/pages/notespage.dart';
import 'package:hubify/pages/startscreen.dart';
import 'admin/admin_dash.dart';
import 'admin/admin_event_update.dart';
import 'admin/admin_noteadd.dart';
import 'admin/feedback_provider.dart';
import 'pages/hub_center/files.dart';
import 'pages/about_page_component.dart';
import 'pages/hub_center/feedback_page.dart';

/// Custom HttpOverrides to allow bad certificate handling
class CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

/// Firebase configuration for web
const firebaseConfig = {
  "apiKey": "AIzaSyCaJ5FJj-4fyGaep_qLGjfZrwZXGPYXPlE",
  "authDomain": "hubify-151746.firebaseapp.com",
  "projectId": "hubify-151746",
  "storageBucket": "hubify-151746.firebasestorage.app",
  "messagingSenderId": "1079952339326",
  "appId": "1:1079952339326:web:d042f3404a7318b332032f",
  "measurementId": "G-V8TN09NBP9"
};

/// Separate async initialization
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = CustomHttpOverrides(); // Set HTTP overrides

  // Initialize Firebase for Web and Native
  if (Firebase.apps.isEmpty) {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: firebaseConfig['apiKey']!,
          authDomain: firebaseConfig['authDomain']!,
          projectId: firebaseConfig['projectId']!,
          storageBucket: firebaseConfig['storageBucket']!,
          messagingSenderId: firebaseConfig['messagingSenderId']!,
          appId: firebaseConfig['appId']!,
          measurementId: firebaseConfig['measurementId']!,
        ),
      );
    } else {
      await Firebase.initializeApp(); // Native initialization
    }
  }

  runApp(const MyApp());
}

/// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      title: 'HUBIFY',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Add routes for navigation
      initialRoute: '/',
      routes: {
        '/': (context) => StartScreen(),
        '/about': (context) => AboutPageComponent(),
        '/login': (context) => LoginScreen(),
        '/createac': (context) => CreateAccountComponent(),
        '/dash': (context) => Dashboard(),
        '/cal': (context) => CalendarPage(),
        '/aca': (context) => AcademicCal(),
        '/chat': (context) => ChatPage(),
        '/chatgpt': (context) => ChatGemini(),
        '/event': (context) => EventPage(),
        '/notes': (context) => NotesPage(),
        '/hub': (context) => HubCenter(),
        '/result': (context) => ResultPage(),
        '/mynotes' : (context) => MyNotesPage(),
        '/class' : (context) => ClassSchedulerPage(),
        '/file' : (context) => FilesPage(),
        '/admin' : (context) => AdminLoginPage(),
        '/noteadd' : (context)=> UploadNotesPage(),
        '/admindash' : (context) => AdminDashboard(),
        '/notesadd' : (context) => NotesAdderPage(),
        '/feedp' : (context) => FeedbackProviderPage(),
        '/attendance' : (context) => AttendancePage(),
        '/firstyrattend' : (context) => FirstYearAttendanceScreen(),
        '/eventupdate' : (context) => EventUpdaterPage(),
        '/feed' : (context) => FeedbackPage(),
        '/links' : (context) => UsefulLinksPage(),
        '/contact' : (context) => ContactPage(),
        '/cgpa' :  (context) => CGPACalculatorPage(),
      },
    );
  }
}
