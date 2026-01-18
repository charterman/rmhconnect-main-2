import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/constants.dart';
import 'package:flutter/material.dart';
import 'package:rmhconnect/screens/Events.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/screens/admins/admin_home.dart';
import 'package:rmhconnect/screens/admins/admin_profile.dart';
import 'package:rmhconnect/screens/admins/adminbranches.dart';
import 'package:rmhconnect/screens/admins/super_admin/super_admin_branches.dart';
import 'package:rmhconnect/screens/admins/super_admin/super_admin_profile.dart';
import 'package:rmhconnect/screens/logo.dart';
import 'package:rmhconnect/screens/residents/announcements_page.dart';

import '../../../theme.dart';

class SuperAdminNavigation extends StatefulWidget {
  const SuperAdminNavigation({super.key});

  @override
  State<SuperAdminNavigation> createState() => _SuperAdminNavigationState();
}

class _SuperAdminNavigationState extends State<SuperAdminNavigation> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    AdminHome(),
    SuperAdminBranches(),
    SuperAdminProfile()
  ];

  void _onItemTapped(int index){
    setState((){
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: CharityConnectTheme.primaryColor,
        showSelectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: "Charities"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

