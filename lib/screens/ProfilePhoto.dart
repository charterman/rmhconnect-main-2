import 'package:flutter/material.dart';
import 'package:rmhconnect/constants.dart';

class Profilephoto extends StatelessWidget {
  final String pfp;
  const Profilephoto({super.key, required this.pfp});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 50,
      // backgroundImage: NetworkImage(pfp),
      backgroundImage: AssetImage(pfp),
      backgroundColor: backgroundColor.withOpacity(0.2),
    );
  }
}
