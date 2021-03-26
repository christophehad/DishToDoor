import 'dart:convert';

import 'package:dishtodoor/screens/Eater/Profile/profile_eater_information.dart';
import 'package:dishtodoor/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:dishtodoor/config/config.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class ProfileEater extends StatefulWidget {
  final ProfileEaterInformation profileEaterInformation;
  ProfileEater({Key key, this.profileEaterInformation}) : super(key: key);
  @override
  _ProfileEaterState createState() => _ProfileEaterState();
}

class _ProfileEaterState extends State<ProfileEater> {
  DateTime pickupDate;
  bool datePicked = false;
  bool isEaterEmpty = false;
  ProfileEaterInformation profileEaterInformation;

  @override
  void initState() {
    eaterProfileInformationFetching();
    super.initState();
  }

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

  Future<void> eaterProfileInformationFetching() async {
    print("trying comm order");
    String token = await storage.read(key: 'token');
    final http.Response response = await http.get(
      baseURL + '/eater/api/profile/get',
      headers: <String, String>{
        'Authorization': "Bearer " + token.toString(),
      },
    );

    if (response.statusCode == 200) {
      dynamic decoded = jsonDecode(response.body);
      print("Received: " + decoded.toString());
      bool success = decoded['success'];
      if (success) {
        setState(() {
          profileEaterInformation =
              ProfileEaterInformation.fromJson(decoded['eater']);
          isEaterEmpty = true;
        });
        print("Successful!");
      } else {
        print("Error: " + decoded['error']);
        isEaterEmpty = false;
      }
    } else {
      print(response.statusCode);
      isEaterEmpty = false;
      print("An unkown error occured");
    }
  }

  Widget build(BuildContext context) {
    if (profileEaterInformation == null && isEaterEmpty == false) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Colors.teal[200],
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            profileEaterInformation.eaterProfile.firstName +
                profileEaterInformation.eaterProfile.lastName, //get name
            style: TextStyle(
                fontSize: 40.0,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
            width: 200,
            child: Divider(
              color: Colors.teal.shade700,
            ),
          ),
          Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
              child: ListTile(
                  leading: Icon(
                    Icons.phone,
                    color: Colors.teal,
                  ),
                  title: Text(profileEaterInformation.phone,
                      //add phone number
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.teal,
                      )))),
          Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
              child: ListTile(
                  leading: Icon(
                    Icons.email,
                    color: Colors.teal,
                  ),
                  title: Text(profileEaterInformation.email,
                      //add email
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.teal,
                      )))),
          Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
            child: ListTile(
              leading: Icon(
                Icons.check,
                color: Colors.teal,
              ),
              title: Text(
                "Added since " + profileEaterInformation.date_added,
                //add verified since
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.teal,
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 10,
          ),
          Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.teal,
              ),
              onTap: () {
                storage.deleteAll();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Login(),
                  ),
                  (route) => false,
                );
              },
              title: Text(
                "Logout",
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.teal,
                ),
              ),
            ),
          ),
        ],
      )
          /*top: false,
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
        ),*/
          ),
    );
  }
}
