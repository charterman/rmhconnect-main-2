import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/constants.dart';
import 'package:flutter/material.dart';
import 'package:rmhconnect/screens/Events.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/screens/logo.dart';
import 'package:rmhconnect/theme.dart';

class SuperAdminMemberlist extends StatelessWidget {
  final String uid;
  final String pfp;
  final String name;
  final String role;
  const SuperAdminMemberlist({super.key, required this.uid, required this.name, required this.role, required this.pfp});

  Future<void> demoteUserByUid(String uid) async {
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      final docSnapshot = await userDocRef.get();

      if (docSnapshot.exists) {
        await userDocRef.update({'role': 'user'});
        print("User with UID '$uid' has been demoted to patient.");
      } else {
        print("No user found with UID: $uid");
      }
    } catch (e) {
      print("Error demoting user: $e");
    }
  }

  Future<bool?> showDeleteConfirmationDialog(BuildContext context, String userName, String uid) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Permission Demotion"),
        content: Text("Are you sure you want to make user '$userName' no longer admin?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              demoteUserByUid(uid);
              Navigator.of(context).pop(true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Remove Permissions"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        color: CharityConnectTheme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  // backgroundImage: NetworkImage(pfp),
                  backgroundImage: AssetImage(pfp),
                  backgroundColor: Colors.white,
                ),
                SizedBox(width: 15),
                Column(
                    children: [
                      Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(role, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
                    ]
                ),
                Spacer(),
                GestureDetector(
                  onTap: () async{
                    await showDeleteConfirmationDialog(context, name, uid);
                  },
                  child: const Icon(Icons.delete, color: Colors.red, size: 30),
                )
              ]
          ),
        ),

      ),
    );
  }
}
