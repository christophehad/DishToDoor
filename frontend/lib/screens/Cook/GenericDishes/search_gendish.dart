import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dishtodoor/config/config.dart';
import 'package:dishtodoor/screens/Cook/GenericDishes/dishClass.dart';
import 'package:dishtodoor/screens/Cook/GenericDishes/add_generic_dish.dart';
import 'dart:async';
import 'package:dishtodoor/config/appProperties.dart';

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
    String token = await storage.read(key: "token");
    final http.Response response = await http.get(
      baseURL + '/cook/api/gen-dish/search?query=' + query,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token.toString()
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
        if (decoded['error'] == "missing_query") {
          displayGenDish();
        }
      }
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      print("An unkown error occured getgenDish");
    }
  }

  Future displayGenDish() async {
    print("Trying comm");
    String token = await storage.read(key: "token");
    final http.Response response = await http.get(
      baseURL + '/cook/api/gen-dish/get',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token.toString()
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
      print("An unkown error occured displaygenDish");
    }
  }

  Widget searchField() {
    return Container(
        padding: EdgeInsets.only(left: 5),
        child: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.black, fontSize: 18),
          decoration: InputDecoration(
            hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 18),
            hintText: "Search Dishes",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade500, width: 2),
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
            color: Colors.grey.shade200,
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
    return Center(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AddGenDish() //cookList: cooks,
                  ));
        },
        child: Container(
          width: 100,
          height: 35,
          child: Center(
              child: new Text("Create Dish",
                  style: const TextStyle(color: Colors.white, fontSize: 17.0))),
          decoration: BoxDecoration(
              color: mediumBlue,
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
    if (genDishes == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            IconButton(
              color: Colors.black,
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            searchField(),
            ConstrainedBox(
              constraints: new BoxConstraints(
                minHeight: 100.0,
                maxHeight: 300.0,
              ),
              child: ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: [
                    Column(
                        children: genDishes.genDishList.map((p) {
                      return genDishCards(p);
                    }).toList()),
                  ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Can't find what you're looking for?",
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                addButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
