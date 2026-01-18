import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rmhconnect/login_screen.dart';
import 'package:rmhconnect/SplashScreen.dart';
import 'package:rmhconnect/screens/Home.dart';
import 'package:rmhconnect/screens/admins/admin_announcements.dart';
import 'package:rmhconnect/screens/admins/admin_branch_deatils_screen.dart';
import 'package:rmhconnect/screens/admins/admin_events.dart';
import 'package:rmhconnect/screens/admins/admin_home.dart';
import 'package:rmhconnect/screens/admins/admin_navigation.dart';
import 'package:rmhconnect/screens/admins/admin_view_events.dart';
import 'package:rmhconnect/screens/admins/super_admin/super_admin_navigation.dart';
import 'package:rmhconnect/screens/residents/announcements_page.dart';
import 'package:rmhconnect/screens/residents/navigation_page.dart';
import 'package:rmhconnect/screens/residents/profile_page.dart';
import 'package:rmhconnect/signup_screen.dart';
import 'package:rmhconnect/welcome.dart';
import 'firebase_options.dart';
import 'package:rmhconnect/screens/admins/adminbranches.dart';
import 'package:rmhconnect/screens/admins/admin_members.dart';
import 'package:rmhconnect/theme.dart';
import 'package:rmhconnect/screens/admins/admin_view_events.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'RMHConnect',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: CharityConnectTheme.themeData,

      initialRoute: '/',
      routes: {
        '/' /*name here before '*/: (context) => SplashScreen(),
        '/welcome': (context) => WelcomePage(),
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/signup_screen': (context) => SignupPage(),
        '/navigation_screen': (context) => NavigationPage(),
        '/announcements': (context) => AnnouncementsPage(),
        '/profile': (context) => ProfilePage(),
        '/admin_navigation': (context) => AdminNavigation(),
        '/admin_home': (context) => AdminHome(),
        '/admin_branch': (context) => Adminbranches(),
        '/super_admin_navigation': (context) => SuperAdminNavigation(),

      },
      onGenerateRoute: (settings) {
        if (settings.name == '/admin_branch_details') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => AdminBranchDeatils(
              name: args['name'] ?? "Unknown Name",
              location: args['location'] ?? "Unknown Location",
            ),
          );
        }
        else if(settings.name == '/admin_members'){
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => AdminMembers(
              orgName: args['orgName'] ?? "Unknown Name",
            ),
          );
        }
        else if(settings.name == '/admin_announcements'){
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => AdminAnnouncements(
              orgName: args['orgName'] ?? "Unknown Name",
            ),
          );
        }
        else if(settings.name == '/admin_events'){
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => AdminEvents(
              orgName: args['orgName'] ?? "Unknown Name",
            ),
          );
        }
        else if(settings.name == '/admin_view_events'){
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => AdminViewEvents(
              orgid: args['orgid'] ?? null,
              eventid: args['eventid'] ?? null,
            ),
          );
        }

        return null;
      },
    );
  }
}
