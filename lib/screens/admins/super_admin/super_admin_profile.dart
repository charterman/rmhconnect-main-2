import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rmhconnect/constants.dart';
import 'package:rmhconnect/screens/ProfilePhoto.dart';
import 'package:rmhconnect/screens/admins/memberlist.dart';
import 'package:rmhconnect/screens/admins/super_admin/super_admin_memberlist.dart';

class SuperAdminProfile extends StatefulWidget {
  const SuperAdminProfile({super.key});

  @override
  State<SuperAdminProfile> createState() => _SuperAdminProfileState();
}

class _SuperAdminProfileState extends State<SuperAdminProfile> {
  User? user;
  List<String> orgNames = [];
  bool isLoading = true;
  bool informationLoaded = false;
  String name = '';
  String role = '';
  String email = '';
  String location = '';
  late TextEditingController namecontrol = TextEditingController();
  late TextEditingController rolecontrol = TextEditingController();

  @override
  void initState(){
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    init();
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

  Future<void> updateUserLocationInFirebase(String newLocation) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'location': newLocation});
    }
  }

  Future<void> addAdmin(String email) async {
    try {
      await FirebaseFirestore.instance.collection('admins').add({
        'email': email,
      });
      print('Admin with email "$email" added successfully.');
    } catch (e) {
      print('Error adding admin: $e');
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
                padding: const EdgeInsets.fromLTRB(0,0,30,5),
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: backgroundColor,
          onPressed: (){
            showDialog(
                context: context,
                builder: (BuildContext context){
                  return AlertDialog(
                      title: Text("Add New Admin"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: namecontrol,
                            decoration: InputDecoration(
                              labelText: "New Admin email",
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  namecontrol.clear();
                                },
                                child: Text("Cancel"),
                              ),
                              SizedBox(width: 20),
                              OutlinedButton(
                                onPressed: () async {
                                  setState(() {
                                    nmname = namecontrol.text;
                                    namecontrol.clear();
                                  });
                                  await addAdmin(nmname);
                                  Navigator.pop(context);
                                },
                                child: Text("Create"),
                              ),
                            ],
                          )
                        ],
                      )
                  );
                }
            );
          },
          child: Icon(Icons.add, color: Colors.white),
        ),
        body: Column(
            children:[
              SizedBox(height: 20),
              informationLoaded ?
              Column(
                children: [
                  SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Profilephoto(
                          pfp: "assets/images/person-icon.png",
                        ),
                        Column(
                            children: [
                              Text(name, style: mytextnormal),
                              Text(role, style: mytextnormal),
                              Text(email, style: TextStyle(fontSize: 18, decoration: TextDecoration.underline)),
                              Text(location, style: mytextnormal),
                            ]
                        )
                      ]
                  ),
                ],
              )
                  : Center(child: CircularProgressIndicator()),

              Padding(
                padding: const EdgeInsets.fromLTRB(0,10,0,0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25,0,0,0),
                        child: Text("Current Charity: ", style: TextStyle(fontSize: 22)),
                      ),
                      SizedBox(width: 10),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: isLoading == false
                              ? SizedBox(
                            width: 150,
                            child: DropdownSearch<String>(
                              items: (f, cs) => orgNames,
                              popupProps: const PopupProps.menu(
                                fit: FlexFit.loose,
                              ),
                              selectedItem: location,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    location = val;
                                  });
                                  updateUserLocationInFirebase(location);
                                }
                              },
                            ),
                          )
                              : const SizedBox(),
                        ),
                      ),
                    ]
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25,8,0,0),
                    child: Text("Admin Members", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),


                ],
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('location', isEqualTo: location)
                        .where('role', isEqualTo: 'admin') // <-- Filter for admins only
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No admins found."));
                      }

                      final users = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final name = user['name'] ?? 'Unknown';
                          final role = user['role'] ?? 'Member';
                          final uid = user.id;
                          return SuperAdminMemberlist(uid: uid, name: name, role: role, pfp: "assets/images/person-icon.png");
                        },
                      );
                    },
                  ),
                ),
              )

            ]
        )
    );
  }
}
