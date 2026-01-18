import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/constants.dart';
import 'package:flutter/material.dart';
import 'package:rmhconnect/screens/Events.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/screens/logo.dart';
import 'package:rmhconnect/theme.dart';

class memberlist extends StatelessWidget {
  final String pfp;
  final String name;
  final String role;
  const memberlist({super.key, required this.name, required this.role, required this.pfp});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        color: CharityConnectTheme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                // backgroundImage: NetworkImage(pfp),
                backgroundImage: AssetImage(pfp),
                backgroundColor: Colors.white,
              ),
              SizedBox(width: 15),
              Column(
                children: [
                  Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(role, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
                ]
              )
            ]
          ),
        ),

      ),
    );
  }
}
