import 'package:dishtodoor/screens/Eater/Order_Tracking/orderTracking2.dart';
import 'package:dishtodoor/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:dishtodoor/config/config.dart';
import 'package:geolocator/geolocator.dart';

class ProfileEater extends StatefulWidget {
  ProfileEater({Key key}) : super(key: key);
  @override
  _ProfileEaterState createState() => _ProfileEaterState();
}

class _ProfileEaterState extends State<ProfileEater> {
  DateTime pickupDate;
  bool datePicked = false;

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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => Login(
                          //cookList: cooks,
                          )));
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
            Positioned(
              top: 45,
              right: 15,
              child: IconButton(
                color: Colors.black,
                icon: Icon(Icons.zoom_in),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => Order()));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
