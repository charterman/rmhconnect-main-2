import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/constants.dart';
import 'package:flutter/material.dart';
import 'package:rmhconnect/screens/Events.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/screens/logo.dart';
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        title: Text("Chairities", style: titling),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('organizations').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No organizations found."));
              }

              final orgDocs = snapshot.data!.docs;

              return ListView.builder(
                itemCount: orgDocs.length,
                itemBuilder: (context, index) {
                  final data = orgDocs[index].data() as Map<String, dynamic>;
                  final String nbname = data['name'] ?? 'Unknown Name';
                  final String nbloc = data['location'] ?? 'Unknown Location';

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
                        leading: const Icon(Icons.home, color: CharityConnectTheme.primaryColor),
                        title: Text(nbname, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        subtitle: Text(nbloc, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        )
      )
    );
  }
}
