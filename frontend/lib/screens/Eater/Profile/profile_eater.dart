import 'package:dishtodoor/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:dishtodoor/config/config.dart';

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
        ),
      ),
    );
  }
}
