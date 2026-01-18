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
late String username = "username";
late String role = "role";
late String password = "password";
late String email = "email";
late String location = "location";
late String nbname = "charity name";
late String nbloc = "charity location";
late String nenme;
late String nedscrp;
late String cbname = "charity name current";
late String nmname = "bob";
late String nmrole = "role";



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