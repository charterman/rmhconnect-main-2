import 'package:flutter/material.dart';
import 'package:rmhconnect/theme.dart';
final Color backgroundColor = CharityConnectTheme.primaryColor;
final TextStyle mytext = TextStyle(fontSize:32, color: CharityConnectTheme.primaryColor, fontWeight: FontWeight.bold);
final TextStyle mytextnormal = TextStyle(fontSize:18, color: Colors.black);
final TextStyle mytextmed = TextStyle(fontSize:24, color: Colors.black, fontWeight: FontWeight.bold);
final TextStyle mytextred = TextStyle(fontSize:18, color: CharityConnectTheme.primaryColor);
final TextStyle titling = TextStyle(fontSize:32, color: Colors.white, fontWeight: FontWeight.bold);
final TextStyle titlingblck = TextStyle(fontSize:32, color: Colors.black, fontWeight: FontWeight.bold);
final TextStyle versionStyley = TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 32);
final TextStyle titleStyley = TextStyle(fontSize: 32);
bool? signIn = false;
String username = "username";
String role = "role";
String password = "password";
String email = "email";
String location = "location";
String nbname = "charity name";
String nbloc = "charity location";
late String nenme;
late String nedscrp;
String cbname = "charity name current";
String nmname = "bob";
String nmrole = "role";



double resizedHeight(context, double mediumPhoneWidgetHeight){
  Size size = MediaQuery.of(context).size;
  double deviceHeight = size.height;
  double mediumPhoneTotalHeight = 924;
  return deviceHeight*mediumPhoneWidgetHeight/mediumPhoneTotalHeight;
}

double aggressivelyResizedHeight(context, double mediumPhoneWidgetHeight){
  Size size = MediaQuery.of(context).size;
  double deviceHeight = size.height;
  double mediumPhoneTotalHeight = 924;
  return 0.80*deviceHeight*mediumPhoneWidgetHeight/mediumPhoneTotalHeight;
}