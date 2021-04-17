import 'package:dishtodoor/screens/Cook/GenericDishes/add_cook_dish.dart';
import 'package:flutter/material.dart';
import 'package:dishtodoor/screens/Cook/Profile/cook_profile.dart';
import 'package:dishtodoor/screens/Cook/OrderTracking/orderTrackingCook.dart';
import 'package:dishtodoor/config/appProperties.dart';

import 'package:dishtodoor/screens/Cook/Menu/cookAvailableMeals.dart';
//Eater Page Navigator

class PageNavigatorCook extends StatefulWidget {
  int indexInput;
  PageNavigatorCook({Key key, this.indexInput}) : super(key: key);
  @override
  _PageNavigatorCook createState() => _PageNavigatorCook();
}

class _PageNavigatorCook extends State<PageNavigatorCook> {
  int _currentIndex = 0; //track the index of our currently selected tab
  //list of widgets that we want to render based on the currently selected tab
  List<Widget> _children = [
    AddCookDish(),
    //if no cooks around, another map is displayed
    CookManageDishes(),
    CookTrackOrder(),
    ProfileCook2(),
  ];

  @override
  void initState() {
    _indexCheck();
    super.initState();
  }

  //this function is called when an index is passed to page navigaotr
  //usually from notification system
  void _indexCheck() {
    print("index:" + widget.indexInput.toString());
    if (widget.indexInput != null) {
      setState(() {
        _currentIndex = widget.indexInput;
      });
      print("current index: " + _currentIndex.toString());
    }
  }

  //takes in the tapped tab’s index and calls setState on our state class.
  //This will trigger the build method to be run again with the state that we pass in to it
  Future onTabTapped(int index) async {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[
          _currentIndex], //widget that gets displayed, equal to the corresponding widget in our _children widget list
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: blue,
        type: BottomNavigationBarType.fixed,
        onTap:
            onTabTapped, //function that will take the index of the tab that is tapped and decide what to do with it
        currentIndex:
            _currentIndex, //set the currentIndex of the bottom navigation bar to the current index held in our state’s _currentIndex property.
        items: [
          new BottomNavigationBarItem(
              icon: Icon(Icons.local_restaurant), label: 'Meals'),
          new BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded), label: 'Menu'),
          new BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Orders'),
          new BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile')
        ],
      ),
    );
  }
}
