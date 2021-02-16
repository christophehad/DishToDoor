import 'dart:convert';

import 'package:dishtodoor/screens/add_generic_dish.dart';
import 'package:flutter/material.dart';
import 'auth/globals.dart' as globals;
import 'placeholder_widget.dart';
import 'Map/main_map.dart';
import 'Map/cookless_map.dart';
import 'package:dishtodoor/screens/Map/cookClass.dart';
import 'Eater/Order_Tracking/orderTracking2.dart';
import 'package:dishtodoor/config/config.dart';
import 'Eater/Order_Tracking/orderClass.dart';
import 'package:http/http.dart' as http;

class PageNavigator extends StatefulWidget {
  final CookList cookList;
  PageNavigator({Key key, this.cookList}) : super(key: key);
  @override
  _PageNavigator createState() => _PageNavigator();
}

class _PageNavigator extends State<PageNavigator> {
  CookList cookListLocal;
  TextEditingController email = TextEditingController(text: "");
  TextEditingController password = TextEditingController(text: "");
  int _currentIndex = 0; //track the index of our currently selected tab
  //list of widgets that we want to render based on the currently selected tab
  List<Widget> _children = [];
  EaterOrderList orderList;

  //for order fetching
  Future<void> orderFetching() async {
    print("trying comm order");
    final http.Response response = await http.get(
      baseURL + '/eater/api/orders/get',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + globals.token,
      },
    );

    if (response.statusCode == 200) {
      dynamic decoded = jsonDecode(response.body);
      print("Received: " + decoded.toString());
      bool success = decoded['success'];
      if (success) {
        setState(() {
          orderList = EaterOrderList.fromJson(decoded['orders']);
        });
        print("Successful!");
      } else {
        print("Error: " + decoded['error']);
      }
    } else {
      print(response.statusCode);
      print("An unkown error occured");
    }
  }

  @override
  void initState() {
    orderFetching();
    _children = [
      AddGenericDish(),
      //if no cooks around, another map is displayed
      widget.cookList.cooksList != null
          ? MainMap(cookList: widget.cookList)
          : MainMap2(
              cookList: widget.cookList,
            ),
      Order(orderList: orderList),
      PlaceholderWidget(Colors.green),
      PlaceholderWidget(Colors.blue)
    ];

    super.initState();
  }

  //takes in the tapped tab’s index and calls setState on our state class.
  //This will trigger the build method to be run again with the state that we pass in to it
  Future onTabTapped(int index) async {
    //here I am checking if order's tab is pressed to update the info faster and avoid null error
    if (index == 2) {
      await orderFetching().then((value) {
        setState(() {
          _children[index] = Order(
            orderList: orderList,
          );
        });
      });
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  appBar: AppBar(
      //    title: Text('My Flutter App'),
      //  ),
      body: _children[
          _currentIndex], //widget that gets displayed, equal to the corresponding widget in our _children widget list
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap:
            onTabTapped, //function that will take the index of the tab that is tapped and decide what to do with it
        currentIndex:
            _currentIndex, //set the currentIndex of the bottom navigation bar to the current index held in our state’s _currentIndex property.
        items: [
          new BottomNavigationBarItem(
              icon: Icon(Icons.local_restaurant), label: 'Meals'),
          new BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Discover'),
          new BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Orders'),
          new BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Analytics'),
          new BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile')
        ],
      ),
    );
  }
}
