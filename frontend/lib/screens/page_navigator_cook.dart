import 'package:dishtodoor/screens/Cook/add_cook_dish.dart';
import 'package:flutter/material.dart';
import 'placeholder_widget.dart';
import 'Cook/orderTrackingCook.dart';
import 'cook_profile.dart';
import 'package:dishtodoor/screens/Cook/cookAvailableMeals.dart';
//Eater Page Navigator

class PageNavigatorCook extends StatefulWidget {
  PageNavigatorCook({Key key}) : super(key: key);
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
    PlaceholderWidget(Colors.green),
    ProfileCook2(),
  ];

  @override
  void initState() {
    super.initState();
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
