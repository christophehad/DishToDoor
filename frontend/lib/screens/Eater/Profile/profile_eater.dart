import 'dart:convert';

import 'package:dishtodoor/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:dishtodoor/config/config.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class ProfileEater extends StatefulWidget {
  ProfileEater({Key key}) : super(key: key);
  @override
  _ProfileEaterState createState() => _ProfileEaterState();
}

class _ProfileEaterState extends State<ProfileEater> {
  DateTime pickupDate;
  bool datePicked = false;

  //delete notification token from backend
  Future<void> logoutNotif() async {
    String token = await storage.read(key: 'token');
    final http.Response response = await http.get(
      baseURL + '/eater/api/device/delete',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token.toString(),
      },
    );

    if (response.statusCode == 200) {
      dynamic decoded = jsonDecode(response.body);
      print("Received: " + decoded.toString());
      bool success = decoded['success'];
      if (success) {
        print("Successfuly deleted notification token - eater!");
      } else {
        print("Error deleting notif token - eater: ");
      }
    } else {
      print(response.statusCode);
      print("An unkown error occured while deleting token - eater");
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height / 2,
              left: MediaQuery.of(context).size.width / 2,
              child: InkWell(
                splashColor: Colors.blue,
                child: Text("Logout"),
                onTap: () {
                  storage.deleteAll();
                  logoutNotif();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => Login(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ),
            Positioned(
              top: 45,
              left: 5,
              child: IconButton(
                color: Colors.black,
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
