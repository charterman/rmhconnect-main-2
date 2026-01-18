import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/theme.dart';



class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  Future<void> fillJoinedOrgs() async{
    List<Map<String, dynamic>> joinedOrganizations = [];
    List<Map<String, dynamic>> upcomingActivities = [];
    final user = FirebaseAuth.instance.currentUser;

    final joinedOrgs = await FirebaseFirestore.instance // Fetch
        .collection('users')
        .doc(user?.uid)
        .get();

    final tempJoinedOrgs = joinedOrgs['orgs']??[]; // ??[] makes empty list

    for (int i = 0; i < tempJoinedOrgs.length; i++){
      FirebaseFirestore.instance.collection("organizations")
          .where('name', isEqualTo: tempJoinedOrgs[i])
          .get()
          .then(
              (querySnapshot){
            for (var docSnapshot in querySnapshot.docs) {
              //      print('docSnapshot ID: ${docSnapshot.id}');
              joinedOrganizations.add(docSnapshot
                  .data()
                //.collection('announcements')
              );
            }
            //print('Temp Joined Org: ${tempJoinedOrgs[i]}');
          }
      );
    }
    //print('tempJoinedOrgs: ${tempJoinedOrgs.length}');
    //print('joinedOrganizations: ${joinedOrganizations.length}');

    // for(String in )
    // final orgEvents = await FirebaseFirestore.instance
    //   .collection()
  }


  Future<List<Map<String, dynamic>>> fetchAnnouncements() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final location = userDoc.data()?['location'];
    if (location == null) {
      throw Exception("User does not have a location set");
    }

    final orgQuery = await FirebaseFirestore.instance
        .collection('organizations')
        .where('name', isEqualTo: location)
        .limit(1)
        .get();

    if (orgQuery.docs.isEmpty) {
      throw Exception("No organization found with name: $location");
    }

    final orgDocId = orgQuery.docs.first.id;

    final announcementsSnapshot = await FirebaseFirestore.instance
        .collection('organizations')
        .doc(orgDocId)
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .get();

    return announcementsSnapshot.docs.map((doc) => doc.data()).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          //(16.0),
          child: Text(
            'Announcements',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
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
                  final imgUrl = item['url'];
                  final description = item['description'];
                  final timestamp = item['timestamp'] as Timestamp?;
                  final date = timestamp?.toDate();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Card(
                      color: CharityConnectTheme.cardColor,
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: ListTile(

                          title: Text(description ?? 'No description'),
                          subtitle: Text(
                            date != null
                                ? DateFormat.yMMMd().add_jm().format(date)
                                : 'No timestamp',
                          ),
                          onTap: () {},
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
    );


  }
}

// Below working code, above copied from main
/*

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/theme.dart';



class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  Future<List<Map<String, dynamic>>> fillJoinedOrgs() async{
    List<Map<String, dynamic>> joinedOrganizations = [];
    List<Map<String, dynamic>> upcomingActivities = [];
    final user = FirebaseAuth.instance.currentUser;

    final joinedOrgs = await FirebaseFirestore.instance // Fetch
        .collection('users')
        .doc(user?.uid)
        .get();

    final tempJoinedOrgs = joinedOrgs['orgs']??[]; // ??[] makes empty list

    final now = DateTime.now();

    final querySnapshot = await FirebaseFirestore.instance.collectionGroup("announcements")
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy(DateTime)
          .get();

    final allAnnouncements = querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'orgId': doc.reference.parent.parent?.id, // 👈 parent org id
        ...doc.data() as Map<String, dynamic>,
      };
    })
    .toList();

    return allAnnouncements;

  }

  Future<List<Map<String, dynamic>>> fetchAnnouncements() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final allAnnouncements2 = await fillJoinedOrgs();
    for(int i=0; i < allAnnouncements2.length; i++){
      //print(allAnnouncements2[i]);
    }


    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final location = userDoc.data()?['location'];
    if (location == null) {
      throw Exception("User does not have a location set");
    }

    final orgQuery = await FirebaseFirestore.instance
        .collection('organizations')
        .where('name', isEqualTo: location)
        .limit(1)
        .get();

    if (orgQuery.docs.isEmpty) {
      throw Exception("No organization found with name: $location");
    }

    final orgDocId = orgQuery.docs.first.id;

    final announcementsSnapshot = await FirebaseFirestore.instance
        .collection('organizations')
        .doc(orgDocId)
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .get();

    return announcementsSnapshot.docs.map((doc) => doc.data()).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          //(16.0),
          child: Text(
            'Announcements',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
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
                  final imgUrl = item['url'];
                  final description = item['description'];
                  final timestamp = item['timestamp'] as Timestamp?;
                  final date = timestamp?.toDate();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Card(
                      color: CharityConnectTheme.cardColor,
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: ListTile(

                          title: Text(description ?? 'No description'),
                          subtitle: Text(
                            date != null
                                ? DateFormat.yMMMd().add_jm().format(date)
                                : 'No timestamp',
                          ),
                          onTap: () {},
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
    );


  }
}

 */