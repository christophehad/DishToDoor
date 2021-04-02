import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dishtodoor/screens/Cook/set_cook_location.dart';

String baseURL = "https://dishtodoor.azurewebsites.net/";
const kPrimaryColor = Color(0xFFFFC61F);
const ksecondaryColor = Color(0xFFB5BFD0);
const kTextColor = Color(0xFF50505D);
const kTextLightColor = Color(0xFF6A727D);
// Create storage
final storage = new FlutterSecureStorage();
//store cook location
CookLoc cookLocation = CookLoc();
