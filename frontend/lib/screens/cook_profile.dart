import 'package:dishtodoor/screens/cook_profile_information.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dishtodoor/config/config.dart';
import 'package:dishtodoor/screens/auth/login.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() => runApp(OrderApp());

class OrderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Horizontal Timeline',
      home: ProfileCook2(),
    );
  }
}

//TODO logout button
//TODO reset location
class ProfileCook2 extends StatefulWidget {
  final CookProfileInformation cookProfileInformation;
  ProfileCook2({Key key, this.cookProfileInformation}) : super(key: key);
  @override
  _ProfileCookState2 createState() => _ProfileCookState2();
}

class _ProfileCookState2 extends State<ProfileCook2> {
  DateTime pickupDate;
  bool datePicked = false;
  CookProfileInformation cookProfileInformation;
  bool isCookEmpty = false;

  @override
  void initState() {
    cookProfileInformationFetching();
    super.initState();
  }

  //delete notification token from backend
  Future<void> logoutNotif() async {
    String token = await storage.read(key: 'token');
    final http.Response response = await http.get(
      baseURL + '/cook/api/device/delete',
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
        print("Successfuly deleted notification token - cook!");
      } else {
        print("Error deleting notif token - cook: ");
      }
    } else {
      print(response.statusCode);
      print("An unkown error occured while deleting token - cook");
    }
  }

  Future<void> _changeLocationAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to change your location?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This action is permanent and irreversible.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                await _setLocation();
                return Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _setLocation() async {
    storage.delete(key: 'location');
    cookLocation.sendLoc().then((value) async {
      await storage.write(
          key: 'location',
          value: (cookLocation.cookLocation.latitude.toString() +
              ',' +
              cookLocation.cookLocation.longitude.toString()));
    });
  }

  //for cook name fetching
  Future<void> cookProfileInformationFetching() async {
    print("trying comm order");
    String token = await storage.read(key: 'token');
    final http.Response response = await http.get(
      baseURL + '/cook/api/profile/get',
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
          cookProfileInformation =
              CookProfileInformation.fromJson(decoded['cook']);
          isCookEmpty = true;
        });
        print("Successful!");
      } else {
        print("Error: " + decoded['error']);
        isCookEmpty = false;
      }
    } else {
      print(response.statusCode);
      isCookEmpty = false;
      print("An unkown error occured");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cookProfileInformation == null && isCookEmpty == false) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Colors.teal[200],
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: 50,
            backgroundImage:
                NetworkImage(cookProfileInformation.cookProfile.logo),
            //"https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"), //check here
          ),
          Text(
            cookProfileInformation.cookProfile.firstName +
                cookProfileInformation.cookProfile.lastName, //get name
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
                  title: Text(cookProfileInformation.phone,
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
                  title: Text(cookProfileInformation.email,
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
                    Icons.location_city,
                    color: Colors.teal,
                  ),
                  onTap: () {
                    _changeLocationAlert();
                  },
                  title: Text(
                      "Lat: " +
                          cookProfileInformation.cookProfile.lat.toString() +
                          " Lon: " +
                          cookProfileInformation.cookProfile.lon.toString(),
                      //add location
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
                "Added since " + cookProfileInformation.date_added,
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
      )),
    );
  }
}
