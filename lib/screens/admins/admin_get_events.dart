import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rmhconnect/screens/Events.dart';


class AdminGetEvents extends StatelessWidget {
  final String orgName;

  const AdminGetEvents({super.key, required this.orgName});

  String _formatDate(Timestamp timestamp) {
    return DateFormat('MMMM d, yyyy').format(timestamp.toDate());
  }

  String _formatTime(Timestamp timestamp) {
    return DateFormat('h:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('organizations')
          .where('name', isEqualTo: orgName)
          .limit(1)
          .get(),
      builder: (context, orgSnapshot) {
        if (orgSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!orgSnapshot.hasData || orgSnapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Organization not found"));
        }

        final orgDocId = orgSnapshot.data!.docs.first.id;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('organizations')
              .doc(orgDocId)
              .collection('activities')
              .where('dateTime', isGreaterThan: Timestamp.now())
              .orderBy('dateTime')
              .snapshots(),
          builder: (context, activitySnapshot) {
            if (activitySnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!activitySnapshot.hasData || activitySnapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No upcoming events"));
            }

            final activities = activitySnapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                final title = activity['title'] ?? 'Event';
                final description = activity['description'] ?? 'No description';
                final dateTime = activity['dateTime'] as Timestamp;
                final eventID = activity.id;

                return Events(
                  eventID: eventID,
                  orgName: orgName,
                  evname: title,
                  evdescrip: description,
                  evtime: _formatTime(dateTime),
                  evdate: _formatDate(dateTime),
                  evtimeunchanged: dateTime,
                );
              },
            );
          },
        );
      },
    );
  }
}
