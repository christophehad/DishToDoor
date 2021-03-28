import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dishtodoor/screens/Eater/Checkout_Processs/bloc/cart_items.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'size_config.dart';
import 'package:http/http.dart' as http;
import 'package:dishtodoor/config/config.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:dishtodoor/screens/splash.dart';

class Checkout extends StatefulWidget {
  Checkout({Key key}) : super(key: key);
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  DateTime pickupDate;
  bool datePicked = false;

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder(
            stream: bloc.getStream,
            initialData: bloc.cartItems,
            builder: (context, snapshot) {
              final List<CartTuple> cartList = snapshot.data;
              SizeConfig().init(context);
              return Column(
                children: <Widget>[
                  /// The [checkoutListBuilder] has to be fixed
                  /// in an expanded widget to ensure it
                  /// doesn't occupy the whole screen and leaves
                  /// room for the the RaisedButton
                  Expanded(child: checkoutListBuilder(snapshot)),
                  checkoutTab(context, cartList),
                ],
              );
            },
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
    );
  }

//bottom checkout with total
  Widget checkoutTab(BuildContext context, List<CartTuple> cartList) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: getProportionateScreenWidth(15),
        horizontal: getProportionateScreenWidth(30),
      ),
      // height: 174,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -15),
            blurRadius: 20,
            color: Color(0xFFDADADA).withOpacity(0.15),
          )
        ],
      ),
      child: SafeArea(
        bottom: true,
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  height: getProportionateScreenWidth(40),
                  width: getProportionateScreenWidth(40),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F6F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset("assets/receipt.svg"),
                ),
                Spacer(),
                FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: Colors.blueAccent,
                  onPressed: () {
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true, onChanged: (date) {
                      print('change $date in time zone ' +
                          date.timeZoneOffset.inHours.toString());
                    }, onConfirm: (date) {
                      print('confirm $date');
                      setState(() {
                        pickupDate = date;
                        datePicked = true;
                      });
                    }, currentTime: DateTime.now());
                  },
                  child: Text(
                    "Pickup time",
                    style: TextStyle(
                      fontSize: getProportionateScreenWidth(18),
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: getProportionateScreenHeight(20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: "Total:\n",
                    children: [
                      TextSpan(
                        text: bloc.totalCost().toString() + " LBP",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: getProportionateScreenWidth(190),
                  child: SizedBox(
                    width: double.infinity,
                    height: getProportionateScreenHeight(56),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: Colors.blueAccent,
                      onPressed: () {
                        if (datePicked == true) {
                          checkoutProcedure(context, cartList, pickupDate);
                        } else {
                          _popUpPickTime(context);
                        }
                      },
                      child: Text(
                        "Checkout",
                        style: TextStyle(
                          fontSize: getProportionateScreenWidth(18),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkoutProcedure(BuildContext context, List<CartTuple> cartList,
      DateTime pickupDate) async {
    String token = await storage.read(key: 'token');
    CartItems temp = CartItems();
    temp.cartItems = cartList;
    temp.pickupDate = pickupDate;
    print(temp.pickupDate);
    final String requestBody = json.encoder.convert(temp);
    print(requestBody);
    final http.Response response = await http.post(
      baseURL + '/eater/api/dish/checkout',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token.toString(),
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      dynamic decoded = jsonDecode(response.body);
      print("Received: " + decoded.toString());
      bool success = decoded['success'];
      if (success) {
        _registerSuccessfulAlert(context);
        bloc.emptyCart(); //empty the cart after success
        print("Successful!");
      } else {
        _registerErrorAlert(decoded['error'], context);
        print("Error: " + decoded['error']);
      }
    } else {
      print(response.statusCode);
      print("An unkown error occured");
    }
  }

//TODO refactor alerts into one .dart file in config
//Error Alert
  Future<void> _registerErrorAlert(String e, BuildContext context) async {
    String _errorDisp = "";
    if (e == "missing_fields") {
      _errorDisp = "Please fill out all the fields.";
    } else if (e == "total_price_wrong") {
      _errorDisp = "You've encountered a very rare bug!";
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
                if (e == "missing_fields") {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => SplashScreen()));
                }
              },
            ),
          ],
        );
      },
    );
  }

//Alert Dialaog
  Future<void> _registerSuccessfulAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your order will be processed by the cook(s)!'),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _popUpPickTime(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Oops!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please choose a pickup time!'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget addRemoveDishes(List<CartTuple> cartList, var i) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            bloc.addToCart(cartList[i]);
          },
        ),
        SizedBox(
          child: Text(cartList[i].count.toString()),
        ),
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () {
            bloc.removeFromCart(cartList[i]);
          },
        ),
      ],
    );
  }

  Widget checkoutListBuilder(snapshot) {
    return ListView.builder(
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, i) {
        final List<CartTuple> cartList = snapshot.data;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(cartList[i].dish.dishPic.toString()),
          ),
          title: RichText(
              text: TextSpan(
                  // set the default style for the children TextSpans
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(fontSize: 13),
                  children: [
                TextSpan(
                  text: cartList[i].dish.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                TextSpan(
                  text: " | " +
                      cartList[i].cookFname +
                      " " +
                      cartList[i].cookLname,
                  style: TextStyle(fontSize: 17),
                ),
              ])),
          subtitle: Text(cartList[i].dish.price.toString() + " LBP"),
          trailing: addRemoveDishes(cartList, i),
        );
      },
    );
  }
}
