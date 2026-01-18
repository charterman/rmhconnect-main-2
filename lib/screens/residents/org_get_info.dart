import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/theme.dart';

import 'event_detail_page.dart';

class OrgGetInfo extends StatefulWidget {
  const OrgGetInfo({super.key});


  @override
  State<OrgGetInfo> createState() => _OrgGetInfoState();
}

class _OrgGetInfoState extends State<OrgGetInfo> {

  String _formatDateTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('MMM d, yyyy · h:mm a').format(date);
  }

  Stream<List<Map<String, dynamic>>> _getJoinedEventsStream(String orgId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    // Create a timer stream to periodically check for updates
    return Stream.periodic(const Duration(seconds: 2), (_) async {
      try {
        // Get all events
        final eventsSnapshot = await FirebaseFirestore.instance
            .collection('organizations')
            .doc(orgId)
            .collection('activities')
            .where('dateTime', isGreaterThan: Timestamp.now())
            .orderBy('dateTime')
            .get();

        final joinedEvents = <Map<String, dynamic>>[];

        // For each event, check if user has joined
        for (final eventDoc in eventsSnapshot.docs) {
          try {
            // Check if user is in participants collection
            final participantDoc = await FirebaseFirestore.instance
                .collection('organizations')
                .doc(orgId)
                .collection('activities')
                .doc(eventDoc.id)
                .collection('participants')
                .doc(user.uid)
                .get();

            if (participantDoc.exists) {
              joinedEvents.add({
                'id': eventDoc.id,
                'orgID': orgId,
                'orgName': 'Organization',
                ...eventDoc.data(),
              });
            }
          } catch (e) {
            print('Error checking join status for event ${eventDoc.id}: $e');
          }
        }

        return joinedEvents;
      } catch (e) {
        print('Error getting joined events: $e');
        return <Map<String, dynamic>>[];
      }
    }).asyncMap((future) => future);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text("User data not found"));
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final location = userData['location'];

        if (location == null) {
          return const Center(child: Text("No location set for user"));
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('organizations')
              .where('name', isEqualTo: location)
              .snapshots(),
          builder: (context, orgSnapshot) {
            if (!orgSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final organizations = orgSnapshot.data!.docs;
            if (organizations.isEmpty) {
              return const Center(child: Text("No organization found for your location"));
            }

            // Assuming only one org per name
            final orgDoc = organizations.first;

            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getJoinedEventsStream(orgDoc.id), //getJoinedEventsStream
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allActivities = snapshot.data ?? [];
                if (allActivities.isEmpty) {
                  return Column(
                    children: [
                      const Center(child: Text('No joined events')),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Force refresh by rebuilding
                          });
                        },
                        child: const Text('Refresh'),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 1, // Only one org
                  itemBuilder: (context, index) {
                    final activities = allActivities;
                    final orgName = activities.first['orgName'] as String;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...activities.map((activity) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Card(
                              color: CharityConnectTheme.cardColor,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                leading: const Icon(Icons.check_circle, color: Colors.green),
                                title: Text(activity['title'] ?? 'Activity'),
                                subtitle: activity['dateTime'] != null
                                    ? Text(_formatDateTime(activity['dateTime'] as Timestamp))
                                    : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Joined',
                                        style: TextStyle(
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
                                            builder: (context) => EventDetailPage(
                                              eventId: activity['id'],
                                              orgId: activity['orgID'],
                                              eventData: activity,
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
                                      builder: (context) => EventDetailPage(
                                        eventId: activity['id'],
                                        orgId: activity['orgID'],
                                        eventData: activity,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
