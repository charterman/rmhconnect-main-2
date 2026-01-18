import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/constants.dart';
import 'package:flutter/material.dart';
import 'package:rmhconnect/screens/Events.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/screens/logo.dart';

class WelcomePage extends StatefulWidget {
  final int selectedIndex;
  const WelcomePage({super.key, this.selectedIndex = 2});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex; // get the starting index
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double deviceHeight = size.height;
    double testOGHeight = 924;
    return Scaffold(
      body: SafeArea(
          child: Center(
            child: Column(
                children: [
                  Image.asset("assets/images/logoclear.png", height: 450),
                  //ext("CHARITY CONNECT", style: mytext),
                  SizedBox(
                    width: 200,
                    //height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: SizedBox(

                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Login", style: TextStyle(fontSize:20)),
                        ),
                      )
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical:(8.0)),
                            child: Text("Signup", style: TextStyle(fontSize:20)),
                          ),
                        )
                    ),
                  )
                ] //Children
            ),
          ),
        ),
      /*
      bottomNavigationBar: BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        if(index == 0){
          Navigator.pushNamed(context, '/signup');
        }
        else {
          setState(() {
            selectedIndex = index;
          });
        }
      },
      selectedItemColor: Colors.red,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.mail), label: "Announcements"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    ),
      */
    );
  }
}
