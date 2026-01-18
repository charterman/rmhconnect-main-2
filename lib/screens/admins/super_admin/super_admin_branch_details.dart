import 'package:rmhconnect/constants.dart';
import 'package:flutter/material.dart';
import 'package:rmhconnect/theme.dart';

class SuperAdminBranchDetails extends StatefulWidget {
  final String name;
  final String location;
  const SuperAdminBranchDetails({super.key, required this.name, required this.location});

  @override
  State<SuperAdminBranchDetails> createState() => _SuperAdminBranchDetailsState();
}

class _SuperAdminBranchDetailsState extends State<SuperAdminBranchDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundColor,
          title: Text("Charity Details", style: titling),
          centerTitle: true,
        ),
        body: Center(
            child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                    child: Center(
                      child: SizedBox(
                        width: double.infinity, // or a fixed value like 300 if needed
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          color: CharityConnectTheme.cardColor,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(widget.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                Text(widget.location, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: (){
                            Navigator.pushNamed(
                              context,
                              '/admin_announcements',
                              arguments: {
                                'orgName': widget.name,
                              },
                            );
                          },
                          child: Card(
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              color: CharityConnectTheme.cardColor,
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check, color: CharityConnectTheme.primaryColor, size: 40),
                                      SizedBox(height: 20),
                                      Text("Announcements", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    ]
                                ),
                              )
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            Navigator.pushNamed(
                              context,
                              '/admin_events',
                              arguments: {
                                'orgName': widget.name,
                              },
                            );
                          },
                          child: Card(
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              color: CharityConnectTheme.cardColor,
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.calendar_month, color: CharityConnectTheme.primaryColor, size: 40),
                                      SizedBox(height: 20),
                                      Text("Events", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    ]
                                ),
                              )
                          ),
                        ),
                      ]
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/admin_members',
                            arguments: {
                              'orgName': widget.name,
                            },
                          );
                        },
                        child: Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            color: CharityConnectTheme.cardColor,
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                  children: [
                                    Icon(Icons.group, color: CharityConnectTheme.primaryColor, size: 40),
                                    SizedBox(height: 20),
                                    Text("Members", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  ]
                              ),
                            )
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/admin_members',
                            arguments: {
                              'orgName': widget.name,
                            },
                          );
                        },
                        child: Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            color: CharityConnectTheme.cardColor,
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                  children: [
                                    Icon(Icons.group, color: CharityConnectTheme.primaryColor, size: 40),
                                    SizedBox(height: 20),
                                    Text("Members", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  ]
                              ),
                            )
                        ),
                      ),
                    ],
                  ),
                ]
            )
        )
    );
  }
}
