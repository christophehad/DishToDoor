import 'dart:convert';
import 'package:dishtodoor/screens/auth/login.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:dishtodoor/app_properties.dart';
import 'register_as_cook.dart';
import 'package:dishtodoor/config/config.dart';

class RegisterEaterPage extends StatefulWidget {
  @override
  _RegisterEaterPageState createState() => _RegisterEaterPageState();
}

class _RegisterEaterPageState extends State<RegisterEaterPage> {
  TextEditingController email = TextEditingController(text: "");

  TextEditingController password = TextEditingController(text: "");

  TextEditingController fname = TextEditingController(text: "");
  TextEditingController lname = TextEditingController(text: "");
  String phonenumber = "";

  @override
  Widget build(BuildContext context) {
    Widget title = Text(
      'Welcome!',
      style: TextStyle(
          color: Colors.white,
          fontSize: 34.0,
          fontWeight: FontWeight.bold,
          shadows: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.15),
              offset: Offset(0, 5),
              blurRadius: 10.0,
            )
          ]),
    );

//Error Alert
    Future<void> _registerErrorAlert(String e) async {
      String _errorDisp = "";
      if (e == "missing_credentials") {
        _errorDisp = "Please fill out all the fields.";
      } else if (e == "email_used") {
        _errorDisp =
            "This email was used previously, please select another one.";
      } else if (e == "phone_used") {
        _errorDisp =
            "This phone number was used previously, please select another one.";
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
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => Login()));
                },
              ),
            ],
          );
        },
      );
    }

//Alert Dialaog
    Future<void> _registerSuccessfulAlert() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success!'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('You have successfuly registered.'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Continue'),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => Login()));
                },
              ),
            ],
          );
        },
      );
    }

    Widget subTitle = Padding(
        padding: const EdgeInsets.only(right: 56.0),
        child: Text(
          'Sign-up to start exploring dishes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ));

    Widget registerButton = Positioned(
      left: MediaQuery.of(context).size.width / 4,
      bottom: 20,
      child: InkWell(
        //MODIFY to different button - here onTap should communicate with backend
        onTap: () async {
          final http.Response response = await http.post(
            baseURL + '/eater/register',
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'email': email.text,
              'phone': phonenumber,
              'password': password.text,
              'first_name': fname.text,
              'last_name': lname.text,
            }),
          );
          if (response.statusCode == 200) {
            // If the server did return a 200 CREATED response,
            // then parse the JSON and send user to login screen
            dynamic decoded = jsonDecode(response.body);
            print("Received: " + decoded.toString());
            bool success = decoded['success'];
            if (success) {
              _registerSuccessfulAlert();
              print("Successful!");
            } else
              //handle errors
              print("Error: " + decoded['error']);
            _registerErrorAlert(decoded['error']);
          } else {
            // If the server did not return a 201 CREATED response,
            // then throw an exception.
            print("An unkown error occured");
          }
        },

        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          height: 80,
          child: Center(
              child: new Text("Register",
                  style: const TextStyle(
                      color: const Color(0xfffefefe),
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      fontSize: 20.0))),
          decoration: BoxDecoration(
              gradient: mainButton,
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

    Widget registerForm = Container(
      height: 400,
      child: Stack(
        children: <Widget>[
          Container(
            height: 320,
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
                    decoration: InputDecoration(hintText: 'First Name'),
                    controller: fname,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Last Name'),
                    controller: lname,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: IntlPhoneField(
                    decoration: InputDecoration(
                        labelText: 'Phone Number',
                        suffixIcon: Icon(Icons.phone)),
                    initialCountryCode: 'LB',
                    onChanged: (phone) {
                      print(phone.completeNumber);
                      phonenumber = phone.number;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    decoration: InputDecoration(hintText: 'email'),
                    controller: email,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextField(
                    decoration: InputDecoration(hintText: 'password'),
                    controller: password,
                    style: TextStyle(fontSize: 16.0),
                    obscureText: true,
                  ),
                ),
              ],
            ),
          ),
          registerButton,
        ],
      ),
    );

    Widget socialRegister = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Sign-up as a cook',
          style: TextStyle(
              fontSize: 13.0, fontStyle: FontStyle.italic, color: Colors.white),
        ),
        IconButton(
          icon: Icon(Icons.room_service),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => RegisterCookPage()));
          },
          color: Colors.white,
        ),
      ],
    );

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/background_signup_eater.jpg'),
                    fit: BoxFit.cover)),
          ),
          Container(
            decoration: BoxDecoration(
              color: transparentYellow,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Spacer(flex: 3),
                title,
                Spacer(),
                subTitle,
                Spacer(flex: 2),
                registerForm,
                Spacer(flex: 2),
                Padding(
                    padding: EdgeInsets.only(bottom: 20), child: socialRegister)
              ],
            ),
          ),
          Positioned(
            top: 35,
            left: 5,
            child: IconButton(
              color: Colors.white,
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
    );
  }
}
