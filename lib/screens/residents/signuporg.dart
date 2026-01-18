import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../theme.dart';

class Signuporg extends StatefulWidget {
  final String photor;
  final String namee;
  final String linfo;
  const Signuporg({super.key, required this.photor, required this.namee, required this.linfo});

  @override
  State<Signuporg> createState() => _SignuporgState();
}



class _SignuporgState extends State<Signuporg> {
  late bool joined = false;
  late String button = "Join";

  @override
  void initState(){
    super.initState();
    Checkorg();

  }
  Future <void> Checkorg() async{
    final db = FirebaseFirestore.instance;
    final userid = FirebaseAuth.instance.currentUser!.uid;
    final user = db.collection('users').doc(userid).get();
    user.then(
        (DocumentSnapshot doc) {
          final data = doc.data() as Map<String, dynamic>;
          final org = data['orgs'] ?? [] as List<String>;
          print(org);
          if(org.contains(widget.namee) == false){
            setState(() {joined = false;});
          }
          else{
            setState(() {joined = true;});
          }
          if(joined == false){
            setState(() {button = "Join";});
          }
          else{
            setState(() {button = "Leave";});
          }
        }
    );



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Tooltip(
            message: widget.namee,
            child: Text(
              widget.namee,
              style: titling,
              softWrap: true,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(90),
            child: Container(
              height: 80,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Follow the ${widget.namee} branch",
                      style: mytextmed,
                      softWrap: true,
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if(joined == false) {
                        final db = FirebaseFirestore.instance;
                        final docRef = db.collection('users').doc(
                            FirebaseAuth.instance.currentUser!.uid);
                        docRef.update({
                          'orgs': FieldValue.arrayUnion([widget.namee])
                        });
                        setState(() {
                          joined = true;
                          button = "Leave";
                        });
                      }
                      else{
                        final db = FirebaseFirestore.instance;
                        final docRef = db.collection('users').doc(
                            FirebaseAuth.instance.currentUser!.uid);
                        docRef.update({
                          'orgs': FieldValue.arrayRemove([widget.namee])
                        });
                        setState(() {
                          joined = false;
                          button = "Join";
                        });
                      };
                    },
                    child: Text(button, style: const TextStyle(fontSize: 20, color: Colors.white),),
                  ),
                ],
              ),
            ),
          ),
        ),

        body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: ListView(
          children: [
            Column(
              children: [
                Card(
                  color: CharityConnectTheme.cardColor,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  elevation: 10,
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(widget.photor),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(widget.linfo, style: mytextnormal),
                ),
                SizedBox(height: 20),

              ]
            )
          ],
        ),
      )
    );
  }
}
