//Annuncio gratis
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
import 'package:rmhconnect/screens/admins/super_admin/super_admin_navigation.dart';
import 'package:rmhconnect/screens/residents/announcements_page.dart';
import 'package:rmhconnect/screens/residents/navigation_page.dart';
import 'package:rmhconnect/screens/residents/profile_page.dart';
import 'package:rmhconnect/signup_screen.dart';
import 'package:rmhconnect/welcome.dart';
//import 'firebase_options.dart';
import 'package:rmhconnect/screens/admins/adminbranches.dart';
import 'package:rmhconnect/screens/admins/admin_members.dart';
import 'package:rmhconnect/theme.dart';
import 'package:rmhconnect/constants.dart';

class Discovery extends StatelessWidget {
  final String name;
  final String photo;
  const Discovery({super.key, required this.name, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 10.0, 18.0, 10.0),
      child: Card(
        //height: 150,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        color: CharityConnectTheme.cardColor,
        elevation: 100,
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(photo),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ListTile(
              tileColor: Colors.white,
              title: Center(
                  child: Text("`$name branch", style: TextStyle(fontSize: 20))
              ),
            ),
          ],
        ),
      ),
    );
  }
}
