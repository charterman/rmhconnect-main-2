import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/screens/residents/org_get_info.dart';

import '../../theme.dart';
import 'announcements_page.dart';
import 'event_detail_page.dart';

class ResidentsHome extends StatefulWidget {
  const ResidentsHome({super.key});

  @override
  State<ResidentsHome> createState() => _ResidentsHomeState();
}



class _ResidentsHomeState extends State<ResidentsHome> {
  Future<List<Map<String, dynamic>>> fetchAnnouncements() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    final userDoc =
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final location = userDoc.data()?['location'];
    if (location == null) {
      throw Exception("User does not have a location set");
    }

    final orgQuery =
    await FirebaseFirestore.instance
        .collection('organizations')
        .where('name', isEqualTo: location)
        .limit(1)
        .get();

    if (orgQuery.docs.isEmpty) {
      throw Exception("No organization found with name: $location");
    }

    print("Organization found: ${orgQuery.docs.first.data()}");
    final orgDocId = orgQuery.docs.first.id;

// Get current time
    final now = DateTime.now();

    final announcementsSnapshot =
    await FirebaseFirestore.instance
        .collection('organizations')
        .doc(orgDocId)
        .collection('activities')
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(now)) // 👈 filter here
        .orderBy('dateTime', descending: true)
        .get();

    return announcementsSnapshot.docs
        .map((doc) => {'id': doc.id, 'orgId': orgDocId, ...doc.data()})
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: backgroundColor,
          automaticallyImplyLeading: false,
          title: Text("CHARITY CONNECT", style: titling),
          centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            DefaultTabController(
              length: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    labelColor: CharityConnectTheme.primaryColor,
                    unselectedLabelColor: CharityConnectTheme.secondaryTextColor,
                    indicatorColor: CharityConnectTheme.primaryColor,
                    tabs: const [
                      Tab(text: 'Upcoming Events'),
                      Tab(text: 'Announcements')
                    ],
                  ),
                  SizedBox(
                    height: resizedHeight(context, 650), //3880/7),
                    child: TabBarView(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Upcoming Events',
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
                                  return const Center(child: Text('No upcoming events'));
                                }

                                return Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    //physics: const NeverScrollableScrollPhysics(),
                                    itemCount: announcements.length,
                                    itemBuilder: (context, index) {
                                      final item = announcements[index];
                                      final imgUrl = item['url'];
                                      final description = item['description'];
                                      final timestamp = item['dateTime'] as Timestamp?;
                                      final date = timestamp?.toDate();
                                      final title = item['title'] ?? 'No title';
                                      final eventId = item['id'];
                                      final orgId = item['orgId'];

                                      return StreamBuilder<DocumentSnapshot>(
                                        stream:
                                        FirebaseFirestore.instance
                                            .collection('organizations')
                                            .doc(orgId)
                                            .collection('activities')
                                            .doc(eventId)
                                            .collection('participants')
                                            .doc(FirebaseAuth.instance.currentUser?.uid)
                                            .snapshots(),
                                        builder: (context, joinSnapshot) {
                                          final isJoined = joinSnapshot.data?.exists ?? false;

                                          return Card(
                                            margin: const EdgeInsets.all(8.0),
                                            elevation: 2.0,
                                            color:
                                            isJoined
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              side: BorderSide(
                                                color:
                                                isJoined
                                                    ? Colors.green
                                                    : Colors.grey.withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: ListTile(
                                              // leading: Icon(
                                              //   isJoined ? Icons.check_circle : Icons.event,
                                              //   color: isJoined ? Colors.green : Colors.grey,
                                              // ),
                                              title: Text(
                                                title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              subtitle: Text(
                                                date != null
                                                    ? DateFormat.yMMMd().add_jm().format(date)
                                                    : 'No timestamp',
                                              ),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                      isJoined ? Colors.green : Colors.grey,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      isJoined ? 'Joined' : 'Not Joined',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  IconButton(
                                                    icon: const Icon(Icons.arrow_forward_ios),
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (context) => EventDetailPage(
                                                            eventId: eventId,
                                                            orgId: orgId,
                                                            eventData: item,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) => EventDetailPage(
                                                      eventId: eventId,
                                                      orgId: orgId,
                                                      eventData: item,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ), // Events tab
                        AnnouncementsPage()
                      ]
                    )
                  ),
                ]
              )
            ),
          ],
        ),
      )
    );
  }
}
