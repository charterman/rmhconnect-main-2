import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../theme.dart';

class AdminViewEvents extends StatefulWidget {
  final orgid;
  final eventid;
  const AdminViewEvents({super.key, required this.orgid, required this.eventid});

  @override
  State<AdminViewEvents> createState() => _AdminViewEventsState();
}

class _AdminViewEventsState extends State<AdminViewEvents> {


  Future<List<Map<String, dynamic>>> fetchAnnouncements() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final orgQuery = await FirebaseFirestore.instance
        .collection('organizations')
        .where('name', isEqualTo: widget.orgid)
        .limit(1)
        .get();


    final orgId = orgQuery.docs.first.id;

    final announcementsSnapshot =
    await FirebaseFirestore.instance
        .collection('organizations')
        .doc(orgId)
        .collection('activities')
        .doc(widget.eventid)
        .collection('participants')
        //todo: make this go into participants (find doc id so we can find participants)
        .get();

    return announcementsSnapshot.docs.map((doc) {
      final data = doc.data();

      return {
        'id': doc.id,
        'orgId':orgId,
        'userId': data['userId'],
        'userEmail': data['userEmail'],
        'name' : data['name'],
        'pfp' : data['pfp']
        //'joinedAt': (data['joinedAt'] as Timestamp).toDate(),
      };
    }).toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event Signups", style: titling),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchAnnouncements(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final announcements = snapshot.data ?? [];

                if (announcements.isEmpty) {
                  return const Center(child: Text('No announcements available'));
                }

                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final item = announcements[index];
                      print(item);
                      String name = item["name"] ?? "null";
                      String email = item["userEmail"] ?? "null";
                      String pfp = item["pfp"] ?? "null";

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Card(
                          color: CharityConnectTheme.cardColor,
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 15),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: ListTile(
                              leading:
                               SizedBox(
                                 height: 50,
                                 child:  pfp != "null"
                               ? CircleAvatar(
                                   radius: 50,
                                   backgroundImage: NetworkImage(pfp)
                               )
                                  : CircleAvatar(
                                   radius: 20,
                                   // backgroundImage: NetworkImage(pfp),
                                   backgroundImage: AssetImage("assets/images/person-icon.png"),
                                   backgroundColor: backgroundColor.withOpacity(0.2),
                                 )
                               ),
                              title: Text(name),
                              subtitle: Text(email),
                              onTap: () {

                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      )
    );
  }
}

