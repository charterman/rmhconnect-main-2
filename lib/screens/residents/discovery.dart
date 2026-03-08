//Annuncio gratis
import 'package:flutter/material.dart';
//import 'firebase_options.dart';
import 'package:rmhconnect/theme.dart';

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
