import 'package:flutter/material.dart';
import 'Map/main_map.dart';
import 'Eater/Order_Tracking/orderTrackingEater.dart';
import 'Eater/Profile/profile_eater.dart';

//Eater Page Navigator

class PageNavigatorEater extends StatefulWidget {
  int indexInput = -1;
  PageNavigatorEater({Key key, this.indexInput}) : super(key: key);
  @override
  _PageNavigatorEater createState() => _PageNavigatorEater();
}

class _PageNavigatorEater extends State<PageNavigatorEater> {
  //CookList cookListLocal;
  int _currentIndex = 0; //track the index of our currently selected tab
  //list of widgets that we want to render based on the currently selected tab
  List<Widget> _children = [
    MainMap(),
    EaterTrackOrder(),
    ProfileEater(),
  ];

  @override
  void initState() {
    _indexCheck();
    super.initState();
  }

  //this function is called when an index is passed to page navigator
  //usually from notification system
  void _indexCheck() {
    print("index:" + widget.indexInput.toString());
    if (widget.indexInput != null) {
      print("inside index update: " + widget.indexInput.isNaN.toString());
      setState(() {
        _currentIndex = widget.indexInput;
      });
      print("current index: " + _currentIndex.toString());
    }
  }

  Future onTabTapped(int index) async {
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
