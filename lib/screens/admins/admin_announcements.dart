import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rmhconnect/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rmhconnect/theme.dart';

class AdminAnnouncements extends StatefulWidget {
  final String orgName;
  const AdminAnnouncements({super.key, required this.orgName});

  @override
  State<AdminAnnouncements> createState() => _AdminAnnouncementsState();
}

class _AdminAnnouncementsState extends State<AdminAnnouncements> {
  late TextEditingController namecontrol = TextEditingController();
  late TextEditingController descripcontrol = TextEditingController();
  late String postname = "Unknowner";
  late Future<List<Map<String, dynamic>>> _announcementsFuture;
  User? get user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _announcementsFuture = fetchAnnouncements();
  }


  void _refreshAnnouncements() {
    setState(() {
      _announcementsFuture = fetchAnnouncements();
    });
  }

  Future<List<Map<String, dynamic>>> fetchAnnouncements() async {
    final orgQuery = await FirebaseFirestore.instance
        .collection('organizations')
        .where('name', isEqualTo: widget.orgName)
        .limit(1)
        .get();

    if (orgQuery.docs.isEmpty) {
      throw Exception("No organization found with name: ${widget.orgName}");
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

  Future<void> _createAnnouncement(String orgName, String description, String url) async {
    if (description.trim().isEmpty || url.trim().isEmpty) {
      print("Description and URL cannot be empty.");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Description and URL cannot be empty.")
          )
      );
      return; // Stop the function if either is empty
    }

    try {
      final orgQuery = await FirebaseFirestore.instance
          .collection('organizations')
          .where('name', isEqualTo: orgName)
          .limit(1)
          .get();

      if (orgQuery.docs.isEmpty) {
        throw Exception("Organization '$orgName' not found.");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Organization '$orgName' not found.")
            )
        );
      }

      final orgDocId = orgQuery.docs.first.id;

      final now = DateTime.now();
      final timestamp = Timestamp.fromDate(now);

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      final announcementRef = await FirebaseFirestore.instance
          .collection('organizations')
          .doc(orgDocId)
          .collection('announcements')
          .add({
        'description': description,
        'url': url,
        'timestamp': timestamp,
        'postedBy': userDoc['name'] ?? "unknown",
      });

      await announcementRef.update({'id': announcementRef.id});
      print("Announcement added successfully.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Announcement added successfully.")
        )
      );
    } catch (e) {
      print("Failed to add announcement: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text("Failed to add announcement.")
          )
      );
    }
  }

  Future<void> deleteAnnouncementByUid(String orgName, String uid) async {
    try {
      final orgQuery = await FirebaseFirestore.instance
          .collection('organizations')
          .where('name', isEqualTo: orgName)
          .limit(1)
          .get();

      if (orgQuery.docs.isEmpty) {
        print("No organization found with name: $orgName");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("No organization found with name: $orgName")
            )
        );
        return;
      }

      final orgId = orgQuery.docs.first.id;

      final announcementRef = FirebaseFirestore.instance
          .collection('organizations')
          .doc(orgId)
          .collection('announcements')
          .doc(uid);

      final docSnapshot = await announcementRef.get();

      if (docSnapshot.exists) {
        await announcementRef.delete();
        print("Announcement with UID '$uid' deleted successfully from organization '$orgName'.");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Announcement with UID '$uid' deleted successfully from organization '$orgName'.")
            )
        );
      } else {
        print("No announcement found with UID: $uid under organization: $orgName");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("No announcement found with UID: $uid under organization: $orgName")
            )
        );
      }
    } catch (e) {
      print("Error deleting announcement: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("No announcement found with UID: $uid under organization: $orgName")
          )
      );
    }
  }

  Future<bool?> showDeleteConfirmationDialog(BuildContext context, String orgName, String uid) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Announcement Deletion"),
        content: const Text("Are you sure you want to delete this announcement?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await deleteAnnouncementByUid(orgName, uid);
              Navigator.of(context).pop(true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete announcement"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(widget.orgName, style: titling),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Text("Announcements", style: mytextmed),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _announcementsFuture,
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

                return ListView.builder(
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    final item = announcements[index];
                    // final imgUrl = item['url'];
                    final imgUrl = "https://e7.pngegg.com/pngimages/981/645/png-clipart-default-profile-united-states-computer-icons-desktop-free-high-quality-person-icon-miscellaneous-silhouette.png";
                    final description = item['description'];
                    final timestamp = item['timestamp'] as Timestamp?;
                    final date = timestamp?.toDate();
                    final announceUID = item['id'];
                    final postedBy = item['postedBy'] ?? 'Unknowner';


                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Card(
                        color: CharityConnectTheme.cardColor,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: ListTile(
                            leading: imgUrl != null
                                ? Image.asset('assets/images/person-icon.png')
                                : null,
                            title: Text(description ?? 'No description'),
                            subtitle: Column(
                              children: [
                                Text(
                                  date != null
                                      ? DateFormat.yMMMd().add_jm().format(date)
                                      : 'No timestamp',
                                ),
                                Text(
                                  'Posted by: $postedBy',
                                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: GestureDetector(
                              onTap: () async {
                                final confirmed = await showDeleteConfirmationDialog(context, widget.orgName, announceUID);
                                if (confirmed == true) {
                                  _refreshAnnouncements();
                                }
                              },
                              child: const Icon(Icons.delete, color: Colors.red, size: 30),
                            ),
                          ),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: backgroundColor,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Add Announcement"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: descripcontrol,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            namecontrol.clear();
                            descripcontrol.clear();
                          },
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 20),
                        OutlinedButton(
                          onPressed: () async {
                            setState(() {
                              nbname = namecontrol.text;
                              nbloc = descripcontrol.text;
                              namecontrol.clear();
                              descripcontrol.clear();
                            });
                            await _createAnnouncement(
                              widget.orgName,
                              //postname,
                              nbloc,
                              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTLn2vN-qAufnhM8t2e4OkZ6-m3Md6_Gk9B7g&s",
                            );
                            _refreshAnnouncements();
                            Navigator.pop(context);
                          },
                          child: const Text("Create"),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}

