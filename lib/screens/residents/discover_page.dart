import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rmhconnect/screens/residents/discovery.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/screens/residents/signuporg.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        title: Text("Discovery", style: titling),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('organizations').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: ( context, int index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final name = data['name'] ?? 'No name';
              final url = data['url'] ?? 'No photo';
              final info = data['info'] ?? 'No info';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Signuporg(photor: url, namee: name, linfo: info),
                    )
                  );
                },
                  child: Discovery(name: name, photo: url));
            },
          );
        },
      )
    );
  }
}
