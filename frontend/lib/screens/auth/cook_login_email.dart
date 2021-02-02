import 'package:intl_phone_field/intl_phone_field.dart';
import 'dart:convert';
import 'package:dishtodoor/app_properties.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;
import 'register_page.dart';
import 'package:dishtodoor/screens/Map/main_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dishtodoor/screens/Map/cookClass.dart';
import 'package:flutter/material.dart';
import 'package:dishtodoor/config/config.dart';
import 'package:location/location.dart';

class CookLoginEmail extends StatefulWidget {
  @override
  _CookLoginEmail createState() => _CookLoginEmail();
}

class _CookLoginEmail extends State<CookLoginEmail> {
  TextEditingController email = TextEditingController(text: "");

  TextEditingController password = TextEditingController(text: "");

//Getting location before hand
//TODO move to page before map later
// get Location of user

  LatLng _finaluserlocation;
  CookList cooks;
  Location _location = Location();

  Future<void> getLoc() async {
    var _loc = await _location.getLocation();
    setState(() {
      _finaluserlocation = LatLng(_loc.latitude, _loc.longitude);
    });
  }

  Future locsharing() async {
    print("trying comm");
    final http.Response response = await http.get(
      baseURL +
          '/eater/api/dish/around?lat=' +
          _finaluserlocation.latitude.toString() +
          '&lon=' +
          _finaluserlocation.longitude.toString(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNjEyMTEwMTgwfQ.TdVSbEd7yzVWC4tBz_QdCV9ZujR8_0C3gfTLcTjoRCg",
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON and send user to login screen
      dynamic decoded = jsonDecode(response.body);
      print("Received: " + decoded.toString());
      bool success = decoded['success'];
      print("success: " + success.toString());
      print(decoded['cooks']);
      if (success) {
        cooks = CookList.fromJson(decoded['cooks']);
        print(cooks.cooksList);
        //_registerSuccessfulAlert();
        print("Successful!");
      } else {
        //handle errors
        print("Error: " + decoded['error']);
        //_registerErrorAlert(decoded['error']);
      }
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      print("An unkown error occured");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoc().then((value) => locsharing());
  }

  @override
  Widget build(BuildContext context) {
    Widget loginButton = Positioned(
      left: MediaQuery.of(context).size.width / 4,
      bottom: 0,
      child: InkWell(
        onTap: () async {
          String baseURL = "http://b1c84252cafb.eu.ngrok.io";
          final http.Response response = await http.post(
              baseURL + '/cook/login-email',
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8'
              },
              body: jsonEncode(<String, String>{
                "email": email.text,
                "password": password.text,
              }));

          if (response.statusCode == 200) {
            dynamic decoded = jsonDecode(response.body);
            print("Received: " + decoded.toString());
            bool success = decoded['success'];
            globals.token = decoded['token'];
            if (success) {
              //_registerSuccessfulAlert();
              print("Successful!");
              print("Your token is" + globals.token);
            } else {
              print("Error: " + decoded['error']);
            }
          } else {
            print("An unkown error occured");
          }
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MainMap(
                    cookList: cooks,
                  )));
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          height: 52,
          child: Center(
              child: new Text("Login",
                  style: const TextStyle(
                      color: const Color(0xfffefefe),
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      fontSize: 20.0))),
          decoration: BoxDecoration(
              color: Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.16),
                  offset: Offset(0, 5),
                  blurRadius: 10.0,
                )
              ],
              borderRadius: BorderRadius.circular(9.0)),
        ),
      ),
    );

    Widget loginForm = Column(children: <Widget>[
      SizedBox(height: 90),
      Container(
        height: 180,
        child: Stack(
          children: <Widget>[
            Container(
              height: 150,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(left: 32.0, right: 12.0),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.8),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: 'Email', suffixIcon: Icon(Icons.email)),
                      controller: email,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: 'Password',
                          suffixIcon: Icon(Icons.visibility_off)),
                      controller: password,
                      style: TextStyle(fontSize: 16.0),
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ),
            loginButton,
          ],
        ),
      )
    ]);

    Widget forgotPassword = Align(
        alignment: Alignment.centerRight,
        child: Column(children: <Widget>[
          SizedBox(height: 20),
          Padding(
              padding: const EdgeInsets.only(right: 32),
              child: Text(
                'Forgot Password ?',
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ))
        ]));

    return Scaffold(
        backgroundColor: Colors.blue[100],
        body: Stack(children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[loginForm, forgotPassword],
              )),
          Positioned(
              top: 35,
              left: 5,
              child: IconButton(
                color: Colors.white,
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ))
        ]));
  }
}
