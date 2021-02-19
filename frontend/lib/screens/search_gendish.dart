import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dishtodoor/screens/auth/globals.dart' as globals;
import 'package:dishtodoor/config/config.dart';
import 'package:dishtodoor/screens/dishClass.dart';

class GenDishSearchBar extends StatefulWidget {
  @override
  _GenDishSearchBar createState() => _GenDishSearchBar();
}

class _GenDishSearchBar extends State<GenDishSearchBar> {
  String query;
  GenDishList genDishes;

  Future getGenDish() async {
    print("Trying comm");
    final http.Response response = await http.get(
      baseURL + '/cook/api/gen-dish/search?query=' + query,
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
        //_registerSuccessfulAlert();
        print("Successful!");
        //showList2();
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

  Widget searchField() {
    //search input field
    return Container(
        child: TextField(
      autofocus: true,
      style: TextStyle(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Colors.white, fontSize: 18),
        hintText: "Search Dishes",
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ), //under line border, set OutlineInputBorder() for all side border
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ), // focused border color
      ), //decoration for search input field
      onChanged: (value) {
        query = value; //update the value of query
        getGenDish();
        //start to get suggestion
      },
    ));
  }

  //List creation -- cooks cards
  Widget genDishCards(GenDish genDish) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Card(
          child: Column(
            children: [
              ListTile(
                //trailing: Text(dish.price.toString() + "LBP"),
                title: Text(genDish.name),
                //subtitle: Text(dish.description),
              ),
            ],
          ),
        ),
      ],
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
                      ])
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
