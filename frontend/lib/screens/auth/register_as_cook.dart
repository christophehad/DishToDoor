import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:dishtodoor/app_properties.dart';
import 'package:dishtodoor/screens/auth/login.dart';

class RegisterCookPage extends StatefulWidget {
  @override
  _RegisterCookPageState createState() => _RegisterCookPageState();
}

class _RegisterCookPageState extends State<RegisterCookPage> {
  TextEditingController email = TextEditingController(text: "");

  TextEditingController password = TextEditingController(text: "");

  TextEditingController fname = TextEditingController(text: "");
  TextEditingController lname = TextEditingController(text: "");

  TextEditingController experience = TextEditingController(text: '');
  String dropdownvalue_cert = 'Yes';
  String dropdownvalue_train = 'Yes';
  String dropdownvalue_inspect = 'Yes';
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
                  Text(
                      'We will process your request and get back to you soon!'),
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

    Widget subTitle = Padding(
        padding: const EdgeInsets.only(right: 56.0),
        child: Text(
          'Sign-up to start your cooking journey',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ));

    Widget registerButton = Positioned(
      left: MediaQuery.of(context).size.width / 4,
      bottom: 15,
      child: InkWell(
        //MODIFY to different button - here onTap should communicate with backend
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
        onTap: () async {
          String baseURL = "http://c1b1702a4094.eu.ngrok.io";
          final http.Response response = await http.post(
            baseURL + '/cook/register',
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'email': email.text,
              'phone': phonenumber,
              'password': password.text,
              'first_name': fname.text,
              'last_name': lname.text,

              //MODIFY by adding relevant COOK parts
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
              print("Error: " + decoded['error']);
          } else {
            // If the server did not return a 201 CREATED response,
            // then throw an exception.
            print("An unkown error occured");
          }
        },
      ),
    );

//FIND A WAY TO REFACTOR REDUNDANT CODE

    Widget dropDownMenu_Cert = Container(
        alignment: Alignment.centerLeft,
        child: DropdownButton<String>(
          value: dropdownvalue_cert,
          dropdownColor: Colors.grey[200],
          isDense: true,
          icon: Icon(Icons.arrow_downward),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String newValue) {
            setState(() {
              dropdownvalue_cert = newValue;
            });
          },
          items: <String>['Yes', 'No']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ));

    Widget dropDownMenu_Train = Container(
        alignment: Alignment.centerLeft,
        child: DropdownButton<String>(
          value: dropdownvalue_train,
          dropdownColor: Colors.grey[200],
          isDense: true,
          icon: Icon(Icons.arrow_downward),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String newValue) {
            setState(() {
              dropdownvalue_train = newValue;
            });
          },
          items: <String>['Yes', 'No']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ));

    Widget dropDownMenu_Inspect = Container(
        alignment: Alignment.centerLeft,
        child: DropdownButton<String>(
          value: dropdownvalue_inspect,
          dropdownColor: Colors.grey[200],
          isDense: true,
          icon: Icon(Icons.arrow_downward),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String newValue) {
            setState(() {
              dropdownvalue_inspect = newValue;
            });
          },
          items: <String>['Yes', 'No']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ));

    Widget registerForm = Container(
      height: 600,
      child: Stack(
        children: <Widget>[
          Container(
            height: 525,
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
                  padding: const EdgeInsets.only(top: 7.0),
                  child: TextField(
                    decoration: InputDecoration(hintText: 'First name'),
                    controller: fname,
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 7.0),
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Last name'),
                    controller: lname,
                    style: TextStyle(fontSize: 14.0),
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
                  padding: const EdgeInsets.only(top: 7.0),
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Email'),
                    controller: email,
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 7.0),
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Password'),
                    controller: password,
                    style: TextStyle(fontSize: 14.0),
                    obscureText: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 7.0, bottom: 7.0),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Tell us about your cooking experience'),
                    controller: experience,
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text("Are you a certified chef?",
                        style: const TextStyle(fontSize: 14.0),
                        textAlign: TextAlign.left),
                  ),
                ),
                dropDownMenu_Cert, //calling the drop down menu widget
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                        "Are you willing to take a Food Safety Training?",
                        style: const TextStyle(fontSize: 14.0),
                        textAlign: TextAlign.left),
                  ),
                ),
                dropDownMenu_Train,
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text("Do you consent to an on-site inspection?",
                        style: const TextStyle(fontSize: 14.0),
                        textAlign: TextAlign.left),
                  ),
                ),
                dropDownMenu_Inspect,
              ],
            ),
          ),
          registerButton,
        ],
      ),
    );

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/chef_cooking.jpg'),
                    fit: BoxFit.cover)),
          ),
          Container(
            decoration: BoxDecoration(
              color: transparentYellow,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Spacer(flex: 3),
                title,
                Spacer(),
                subTitle,
                Spacer(),
                registerForm,
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
