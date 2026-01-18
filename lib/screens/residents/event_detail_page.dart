import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rmhconnect/constants.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;
  final String orgId;
  final Map<String, dynamic> eventData;

  const EventDetailPage({
    super.key,
    required this.eventId,
    required this.orgId,
    required this.eventData,
  });

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool isJoined = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkJoinStatus();
  }

  Future<void> checkJoinStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final joinDoc = await FirebaseFirestore.instance
          .collection('organizations')
          .doc(widget.orgId)
          .collection('activities')
          .doc(widget.eventId)
          .collection('participants')
          .doc(user.uid)
          .get();

      setState(() {
        isJoined = joinDoc.exists;
        isLoading = false;
      });
    } catch (e) {
      print('Error checking join status: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> toggleJoinEvent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to join events')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final joinRef = FirebaseFirestore.instance
          .collection('organizations')
          .doc(widget.orgId)
          .collection('activities')
          .doc(widget.eventId)
          .collection('participants')
          .doc(user.uid);

      if (isJoined) {
        // Leave event
        await joinRef.delete();
        setState(() {
          isJoined = false;
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have left the event')),
        );
      } else {
        final joinDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        String name = joinDoc["name"] ?? "null";
        String pfp = joinDoc["profileImageUrl"] ?? "null";
        // Join event
        await joinRef.set({
          'userId': user.uid,
          'joinedAt': FieldValue.serverTimestamp(),
          'userEmail': user.email,
          'name' : name,
          'pfp' : pfp
        });
        setState(() {
          isJoined = true;
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have joined the event!')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _formatDateTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('EEEE, MMMM d, yyyy · h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final eventData = widget.eventData;
    final title = eventData['title'] ?? 'No Title';
    final description = eventData['description'] ?? 'No description available';
    final dateTime = eventData['dateTime'] as Timestamp?;
    final imageUrl = eventData['url'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text('Event Details', style: titling),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            if (imageUrl != null && imageUrl.isNotEmpty)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Date and Time
                  if (dateTime != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          _formatDateTime(dateTime),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                   // Join Status Badge
                   Row(
                     children: [
                       Icon(
                         isJoined ? Icons.check_circle : Icons.cancel,
                         color: isJoined ? Colors.green : Colors.orange,
                         size: 24,
                       ),
                       const SizedBox(width: 8),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         decoration: BoxDecoration(
                           color: isJoined ? Colors.green : Colors.orange,
                           borderRadius: BorderRadius.circular(20),
                         ),
                         child: Text(
                           isJoined ? 'You have joined this event' : 'You have not joined this event',
                           style: const TextStyle(
                             color: Colors.white,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                       ),
                     ],
                   ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Join/Leave Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : toggleJoinEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isJoined ? Colors.red : backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isJoined ? 'Leave Event' : 'Join Event',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 