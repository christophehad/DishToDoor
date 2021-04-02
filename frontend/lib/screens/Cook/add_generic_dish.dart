import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dishtodoor/config/config.dart';
import 'package:dishtodoor/screens/Cook/add_cook_dish.dart';

class AddGenDish extends StatefulWidget {
  @override
  _AddGenDish createState() => _AddGenDish();
}

class _AddGenDish extends State<AddGenDish> {
  TextEditingController genDishName = TextEditingController(text: "");

  //TextEditingController dropDownValueCat = TextEditingController(text: "");
  String dropDownValueCat = 'Platter';

  @override
  Widget build(BuildContext context) {
    Widget addButton = Center(
      child: InkWell(
        onTap: () async {
          String token = await storage.read(key: "token");
          final http.Response response =
              await http.post(baseURL + '/cook/api/gen-dish/add',
                  headers: <String, String>{
                    "Authorization": "Bearer " + token.toString(),
                    'Content-Type': 'application/json; charset=UTF-8'
                  },
                  body: jsonEncode(<String, String>{
                    "name": genDishName.text,
                    "category": dropDownValueCat,
                  }));

          if (response.statusCode == 200) {
            dynamic decoded = jsonDecode(response.body);
            print("Received: " + decoded.toString());
            bool success = decoded['success'];
            if (success) {
              //_registerSuccessfulAlert();
              //secure storage of token

              print("Successful!");

              //locsharing().then((value) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AddCookDish() //cookList: cooks,
                  ));
              //});
            } else {
              print("Error: " + decoded['error']);
              print("Error: " + genDishName.text);
              print("Error: " + dropDownValueCat);
            }
          } else {
            print("An unkown error occured adding dish");
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          height: 52,
          child: Center(
              child: new Text("Add Dish",
                  style: const TextStyle(
                      color: const Color(0xfffefefe),
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      fontSize: 20.0))),
          decoration: BoxDecoration(
              color: Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.16),
                  offset: Offset(0, 5),
                  blurRadius: 10.0,
                )
              ],
              borderRadius: BorderRadius.circular(9.0)),
        ),
      ),
    );

    Widget loginForm = Column(children: <Widget>[
      SizedBox(height: 90),
      Container(
        height: 180,
        child: Stack(
          children: <Widget>[
            Container(
              height: 150,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(left: 32.0, right: 12.0),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.8),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Dish name',
                        //suffixIcon: Icon(Icons.email)
                      ),
                      controller: genDishName,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  Container(
                      alignment: Alignment.centerLeft,
                      child: DropdownButton<String>(
                        value: dropDownValueCat,
                        dropdownColor: Colors.grey[200],
                        isDense: true,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String newValue) {
                          setState(() {
                            dropDownValueCat = newValue;
                          });
                        },
                        items: <String>[
                          'Platter',
                          'Salad',
                          'Sandwich',
                          'Dessert'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )),
                ],
              ),
            ),
            addButton,
          ],
        ),
      )
    ]);

    return Scaffold(
        backgroundColor: Colors.blue[100],
        body: Stack(children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[loginForm],
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
