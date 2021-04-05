import 'package:intl_phone_field/intl_phone_field.dart'; //
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:dishtodoor/screens/auth/eater_login_email.dart';
import 'register_as_eater.dart';

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
            Image.asset("assets/logos/DTDLogo.png", height: 150, width: 150));

    Widget otpButton = Positioned(
      left: MediaQuery.of(context).size.width / 4,
      bottom: 0,
      child: InkWell(
        onTap: () {
          //Add OTP page navigation
          // Navigator.of(context)
          //     .push(MaterialPageRoute(builder: (_) => PageNavigator()));
          //.push(MaterialPageRoute(builder: (_) => MyHomePage()));
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          height: 50,
          child: Center(
              child: new Text("Send OTP",
                  style: const TextStyle(color: Colors.white, fontSize: 20.0))),
          decoration: BoxDecoration(
              color: Colors.blueAccent,
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
                      color: Colors.grey.shade200,
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
                  color: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => EaterLoginEmail())),
                  child: Text('Continue with email',
                      style: TextStyle(fontSize: 20, color: Colors.white))))),
      SizedBox(height: 20)
    ]);

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
                recognizer: new TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => RegisterEaterPage()));
                  },
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              loginText,
              SizedBox(height: 10),
              logo,
              SizedBox(height: 10),
              phoneNumber,
              emailLogin,
              SizedBox(
                height: 100,
              ),
              signupBtn
            ],
          ),
        ),
      ),
    );
  }
}
