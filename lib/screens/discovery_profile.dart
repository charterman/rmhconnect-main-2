import 'package:flutter/material.dart';

class charityProfile extends StatefulWidget {
  const charityProfile({super.key, required this.name, this.description, this.image});
  final String name;
  final String? description;
  final String? image;
  @override
  State<charityProfile> createState() => _charityProfileState();
}

class _charityProfileState extends State<charityProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children:[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              //name
              //follow button
              //ElevatedButton()
            ),
          )
        ]
      )
    );
  }
}
