import 'package:flutter/material.dart';

class WaitingPage extends StatefulWidget {
  @override
  _WaitingPageState createState() {
    return _WaitingPageState();
  }
}

class _WaitingPageState extends State<WaitingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("We are still verifying your request!",
                  style: TextStyle(fontSize: 20)),
              SizedBox(
                height: 10,
              ),
              Icon(
                Icons.hourglass_bottom,
                size: 50,
                color: Colors.blueAccent.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
