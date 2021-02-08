import 'package:dishtodoor/screens/Map/cookClass.dart';
import 'package:dishtodoor/screens/Map/main_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:dishtodoor/screens/auth/cook_login_email.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;

import 'package:dishtodoor/config/config.dart';
import 'package:location/location.dart';

class EaterLoginEmail extends StatefulWidget {
  @override
  _EaterLoginEmail createState() => _EaterLoginEmail();
}

class _EaterLoginEmail extends State<EaterLoginEmail> {
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
        'Authorization': "Bearer " + globals.token,
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
    super.initState();
    getLoc();
  }

  @override
  Widget build(BuildContext context) {
    Widget loginButton = Positioned(
      left: MediaQuery.of(context).size.width / 4,
      bottom: 0,
      child: InkWell(
        onTap: () async {
          final http.Response response = await http.post(
              baseURL + '/eater/login-email',
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

              locsharing()
                  .then((value) => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => MainMap(
                            cookList: cooks,
                          ))));
            } else {
              print("Error: " + decoded['error']);
            }
          } else {
            print("An unkown error occured");
          }
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

    Widget socialRegister = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Login as a cook',
          style: TextStyle(
              fontSize: 13.0, fontStyle: FontStyle.italic, color: Colors.white),
        ),
        IconButton(
          icon: Icon(Icons.room_service),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => CookLoginEmail()));
          },
          color: Colors.white,
        ),
      ],
    );

    return Scaffold(
        backgroundColor: Colors.blue[100],
        body: Stack(children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[loginForm, forgotPassword, socialRegister],
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
