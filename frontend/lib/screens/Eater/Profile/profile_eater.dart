import 'dart:convert';
import 'package:dishtodoor/screens/Eater/Profile/profile_eater_information.dart';
import 'package:flutter/material.dart';
import 'package:dishtodoor/config/config.dart';
import 'package:dishtodoor/screens/auth/login.dart';
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
  bool isEaterEmpty = false;
  ProfileEaterInformation profileEaterInformation;
  TextEditingController fname = TextEditingController(text: "");
  TextEditingController lname = TextEditingController(text: "");

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

//for eater name modification
  Future<void> eaterNameMod() async {
    String token = await storage.read(key: 'token');
    final requestBody = jsonEncode({
      'first_name': fname.text,
      'last_name': lname.text,
    });
    print(requestBody);
    final http.Response response = await http.post(
      baseURL + '/eater/api/profile/name/set',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token.toString(),
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      dynamic decoded = jsonDecode(response.body);
      print("Received: " + decoded.toString());
      bool success = decoded['success'];
      if (success) {
        await eaterProfileInformationFetching();
        print("Successful! eater Name mod");
      } else {
        print("Error eater Name mod: " + decoded['error']);
      }
    } else {
      print(response.statusCode);
      print("An unkown error occured eater Name mod");
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
          fname = TextEditingController(
              text: profileEaterInformation.eaterProfile.firstName);
          lname = TextEditingController(
              text: profileEaterInformation.eaterProfile.lastName);
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

//Alert Dialaog
  Future<void> _changeNameAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change your name'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(hintText: 'First name'),
                  controller: fname,
                  style: TextStyle(fontSize: 14.0),
                ),
                TextField(
                  decoration: InputDecoration(hintText: 'Last name'),
                  controller: lname,
                  style: TextStyle(fontSize: 14.0),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Change'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
            InkWell(
              child: Text(
                profileEaterInformation.eaterProfile.firstName +
                    " " +
                    profileEaterInformation.eaterProfile.lastName,
                style: TextStyle(
                    fontSize: 40.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                await _changeNameAlert().then((value) async {
                  await eaterNameMod();
                });
              },
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
                  "User since " +
                      profileEaterInformation.dateAdded.year.toString() +
                      "-" +
                      profileEaterInformation.dateAdded.month.toString() +
                      "-" +
                      profileEaterInformation.dateAdded.day.toString(),
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
                onTap: () async {
                  await logoutNotif();
                  await storage.deleteAll().then((value) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => Login(),
                      ),
                      (route) => false,
                    );
                  });
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
        ),
      ),
    );
  }
}
