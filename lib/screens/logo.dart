import 'package:flutter/material.dart';

import '../constants.dart';

class Logo extends StatelessWidget {
  final double height;
  final double borderRadius;
  const Logo({super.key, required this.height, this.borderRadius = 80});


  @override
  Widget build(BuildContext context) {
    /*Size size = MediaQuery.of(context).size;
    double resizableHeight = size.height;*/
    return
      Container(
        margin: /*const*/ EdgeInsets.symmetric(vertical: resizedHeight(context, 80), horizontal: resizedHeight(context, 80)),
        height: height, // height, // =350
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: resizedHeight(context, 63)),
        decoration: BoxDecoration(
          // color: Colors.green,
          border: Border.all(
              width: resizedHeight(context, 2),
              color: Colors.black
          ),
          borderRadius: BorderRadius.circular(resizedHeight(context, borderRadius)),
          color: Colors.white,
          image: DecorationImage(
                image: AssetImage("assets/images/logoclear.png"),

                fit: BoxFit.contain//cover
          )
        ),
    );
  }
}
