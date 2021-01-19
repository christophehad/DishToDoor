import 'package:dishtodoor/app_properties.dart';
import 'package:dishtodoor/screens/auth/login.dart';
import 'package:flutter/material.dart';

import 'package:dishtodoor/screens/auth/register_page.dart';

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
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: RichText(
                //     text: TextSpan(
                //         style: TextStyle(color: Colors.black),
                //         children: [
                //           // TextSpan(text: 'Powered by '),
                //           // TextSpan(
                //           //     text: 'DishToDoor',
                //           //     style: TextStyle(fontWeight: FontWeight.bold))
                //         ]),
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
