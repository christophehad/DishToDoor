import 'dart:convert';

import 'package:dishtodoor/screens/Cook/ImageUpload/cookKitchenUpload.dart';
import 'package:dishtodoor/screens/auth/login.dart';
import 'package:dishtodoor/screens/PageNavigation/page_navigator_cook.dart';
import 'package:dishtodoor/screens/PageNavigation/page_navigator_eater.dart';
import 'package:dishtodoor/screens/Cook/ImageUpload/waitingPage.dart';
import 'package:flutter/material.dart';
import 'package:dishtodoor/config/config.dart';
import 'package:dishtodoor/config/appProperties.dart';
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

    _tokenCheck().then((value) {
      controller.forward().then((_) {
        navigationPage();
      });
    });
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
          //check if cook is verified
          if (decoded['is_verified']) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => PageNavigatorCook()));
          } else {
            //route to a page where cook upload pictures
            if (await storage.containsKey(key: 'kitchenPics') == false ||
                await storage.read(key: 'kitchenPics') == 'false') {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => SingleImageUpload()));
            } else {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => WaitingPage()));
            }
          }

          print("Successful!");
        } else {
          print("Error: " + decoded['error']);
        }
      } else {
        print("Error: " + response.statusCode.toString());
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
        decoration: BoxDecoration(color: transparentBlue),
        child: SafeArea(
          child: new Scaffold(
            body: Column(
              children: <Widget>[
                Expanded(
                  child: Opacity(
                      opacity: opacity.value,
                      child: new Image.asset('assets/logos/DTDLogo.png')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
