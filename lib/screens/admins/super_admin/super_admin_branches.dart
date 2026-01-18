import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmhconnect/constants.dart';
import 'package:flutter/material.dart';
import 'package:rmhconnect/theme.dart';

class SuperAdminBranches extends StatefulWidget {
  const SuperAdminBranches({super.key});

  @override
  State<SuperAdminBranches> createState() => _SuperAdminBranchesState();
}

class _SuperAdminBranchesState extends State<SuperAdminBranches> {
  late TextEditingController namecontrol = TextEditingController();
  late TextEditingController loccontrol = TextEditingController();

  Future<void> addOrganizationBranch(String name, String location) async {
    try {
      await FirebaseFirestore.instance.collection('organizations').add({
        'name': name,
        'location': location,
      });

      print('Charity "$name" at "$location" added successfully.');
    } catch (e) {
      print('Failed to add branch: $e');
    }
  }

  Future<void> deleteBranchByName(String name) async {
    final collection = FirebaseFirestore.instance.collection('organizations');

    try {
      final querySnapshot = await collection.where('name', isEqualTo: name).get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      if (querySnapshot.docs.isEmpty) {
        print("No charity found with name: $name");
      } else {
        print("Charity '$name' deleted successfully.");
      }
    } catch (e) {
      print("Error deleting charity: $e");
    }
  }

  Future<bool?> showDeleteConfirmationDialog(BuildContext context, String branchName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: Text("Are you sure you want to permanently delete the Charity '$branchName'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              deleteBranchByName(branchName);
              Navigator.of(context).pop(true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: backgroundColor,
          onPressed: (){
            showDialog(
                context: context,
                builder: (BuildContext context){
                  return AlertDialog(
                      title: Text("Create New Charity"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: namecontrol,
                            decoration: InputDecoration(
                              labelText: "New Charity Name",
                            ),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: loccontrol,
                            decoration: InputDecoration(
                              labelText: "New Charity Location",
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  namecontrol.clear();
                                  loccontrol.clear();
                                },
                                child: Text("Cancel"),
                              ),
                              SizedBox(width: 20),
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    nbname = namecontrol.text;
                                    nbloc = loccontrol.text;
                                    namecontrol.clear();
                                    loccontrol.clear();
                                  });
                                  addOrganizationBranch(nbname, nbloc);
                                  Navigator.pop(context);
                                },
                                child: Text("Create"),
                              ),
                            ],
                          )
                        ],
                      )
                  );
                }
            );
          },
          child: Icon(Icons.add, color: Colors.white,),
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
                            trailing: GestureDetector(
                                onTap: () async {
                                  showDeleteConfirmationDialog(context, nbname);
                                },
                                child: const Icon(Icons.delete, color: Colors.red, size: 30),
                              )
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
