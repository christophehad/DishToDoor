import 'dart:convert';
import 'package:dishtodoor/screens/auth/register_as_cook.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dishtodoor/config/config.dart';

import 'package:dishtodoor/screens/page_navigator_cook.dart';

//TODO safe storage for cook
class CookLoginEmail extends StatefulWidget {
  @override
  _CookLoginEmail createState() => _CookLoginEmail();
}

class _CookLoginEmail extends State<CookLoginEmail> {
  TextEditingController email = TextEditingController(text: "");

  TextEditingController password = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
  }

  //Error Alert
  Future<void> _registerErrorAlert(String e) async {
    String _errorDisp = "";
    if (e == "no_cook_email") {
      _errorDisp =
          "You don't seem to have an account with us, please signup first!";
    } else if (e == "wrong_password") {
      _errorDisp = "Wrong Password";
    } else {
      _errorDisp = "An unkown error occured, please try again later.";
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(_errorDisp),
              ],
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.done_rounded),
              onPressed: () {
                if (e == "no_eater_email") {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => RegisterCookPage()));
                } else if (e == "wrong_password") {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget loginButton = Positioned(
      left: MediaQuery.of(context).size.width / 4,
      bottom: 0,
      child: InkWell(
        onTap: () async {
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
            if (success) {
              //_registerSuccessfulAlert();
              //add cook info
              if (await storage.containsKey(key: 'email') == false) {
                print("storing");
                await storage.write(key: 'token', value: decoded['token']);
                await storage.write(key: 'email', value: email.text);
                await storage.write(key: 'pass', value: password.text);
                await storage.write(key: 'type', value: 'cook');
              }
              //add cook location only if hasn't been previously stored
              bool locAvailable = await storage.containsKey(key: 'location');
              if (locAvailable == false) {
                cookLocation.sendLoc().then((value) async {
                  await storage.write(
                      key: 'location',
                      value: (cookLocation.cookLocation.latitude.toString() +
                          ',' +
                          cookLocation.cookLocation.longitude.toString()));
                });
              }
              // if(gotLocation == false){

              // }
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => PageNavigatorCook()));
              print("Successful!");
              //print("Your token is" + globals.token);
            } else {
              print("Error: " + decoded['error']);
              _registerErrorAlert(decoded['error']);
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
