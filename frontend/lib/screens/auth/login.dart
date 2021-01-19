import 'package:intl_phone_field/intl_phone_field.dart'; //
import 'package:flutter/material.dart';

import 'package:dishtodoor/screens/auth/login_email.dart';
import 'register_page.dart';

class Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> {
  TextEditingController email =
      TextEditingController(text: 'example@email.com');
  TextEditingController password = TextEditingController(text: '12345678');

  @override
  Widget build(BuildContext context) {
    Widget loginText = Column(children: <Widget>[
      SizedBox(height: 50),
      Align(
          alignment: Alignment.center,
          child: Text(
            'Login',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 35.0,
              fontWeight: FontWeight.bold,
            ),
          ))
    ]);

    Widget logo = Align(
        alignment: Alignment.center,
        child:
            Image.asset("assets/logos/twitter.jpg", height: 150, width: 150));

    Widget otpButton = Positioned(
      left: MediaQuery.of(context).size.width / 4,
      bottom: 0,
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => RegisterPage()));
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          height: 50,
          child: Center(
              child: new Text("Send OTP",
                  style: const TextStyle(color: Colors.white, fontSize: 20.0))),
          decoration: BoxDecoration(
              color: Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.2),
                  offset: Offset(0, 5),
                  blurRadius: 10.0,
                )
              ],
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );

    Widget phoneNumber = Padding(
        padding: EdgeInsets.only(left: 28.0),
        child: Container(
          height: 135,
          child: Stack(
            children: <Widget>[
              Container(
                  height: 110,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(
                      left: 32.0, right: 12.0, bottom: 30.0),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 0.8),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10))),
                  child: IntlPhoneField(
                    decoration: InputDecoration(
                        labelText: 'Phone Number',
                        suffixIcon: Icon(Icons.phone)),
                    initialCountryCode: 'LB',
                    onChanged: (phone) {
                      print(phone.completeNumber);
                    },
                  )),
              otpButton,
            ],
          ),
        ));

    Widget emailLogin = Column(children: <Widget>[
      SizedBox(height: 20),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.0),
          child: ButtonTheme(
              minWidth: MediaQuery.of(context).size.width,
              height: 50,
              child: RaisedButton(
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => LoginEmail())),
                  child: Text('Continue with email',
                      style: TextStyle(fontSize: 20, color: Colors.white))))),
      SizedBox(height: 20)
    ]);

    Widget divider = Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('OR'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );

    Widget signInWithText = Align(
      alignment: Alignment.topCenter,
      child: Text('Sign in with'),
    );

    Widget socialBtnRow = Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            height: 60.0,
            width: 60.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 6.0,
                ),
              ],
              image: DecorationImage(
                  image: AssetImage('assets/logos/facebook.jpg')),
            ),
          ),
          Container(
            height: 60.0,
            width: 60.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 6.0,
                ),
              ],
              image:
                  DecorationImage(image: AssetImage('assets/logos/google.jpg')),
            ),
          )
        ],
      ),
    );

    Widget signupBtn = Align(
        alignment: Alignment.center,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Don\'t have an account? ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: 'Sign Up',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ));

    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          loginText,
          logo,
          phoneNumber,
          emailLogin,
          divider,
          signInWithText,
          socialBtnRow,
          signupBtn
        ],
      ),
    );
  }
}
