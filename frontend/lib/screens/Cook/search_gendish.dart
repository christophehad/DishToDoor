import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dishtodoor/screens/auth/globals.dart' as globals;
import 'package:dishtodoor/config/config.dart';
import 'package:dishtodoor/screens/Cook/dishClass.dart';
import 'package:dishtodoor/screens/Cook/add_generic_dish.dart';
import 'dart:async';

class GenDishSearchBar extends StatefulWidget {
  @override
  _GenDishSearchBar createState() => _GenDishSearchBar();
}

class _GenDishSearchBar extends State<GenDishSearchBar> {
  String query;
  GenDishList genDishes;

  @override
  void initState() {
    print('LaunchState initState start');
    displayGenDish();
    super.initState();
  }

  Future getGenDish() async {
    print("Trying comm");
    final http.Response response = await http.get(
      baseURL + '/cook/api/gen-dish/search?query=' + query,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + globals.token
      },
    );
    String error = "";
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON
      dynamic decoded = jsonDecode(response.body);
      print("Received: " + decoded.toString());
      bool success = decoded['success'];
      print("success: " + success.toString());
      print(decoded['gen_dishes']);
      if (success) {
        setState(() {
          genDishes = GenDishList.fromJson(decoded['gen_dishes']);
          error = "";
        });
        print(genDishes.genDishList);
        print("Successful!");
      } else {
        //handle errors
        print("Error: " + decoded['error']);
        if (decoded['error'] == "missing_query") {
          displayGenDish();
        }
      }
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      print("An unkown error occured");
    }
  }

  Future displayGenDish() async {
    print("Trying comm");
    final http.Response response = await http.get(
      baseURL + '/cook/api/gen-dish/get',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + globals.token
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON
      dynamic decoded = jsonDecode(response.body);
      print("Received: " + decoded.toString());
      bool success = decoded['success'];
      print("success: " + success.toString());
      print(decoded['gen_dishes']);
      if (success) {
        setState(() {
          genDishes = GenDishList.fromJson(decoded['gen_dishes']);
        });
        print(genDishes.genDishList);
        print("Successful!");
      } else {
        //handle errors
        print("Error: " + decoded['error']);
      }
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      print("An unkown error occured");
    }
  }

  Widget searchField() {
    return Container(
        child: TextField(
      autofocus: true,
      style: TextStyle(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Colors.white, fontSize: 18),
        hintText: "Search Dishes",
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
      ),
      onChanged: (value) {
        query = value;
        getGenDish();
      },
    ));
  }

  //List creation
  Widget genDishCards(GenDish genDish) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        InkWell(
          child: Card(
            child: ListTile(
              title: Text(genDish.name),
            ),
          ),
          onTap: () {
            Navigator.pop(context, genDish.name + "." + genDish.id.toString());
          },
        ),
      ],
    );
  }

  Widget addButton() {
    return Positioned(
      left: 0,
      bottom: 0,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AddGenDish() //cookList: cooks,
                  ));
        },
        child: Container(
          width: 230,
          height: 50,
          child: Center(
              child: new Text("Add Generic dish",
                  style: const TextStyle(color: Colors.white, fontSize: 20.0))),
          decoration: BoxDecoration(
              color: Colors.blue,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue[100],
        body: Stack(children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 90),
                  searchField(),
                  ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: [
                        Column(
                            children: genDishes.genDishList.map((p) {
                          return genDishCards(p);
                        }).toList()),
                      ]),
                  addButton()
                ],
              )),
          Positioned(
              top: 35,
              left: 5,
              child: IconButton(
                color: Colors.white,
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ))
        ]));
  }
}
