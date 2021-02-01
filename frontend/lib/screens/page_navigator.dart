import 'package:dishtodoor/screens/add_generic_dish.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'globals.dart' as globals;
import 'placeholder_widget.dart';

class PageNavigator extends StatefulWidget {
  @override
  _PageNavigator createState() => _PageNavigator();
}

class _PageNavigator extends State<PageNavigator> {
  TextEditingController email = TextEditingController(text: "");
  TextEditingController password = TextEditingController(text: "");
  int _currentIndex = 0; //track the index of our currently selected tab
  final List<Widget> _children = [
    AddGenericDish(),
    PlaceholderWidget(Colors.deepOrange),
    PlaceholderWidget(Colors.white),
    PlaceholderWidget(Colors.green),
    PlaceholderWidget(Colors.blue)
  ]; //list of widgets that we want to render based on the currently selected tab

  //takes in the tapped tab’s index and calls setState on our state class.
  //This will trigger the build method to be run again with the state that we pass in to it
  void onTabTapped(int index) {
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
