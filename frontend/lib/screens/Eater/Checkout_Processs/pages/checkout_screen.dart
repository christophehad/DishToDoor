import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dishtodoor/screens/Eater/Checkout_Processs/bloc/cart_items.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'size_config.dart';
import 'package:http/http.dart' as http;
import 'package:dishtodoor/screens/auth/globals.dart' as globals;
import 'package:dishtodoor/config/config.dart';

class Checkout extends StatelessWidget {
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
            top: 35,
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
                      checkoutProcedure(context, cartList);
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

//TODO: fix the API URL + alert boxes and errors
Future<void> checkoutProcedure(
    BuildContext context, List<CartTuple> cartList) async {
  CartItems temp = CartItems();
  temp.cartItems = cartList;
  final String requestBody = json.encoder.convert(temp);
  print(requestBody);
  final http.Response response = await http.post(
    baseURL + '/eater/login-email',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': "Bearer " + globals.token,
    },
    body: requestBody,
  );

  if (response.statusCode == 200) {
    dynamic decoded = jsonDecode(response.body);
    print("Received: " + decoded.toString());
    bool success = decoded['success'];
    globals.token = decoded['token'];
    if (success) {
      _registerSuccessfulAlert(context);
      bloc.emptyCart(); //empty the cart after success
      print("Successful!");
    } else {
      print("Error: " + decoded['error']);
    }
  } else {
    print("An unkown error occured");
  }
}

//TODO refactor alerts into one .dart file in config
//error Alert

//Alert Dialaog
Future<void> _registerSuccessfulAlert(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
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
            ])),
        subtitle: Text(cartList[i].dish.price.toString() + " LBP"),
        trailing: addRemoveDishes(cartList, i),
      );
    },
  );
}
