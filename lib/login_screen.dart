import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rmhconnect/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '';
  String password = '';
  String error = '';
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Login'),
            backgroundColor: backgroundColor
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: /*const*/ EdgeInsets.all(resizedHeight(context, 30.0)),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,0,0,0),
                    child: Image.asset("assets/images/logoclear.png", height: 450),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: (String? email) {
                        if (email == null || email.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                      onChanged: (val) => setState(() => email = val)
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Password'
                      ),
                      validator: (String? email) {
                        if (email == null || email.isEmpty) {
                          return 'We are sure you have a password';
                        }
                        return null;
                      },
                      onChanged: (val) => setState(() => password = val)
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() { error = ''; });
                          if (_formKey.currentState!.validate()) {
                            try {
                              final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                                email: email,
                                password: password,
                              );
                              final user = await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).get();
                              final role = user.data()?['role'] ?? 'user';
                              if (user != null) {
                                final userDoc = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.id)
                                    .get();

                                final rawRole = userDoc.data()?['role'];

                                if (rawRole == null) {
                                  Navigator.pushReplacementNamed(context, '/welcome');
                                } else if (rawRole is String) {
                                  // Old system — role is a plain string
                                  if (rawRole == 'admin') {
                                    Navigator.pushReplacementNamed(context, '/admin_navigation');
                                  } else if (rawRole == 'super_admin') {
                                    Navigator.pushReplacementNamed(context, '/super_admin_navigation');
                                  } else {
                                    Navigator.pushReplacementNamed(context, '/navigation_screen');
                                  }
                                } else if (rawRole is Map) {
                                  final Map<String, dynamic> roleMap = Map<String, dynamic>.from(rawRole);

                                  // Check if any value in the map is 'admin' or 'super_admin'
                                  final hasSuperAdmin = roleMap.values.any((v) =>
                                  v.toString() == 'super_admin');
                                  final hasAdmin = roleMap.values.any((v) => v.toString() == 'admin');
                                  print(hasAdmin);
                                  if (hasSuperAdmin) {
                                    Navigator.pushReplacementNamed(context, '/super_admin_navigation');
                                  } else if (hasAdmin) {
                                    Navigator.pushReplacementNamed(context, '/admin_navigation');
                                    print("admin");
                                  } else {
                                    Navigator.pushReplacementNamed(context, '/navigation_screen');
                                    print("no admin here");
                                  }
                                } else {
                                  Navigator.pushReplacementNamed(context, '/welcome');
                                }
                              }
                            } catch (e) {
                              setState(() { error = e.toString(); });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue
                        ),
                        child: const Text(
                            'Log In',
                            style: TextStyle(
                                color: Colors.white
                            )
                        ),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
                      child: TextButton(
                          onPressed: (){
                            Navigator.pushReplacementNamed(context, '/signup');
                          },
                          child: const Text(
                              "First time? Sign up!",
                              style: TextStyle(
                                  color: Colors.blue
                              )
                          )
                      )
                  ),
                  if (error.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(error, style: TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
          ),
        )
    );
  }
}
