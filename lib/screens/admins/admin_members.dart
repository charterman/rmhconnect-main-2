import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmhconnect/constants.dart';
import 'package:flutter/material.dart';
import 'package:rmhconnect/screens/admins/memberlist.dart';

class AdminMembers extends StatefulWidget {
  final String orgName;
  const AdminMembers({super.key, required this.orgName});

  @override
  State<AdminMembers> createState() => _AdminMembersState();
}

class _AdminMembersState extends State<AdminMembers> {

  String resolveRole(DocumentSnapshot user) {
    final everyroleuser = user['role'];
    if (everyroleuser == null) return 'Unknown';
    if (everyroleuser is String) return everyroleuser;
    if (everyroleuser is Map) {
      final roleMap = Map<String, dynamic>.from(everyroleuser);
      return roleMap[widget.orgName]?.toString() ?? 'user';
    }
    return 'user';
  }

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
          padding: const EdgeInsets.fromLTRB(50, 20, 50, 0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('orgs', arrayContains: widget.orgName)
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

              // Sort so 'super_admin' appears first, then 'admin', then everyone else
              users.sort((a, b) {
                final roleA = resolveRole(a).toLowerCase();
                final roleB = resolveRole(b).toLowerCase();

                if (roleA == 'super_admin' && roleB != 'super_admin') return -1;
                if (roleA != 'super_admin' && roleB == 'super_admin') return 1;
                if (roleA == 'admin' && roleB != 'admin') return -1;
                if (roleA != 'admin' && roleB == 'admin') return 1;

                return 0;
              });

              return ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final uid = user.id;
                  final org = widget.orgName;
                  final name = user['name'] ?? 'Unknown';
                  final role = resolveRole(user);

                  return memberlist(
                    name: name,
                    org: org,
                    uid: uid,
                    role: role,
                    pfp: "assets/images/person-icon.png",
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}