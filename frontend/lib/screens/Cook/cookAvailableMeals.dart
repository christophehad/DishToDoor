import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:dishtodoor/config/config.dart';
import 'package:dishtodoor/screens/Cook/orderClassCook.dart';
import 'package:dishtodoor/screens/Eater/Map/cookClass.dart';
import 'package:intl/intl.dart';
import 'package:dishtodoor/config/appProperties.dart';

const deliverySteps = ['Pending', 'Cooking', 'Ready'];

class CookManageDishes extends StatefulWidget {
  final List<CookOrderList> allDishes;
  CookManageDishes({Key key, this.allDishes}) : super(key: key);
  @override
  CookManageDishesState createState() => CookManageDishesState();
}

class CookManageDishesState extends State<CookManageDishes> {
  DishList allDishes = DishList();
  DishList availableDishes = DishList();

  Color doneButton = Colors.green;
  Color removeButton = Colors.red;
  DateTime openingTime;
  DateTime closingTime;

  @override
  void initState() {
    super.initState();
    getDishes();
    getAvaliableDishes();
  }

//fetching order details
  Future<void> getDishes() async {
    String token = await storage.read(key: 'token');
    print("token: " + token);
    print("trying comm get dishes");
    final http.Response response = await http.get(
      baseURL + '/cook/api/cook-dish/get',
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
          allDishes = DishList.fromJson(decoded['cook_dishes']);
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

  Future<void> getAvaliableDishes() async {
    String token = await storage.read(key: 'token');
    print("token: " + token);
    print("trying comm available dishes");
    final http.Response response = await http.get(
      baseURL + '/cook/api/cook-dish/get?available=true',
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
          availableDishes = DishList.fromJson(decoded['cook_dishes']);
        });
        print("Successful!");
      } else {
        setState(() {
          if (availableDishes.dishList != null) {
            availableDishes.dishList.clear();
          }
        });
        print("Error: " + decoded['error']);
      }
    } else {
      print(response.statusCode);
      print("An unkown error occured");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (allDishes == null || availableDishes == null) {
      print("allDishes is null");
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (allDishes.dishList == null && availableDishes.dishList == null) {
      print("allDishes[i] is null");
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F8F8),
              Colors.white,
            ],
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            accentColor: const Color(0xFF35577D).withOpacity(0.2),
          ),
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              extendBodyBehindAppBar: true,
              body: Center(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Your Orders",
                            style: TextStyle(
                                fontSize: 23, fontWeight: FontWeight.bold)),
                        SizedBox(width: MediaQuery.of(context).size.width / 2),
                        IconButton(
                          color: Colors.black,
                          icon: Icon(Icons.refresh),
                          onPressed: () {
                            getDishes();
                            getAvaliableDishes();
                          },
                        ),
                      ],
                    ),
                    Expanded(
                      child: Text(
                        "It looks like you don't have any dishes yet!",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    print("allDishes:" + allDishes.toString());
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: Center(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Your Dishes",
                      style:
                          TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
                  SizedBox(width: MediaQuery.of(context).size.width / 2),
                  IconButton(
                    color: Colors.black,
                    icon: Icon(Icons.refresh),
                    onPressed: () {
                      getDishes();
                      getAvaliableDishes();
                    },
                  ),
                ],
              ),
              Expanded(
                child: sectionTimeline(allDishes, availableDishes),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showPicker(context) async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      title: new Text('Opening Time'),
                      trailing: new Text(openingTime != null
                          ? openingTime.hour.toString() +
                              ":" +
                              openingTime.minute.toString()
                          : ""),
                      onTap: () async {
                        await setOpeningTime();
                        if (openingTime != null && closingTime != null) {
                          await sendOperatingHours();
                        }
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    title: new Text('Closing Time'),
                    trailing: new Text(closingTime != null
                        ? closingTime.hour.toString() +
                            ":" +
                            closingTime.minute.toString()
                        : ""),
                    onTap: () async {
                      await setClosingTime();
                      if (openingTime != null && closingTime != null) {
                        await sendOperatingHours();
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> sendOperatingHours() async {
    print("sending hours");
    String token = await storage.read(key: 'token');
    final format = DateFormat('HH:mm:ss');
    String openingTimeParsed = format.format(openingTime);
    String closingTimeParsed = format.format(closingTime);
    print("opening time: " + openingTimeParsed);
    print("closing time: " + closingTimeParsed);
    final http.Response response = await http.post(
      baseURL + '/cook/api/profile/times/set',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token.toString(),
      },
      body: jsonEncode(<String, String>{
        'opening_time': openingTimeParsed,
        'closing_time': closingTimeParsed,
      }),
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON and send user to login screen
      dynamic decoded = jsonDecode(response.body);
      print("Received: " + decoded.toString());
      bool success = decoded['success'];
      if (success) {
        print("Successful! opening time setting");
      } else {
        //handle errors
        print("Error: opening time setting" + decoded['error']);
      }
    } else {
      print("unknown error: opening time setting");
    }
  }

  Future setOpeningTime() async {
    return DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      onChanged: (date) {
        print('change $date in time zone ' +
            date.timeZoneOffset.inHours.toString());
      },
      onConfirm: (date) {
        print('confirm $date');
        setState(() {
          openingTime = date;
        });
      },
    );
  }

  Future setClosingTime() async {
    return DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      onChanged: (date) {
        print('change $date in time zone ' +
            date.timeZoneOffset.inHours.toString());
      },
      onConfirm: (date) {
        print('confirm $date');
        setState(() {
          closingTime = date;
        });
      },
    );
  }

  Widget todayMenu(DishList availableDishes) {
    print("menu");
    if (availableDishes.dishList == null) {
      print("empty menu");
      return Card(
        elevation: 2,
        child: ExpansionTile(
          backgroundColor: Colors.white,
          title: Text(
            "Today's Menu",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
          ),
        ),
      );
    } else {
      return Card(
        elevation: 2,
        child: ExpansionTile(
          backgroundColor: Colors.white,
          title: Text(
            "Today's Menu",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
          ),
          trailing: numberOfDishes(availableDishes),
          children: [
            ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              children: availableDishes.dishList.map((p) {
                return availableDishesCards(p);
              }).toList(),
            ),
          ],
        ),
      );
    }
  }

  Widget sectionTimeline(DishList allDishes, DishList availableDishes) {
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: [
        Card(
          elevation: 2,
          child: InkWell(
            child: Text(
              "Select opening hours",
              style: TextStyle(
                  fontSize: 25, color: blue, fontWeight: FontWeight.w700),
            ),
            onTap: () {
              _showPicker(context);
            },
          ),
        ),
        todayMenu(availableDishes),
        Card(
          elevation: 2,
          child: ExpansionTile(
            backgroundColor: Colors.white,
            title: Text(
              "All dishes",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
            ),
            trailing: numberOfDishes(allDishes),
            children: [
              ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: allDishes.dishList.map((p) {
                  return allDishesCards(p);
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget numberOfDishes(DishList dishes) {
    int len = dishes.dishList != null ? dishes.dishList.length : 0;
    return Container(
      width: 30,
      height: 30,
      child: Center(
        child: Text(
          len.toString(),
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
        color: Colors.white,
      ),
    );
  }

  //List creation -- cooks cards
  Widget allDishesCards(CookDish dish) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Card(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(dish.dishPic),
                ),
                trailing: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    dish.avgRating != 0.0
                        ? Icon(Icons.star, color: Colors.yellow)
                        : Text(""),
                    dish.avgRating != 0.0
                        ? Text(dish.avgRating.toStringAsFixed(1))
                        : Text(""),
                    SizedBox(width: 10),
                    InkWell(
                      child: Icon(
                        Icons.add_circle_outline,
                        color: doneButton,
                      ),
                      onTap: () async {
                        await makeDishesAvailable(dish);
                      },
                    ),
                  ],
                ),
                title: Text(dish.name +
                    " | " +
                    dish.category +
                    "\n" +
                    dish.price.toString() +
                    "LBP"),
                subtitle: Text(dish.description),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //List creation -- cooks cards
  Widget availableDishesCards(CookDish dish) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Card(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(dish.dishPic),
                ),
                trailing: InkWell(
                  child: Icon(
                    Icons.remove_circle,
                    color: removeButton,
                  ),
                  onTap: () async {
                    await makeDishesUnavailable(dish);
                  },
                ),
                title: Text(dish.name +
                    " | " +
                    dish.category +
                    "\n" +
                    dish.price.toString() +
                    "LBP"),
                subtitle: Text(dish.description),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> makeDishesAvailable(CookDish dish) async {
    String token = await storage.read(key: 'token');
    print("token: " + token);
    print("trying comm makeDishesAvailable");
    final http.Response response = await http.get(
      baseURL +
          '/cook/api/cook-dish/available?dish_id=' +
          dish.dishID.toString(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token.toString(),
        //"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6OSwiaWF0IjoxNjEzMDQwOTgyfQ.5Pp6xPvfmqAeL09oWqX0sJugy3ryxsXdVfNSrHdv2TY",
      },
    );

    if (response.statusCode == 200) {
      dynamic decoded = jsonDecode(response.body);
      print("Received: " + decoded.toString());
      bool success = decoded['success'];
      if (success) {
        getDishes();
        getAvaliableDishes();
        setState(() {
          doneButton = Colors.green;
        });
        print("Successful!");
        return true;
      } else {
        print("Error: " + decoded['error']);
        return false;
      }
    } else {
      print(response.statusCode);
      print("An unkown error occured");
      return false;
    }
  }

  Future<bool> makeDishesUnavailable(CookDish dish) async {
    String token = await storage.read(key: 'token');
    print("token: " + token);
    print("trying comm makeDishesUnavailable");
    final http.Response response = await http.get(
      baseURL +
          '/cook/api/cook-dish/unavailable?dish_id=' +
          dish.dishID.toString(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token.toString(),
        //"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6OSwiaWF0IjoxNjEzMDQwOTgyfQ.5Pp6xPvfmqAeL09oWqX0sJugy3ryxsXdVfNSrHdv2TY",
      },
    );

    if (response.statusCode == 200) {
      dynamic decoded = jsonDecode(response.body);
      print("Received: " + decoded.toString());
      bool success = decoded['success'];
      if (success) {
        getDishes();
        getAvaliableDishes();
        setState(() {
          doneButton = Colors.green;
        });
        print("Successful!");
        return true;
      } else {
        print("Error: " + decoded['error']);
        return false;
      }
    } else {
      print(response.statusCode);
      print("An unkown error occured");
      return false;
    }
  }
}
