import 'dart:convert';

import 'package:dishtodoor/screens/auth/login.dart';
import 'package:dishtodoor/screens/page_navigator_cook.dart';
import 'package:dishtodoor/screens/page_navigator_eater.dart';
import 'package:flutter/material.dart';
import 'package:dishtodoor/config/config.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Animation<double> opacity;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: Duration(milliseconds: 4000), vsync: this);
    opacity = Tween<double>(begin: 1.0, end: 0.0).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.forward().then((_) {
      navigationPage();
    });
    _tokenCheck();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _tokenCheck() async {
    if (await storage.containsKey(key: 'email') == false) {
      print("not here");
      return;
    }
    String resT = await storage.read(key: "token");
    String resE = await storage.read(key: "email");
    String resP = await storage.read(key: "pass");
    String resType = await storage.read(key: "type");
    print(resE);
    print(resP);
    print(resType);

    if (resType == "eater") {
      final http.Response response = await http.post(
          baseURL + '/eater/login-email',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          },
          body: jsonEncode(<String, String>{
            "email": resE,
            "password": resP,
          }));

      if (response.statusCode == 200) {
        dynamic decoded = jsonDecode(response.body);
        print("Received: " + decoded.toString());
        bool success = decoded['success'];
        await storage.delete(key: 'token');
        await storage.write(key: 'token', value: decoded['token']);
        if (success) {
          //_registerSuccessfulAlert();
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => PageNavigatorEater()));
          print("Successful!");
        } else {
          print("Error: " + decoded['error']);
        }
      } else {
        print("An unkown error occured");
      }
    } else {
      final http.Response response = await http.post(
          baseURL + '/cook/login-email',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          },
          body: jsonEncode(<String, String>{
            "email": resE,
            "password": resP,
          }));

      if (response.statusCode == 200) {
        dynamic decoded = jsonDecode(response.body);
        print("Received: " + decoded.toString());
        bool success = decoded['success'];
        if (success) {
          //_registerSuccessfulAlert();
          //add cook info
          //add cook location only if hasn't been previously stored
          bool locAvailable = await storage.containsKey(key: 'location');
          if (locAvailable == false) {
            cookLocation.sendLoc().then((value) async {
              await storage.write(
                  key: 'location',
                  value: (cookLocation.cookLocation.latitude.toString() +
                      ',' +
                      cookLocation.cookLocation.latitude.toString()));
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
        }
      } else {
        print("An unkown error occured");
      }
    }
  }

  void navigationPage() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => Login()));
  }

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/food.jpg'), fit: BoxFit.cover)),
      child: Container(
        decoration: BoxDecoration(color: Color.fromRGBO(70, 184, 253, 0.7)),
        child: SafeArea(
          child: new Scaffold(
            body: Column(
              children: <Widget>[
                Expanded(
                  child: Opacity(
                      opacity: opacity.value,
                      child: new Image.asset('assets/logos/twitter.jpg')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
