import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /*final TextStyle versionStyle = TextStyle(
    color: Colors.white.withOpacity(0.5),
    fontSize: resizedHeight(context, 32)
  );*/
  TextStyle versionStyle(context){
    return TextStyle(
      color: Colors.white.withOpacity(0.5),
      fontSize: resizedHeight(context, 32)
    );
  }

  /*final TextStyle titleStyle = TextStyle(
      fontSize: 32
  );*/
TextStyle titleStyle(context){
  return TextStyle(
      fontSize: resizedHeight(context, 32)
  );
}

  @override
  void initState(){
    super.initState();
    init();
  }

  Future<void> init() async{
    await Future.delayed(const Duration(seconds: 3));

    final user = FirebaseAuth.instance.currentUser;
    print("-1");
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      print("0");
      final rawRole = userDoc.data()?['role'];
      print("1");
      if (rawRole == null) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
      else if (rawRole is String) {
        // Old system — role is a plain string
        print("2");
        if (rawRole == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin_navigation');
        } else if (rawRole == 'super_admin') {
          Navigator.pushReplacementNamed(context, '/super_admin_navigation');
        } else {
          Navigator.pushReplacementNamed(context, '/navigation_screen');
        }
      } else if (rawRole is Map) {
        final Map<String, dynamic> roleMap = Map<String, dynamic>.from(rawRole);
        print("4");
        // Check if any value in the map is 'admin' or 'super_admin'
        final hasSuperAdmin = roleMap.values.any((v) =>
        v.toString() == 'super_admin');
        final hasAdmin = roleMap.values.any((v) => v.toString() == 'admin');

        if (hasSuperAdmin) {
          Navigator.pushReplacementNamed(context, '/super_admin_navigation');
        } else if (hasAdmin) {
          Navigator.pushReplacementNamed(context, '/admin_navigation');
        } else {
          Navigator.pushReplacementNamed(context, '/navigation_screen');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CharityConnectTheme.backgroundColor,
      body:
        SafeArea(
          child: Center(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children:[
                Image.asset("assets/images/logoclear.png", height: 450),
                Spacer(flex: resizedHeight(context, 1).round()),
                Padding(
                  padding: /*const*/ EdgeInsets.symmetric(vertical: resizedHeight(context, 50), horizontal: 0),
                  child: Text(
                      "Version 1.0.0",
                      style: versionStyley
                  ),
                ),
              ]
            ),
          )
        )

    );
  }
}
