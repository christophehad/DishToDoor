import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'placeholder_widget.dart';
import 'Map/main_map.dart';
import 'Map/cookless_map.dart';
import 'package:dishtodoor/screens/Map/cookClass.dart';
import 'Eater/Order_Tracking/orderTracking2.dart';
import 'package:dishtodoor/config/config.dart';
import 'Eater/Order_Tracking/orderClass.dart';
import 'package:http/http.dart' as http;
import 'Eater/Profile/profile_eater.dart';

//Eater Page Navigator

class PageNavigatorEater extends StatefulWidget {
  //final CookList cookList;
  PageNavigatorEater({Key key}) : super(key: key);
  @override
  _PageNavigatorEater createState() => _PageNavigatorEater();
}

class _PageNavigatorEater extends State<PageNavigatorEater> {
  //CookList cookListLocal;
  int _currentIndex = 0; //track the index of our currently selected tab
  //list of widgets that we want to render based on the currently selected tab
  List<Widget> _children = [];
  EaterOrderList orderList = EaterOrderList();
  LatLng _finaluserlocation;
  CookList cooks = CookList();
  Location _location = Location();

  @override
  void initState() {
    getLoc().then((value) => locsharing().then((value) {
          orderFetching();
          _children = [
            //PlaceholderWidget(Colors.red),
            //if no cooks around, another map is displayed
            cooks.cooksList != null
                ? MainMap(cookList: cooks)
                : MainMap2(
                    cookList: cooks,
                  ),
            Order(orderList: orderList),
            ProfileEater(),
          ];
        }));

    super.initState();
  }

  //for order fetching
  Future<void> orderFetching() async {
    print("trying comm order");
    String token = await storage.read(key: 'token');
    final http.Response response = await http.get(
      baseURL + '/eater/api/orders/get',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token.toString(),
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

  //for Map building
  Future<void> getLoc() async {
    var _loc = await _location.getLocation();
    setState(() {
      _finaluserlocation = LatLng(_loc.latitude, _loc.longitude);
    });
  }

  Future locsharing() async {
    print("trying comm");
    String token = await storage.read(key: 'token');
    print(await storage.containsKey(key: 'token'));
    final http.Response response = await http.get(
      baseURL +
          '/eater/api/dish/around?lat=' +
          _finaluserlocation.latitude.toString() +
          '&lon=' +
          _finaluserlocation.longitude.toString(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token.toString(),
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON and send user to login screen
      dynamic decoded = jsonDecode(response.body);
      debugPrint("Received: " + decoded.toString(), wrapWidth: 1024);
      bool success = decoded['success'];
      print("success: " + success.toString());
      print(decoded['cooks']);
      if (success) {
        setState(() {
          cooks = CookList.fromJson(decoded['cooks']);
        });

        debugPrint("debug print: " + cooks.cooksList.toString(),
            wrapWidth: 1024);
        //_registerSuccessfulAlert();
        print("Successful!");
      } else {
        //handle errors
        print("Error: " + decoded['error']);
        //_registerErrorAlert(decoded['error']);
      }
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      print("An unkown error occured");
    }
  }

  //takes in the tapped tab’s index and calls setState on our state class.
  //This will trigger the build method to be run again with the state that we pass in to it
  Future onTabTapped(int index) async {
    //here I am checking if order's tab is pressed to update the info faster and avoid null error
    if (index == 1) {
      await orderFetching().then((value) {
        setState(() {
          _children[index] = Order(
            orderList: orderList,
          );
        });
      });
    }
    if (index == 0) {
      await getLoc().then((value) {
        locsharing().then((value) => setState(() {
              _children[index] = cooks.cooksList != null
                  ? MainMap(cookList: cooks)
                  : MainMap2(
                      cookList: cooks,
                    );
            }));
      });
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_children.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
          //new BottomNavigationBarItem(
          //icon: Icon(Icons.local_restaurant), label: 'Order'),
          new BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          new BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Track'),
          new BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile')
        ],
      ),
    );
  }
}
