import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rmhconnect/constants.dart';
import 'package:flutter/material.dart';
import 'package:rmhconnect/theme.dart';

class Adminbranches extends StatefulWidget {
  const Adminbranches({super.key});

  @override
  State<Adminbranches> createState() => _AdminbranchesState();
}

class _AdminbranchesState extends State<Adminbranches> {
  late TextEditingController namecontrol = TextEditingController();
  late TextEditingController loccontrol = TextEditingController();

  Future<void> addOrganizationBranch(String name, String location) async {
    try {
      await FirebaseFirestore.instance.collection('organizations').add({
        'name': name,
        'location': location,
      });

      print('Branch "$name" at "$location" added successfully.');
    } catch (e) {
      print('Failed to add branch: $e');
    }
  }

  Future<Set<String>> _getAdminOrgNames() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {};

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final roleMap = userDoc.data()?['role'] as Map<String, dynamic>?;
    if (roleMap == null) return {};

    // Only keep keys where the value indicates admin
    return roleMap.entries
        .where((entry) => entry.value == 'admin')
        .map((entry) => entry.key)
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        title: Text("Charities", style: titling),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: FutureBuilder<Set<String>>(
            future: _getAdminOrgNames(),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final adminOrgNames = adminSnapshot.data ?? {};

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('organizations')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No organizations found."));
                  }

                  // Filter orgs to only those the user is an admin of
                  final orgDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final String orgName = data['name'] ?? '';
                    return adminOrgNames.contains(orgName);
                  }).toList();

                  if (orgDocs.isEmpty) {
                    return const Center(
                        child: Text("You are not an admin of any organizations."));
                  }

                  return ListView.builder(
                    itemCount: orgDocs.length,
                    itemBuilder: (context, index) {
                      final data =
                      orgDocs[index].data() as Map<String, dynamic>;
                      final String nbname = data['name'] ?? 'Unknown Name';
                      final String nbloc =
                          data['location'] ?? 'Unknown Location';

                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/admin_branch_details',
                            arguments: {
                              'name': nbname,
                              'location': nbloc,
                            },
                          );
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          color: CharityConnectTheme.cardColor,
                          child: ListTile(
                            leading: const Icon(Icons.home,
                                color: CharityConnectTheme.primaryColor),
                            title: Text(nbname,
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(nbloc,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic)),
                          ),
                        ),
                      );
                    },
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