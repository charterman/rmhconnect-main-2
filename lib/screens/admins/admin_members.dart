import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/constants.dart';
import 'package:flutter/material.dart';
import 'package:rmhconnect/screens/Events.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/screens/logo.dart';
import 'package:rmhconnect/screens/admins/memberlist.dart';

class AdminMembers extends StatefulWidget {
  final String orgName;
  const AdminMembers({super.key, required this.orgName});

  @override
  State<AdminMembers> createState() => _AdminMembersState();
}

class _AdminMembersState extends State<AdminMembers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text("Members", style: titling),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(50,20,50,0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('location', isEqualTo: widget.orgName)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No members found."));
              }

              // Get the list of users
              final users = snapshot.data!.docs;

              // Sort so 'admin' roles appear first
              users.sort((a, b) {
                final roleA = a['role']?.toString().toLowerCase() ?? '';
                final roleB = b['role']?.toString().toLowerCase() ?? '';
                if (roleA == 'admin' && roleB != 'admin') return -1;
                if (roleA != 'admin' && roleB == 'admin') return 1;
                return 0;
              });

              return ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final name = user['name'] ?? 'Unknown';
                  final role = user['role'] ?? 'Member';
                  return memberlist(name: name, role: role, pfp: "assets/images/person-icon.png");
                },
              );
            },
          ),

        ),
      )
    );
  }
}
