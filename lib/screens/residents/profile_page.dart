import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/screens/ProfilePhoto.dart';
import 'package:rmhconnect/screens/residents/org_get_info_past.dart';
import 'package:rmhconnect/screens/residents/org_get_info.dart';
import 'package:rmhconnect/theme.dart';

import 'discovery.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool informationLoaded = false;
  User? user;
  String name = '';
  String role = '';
  String email = '';
  String location = '';
  bool locationPressed = false;
  List<String> orgNames = [];
  bool isLoading = true;
  bool showPastEvents = false;
  List<Map<String, dynamic>> joinedOrganizations = [];
  List<Map<String, dynamic>> upcomingActivities = [];
  File? _imageFile;
  String? profileImageUrl;

  @override
  void initState(){
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    init();
    //look thru user profile, get field, fills joinedOrgs
    fillJoinedOrgs();



  }

  Future<void> fillJoinedOrgs() async{
    final user = FirebaseAuth.instance.currentUser;

    final joinedOrgs = await FirebaseFirestore.instance // Fetch
        .collection('users')
        .doc(user?.uid)
        .get();

        final tempJoinedOrgs = joinedOrgs['orgs']??[]; // ??[] makes empty list

        for (int i = 0; i < tempJoinedOrgs.length; i++){
          FirebaseFirestore.instance.collection("organizations").where('name', isEqualTo: tempJoinedOrgs[i]).get().then(
              (querySnapshot){
                for (var docSnapshot in querySnapshot.docs) {
            //      print('docSnapshot ID: ${docSnapshot.id}');
                  joinedOrganizations.add(docSnapshot.data());
                }
                //print('Temp Joined Org: ${tempJoinedOrgs[i]}');
              }
          );
        }
        //print('tempJoinedOrgs: ${tempJoinedOrgs.length}');
        //print('joinedOrganizations: ${joinedOrganizations.length}');
  }

  Future<void> init() async{
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        try{
          profileImageUrl = userDoc['profileImageUrl'];
        }catch(e){
          profileImageUrl = null;
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
                'profileImageUrl': profileImageUrl
              });
        }
      });

      setState(() {
        try{
          name = userDoc['name'];
          role = userDoc['role'];
          email = userDoc['email'];
          location = userDoc['location'];
          loadOrgNames();
        }catch(e){
          name = '';
          role = '';
          email = '';
          location = '';
        }
        informationLoaded = true;
      });
    }

  }

  Future<String> _promptForPassword() async {
    String password = '';
    await showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('Re-enter your password'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(hintText: 'Password'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                password = controller.text;
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
    return password;
  }


  Future<void> loadOrgNames() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('organizations').get();
    final names = snapshot.docs
        .map((doc) => doc.data()['name'] as String?)
        .whereType<String>()
        .toList();

    setState(() {
      orgNames = names;
      isLoading = false;
      print("Loaded $orgNames successfully");
    });
  }

  void _showSettingsMenu() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () => Navigator.pop(context, 'logout'),
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (action == 'logout') {
      await FirebaseAuth.instance.signOut();
      if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
    } else if (action == 'delete') {
      try {
        // Re-authenticate the user
        final credential = EmailAuthProvider.credential(
          email: user!.email!,
          password: await _promptForPassword(), // You’ll implement this function
        );
        await user?.reauthenticateWithCredential(credential);

        await user?.delete();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .delete();

        if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete account. Try again.")),
        );
      }

    }
  }


    Future<void> _saveProfile() async {
      if (user == null) return;

      try {
        String? profileImageUrl;

        // Upload new image if selected
        if (_imageFile != null) {
          profileImageUrl = await _uploadProfileImage();
          if (profileImageUrl == null) {
            throw Exception('Failed to upload image');
          }
        }

        // Update user profile in Firestore
        final updateData = {
          'profileImageUrl': profileImageUrl ?? '',
        };

        // Only update image URL if we have a new one
        if (profileImageUrl != null) {
          updateData['profileImageUrl'] = profileImageUrl;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update(updateData);

        setState(() {
          _imageFile = null; // Clear the selected file
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        setState(() {
          print(e.toString());
        });
      }
    }


    Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
      _saveProfile();
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_imageFile == null || user == null) return null;

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'profile_images/${user!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await storageRef.putFile(_imageFile!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: backgroundColor,
          title: Text("My Profile", style: titling),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0,0,30,0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                      )
                  ),
                  IconButton(icon: Icon(Icons.settings), onPressed: _showSettingsMenu),
                ],
              ),
            ),
          ]
      ),
      body: Center(
          child: Column(
            children: [
              informationLoaded ?
                Container(
                //children: [
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                              child:
                              profileImageUrl != null
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(profileImageUrl!)
                                    )
                                  : Profilephoto(pfp: "assets/images/person-icon.png")
                          ),
                          Column(
                              children: [
                                Text(name, style: mytextnormal),
                                Text(role, style: mytextnormal),
                                Text(email, style: TextStyle(fontSize: 18, decoration: TextDecoration.underline)),
                              ]
                          )
                        ]
                    ),
                  ],
                ),
                //]
              )
              : Center(child: CircularProgressIndicator()),

              SizedBox(height: 30),

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
                        Tab(text: 'Organizations'),
                        Tab(text: 'Events')
                      ],
                    ),
                    SizedBox(
                      height: resizedHeight(context, 3880/8), //resizedHeight(context, 550),
                      child: TabBarView(
                        children: [
                          // Organizations Tab
                          joinedOrganizations.isEmpty
                              ? Center(child: Text('No organizations joined yet'))
                              : ListView.builder(
                                  itemCount: joinedOrganizations.length,
                                  itemBuilder: (context, index) {
                                    final org = joinedOrganizations[index];
                                    final discoveryName = org['name'];
                                    final discoveryPhoto = org['url'];
                                    return Discovery(name: discoveryName, photo: discoveryPhoto);
                              // return Card(
                              //   margin: EdgeInsets.symmetric(vertical: 8),
                              //   child: ListTile(
                              //     leading: Icon(Icons.business, color: CharityConnectTheme.primaryColor),
                              //     title: Text(org['name'].toUpperCase() ?? 'Organization'),
                              //     subtitle: Text(org['address'] ?? 'No address'),
                              //     onTap: () {
                              //       Navigator.pushNamed(
                              //         context,
                              //         '/organization_detail',
                              //         arguments: {
                              //           'orgId': org['orgId'],
                              //           'orgData': org,
                              //         },
                              //       );
                              //     },
                              //   ),
                              // ); ret
                              return Discovery(name: discoveryName, photo: discoveryPhoto);
                                  },
                              ),
                          // Upcoming Activities Tab
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    //const Text('My Joined Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    ElevatedButton(
                                      onPressed: (){
                                        setState((){
                                          showPastEvents = false;
                                        });
                                      },
                                      child: Text('My Joined Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                                    ),
                                    ElevatedButton(
                                        onPressed: (){
                                          setState((){
                                            showPastEvents = true;

                                          });
                                        },
                                        child: Text('Past Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          // Force refresh
                                        });
                                      },
                                      icon: const Icon(Icons.refresh),
                                    ),
                                  ],
                                ),
                              ),
                              SingleChildScrollView(
                                child: Column(
                                  children: [
                                    if(showPastEvents == false)
                                      OrgGetInfo()
                                    else
                                      OrgGetInfoPast()
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            ]
          )
        )
    );
  }
}
