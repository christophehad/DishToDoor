import 'package:dishtodoor/screens/Cook/search_gendish.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dishtodoor/screens/auth/globals.dart' as globals;
import 'package:dishtodoor/config/config.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

class AddCookDish extends StatefulWidget {
  @override
  _AddCookDish createState() => _AddCookDish();
}

class _AddCookDish extends State<AddCookDish> {
  String genDishName = "Search";
  String genDishId;
  TextEditingController customName = TextEditingController(text: "");
  TextEditingController price = TextEditingController(text: "");
  TextEditingController descriptionText = TextEditingController(text: "");

  String dropDownValueCat = 'Platter';
  String dropDownValueServings = '1-2 persons';

  File _image;
  String _imageString;
  final picker = ImagePicker();

  Future getImageCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        //_imageString = base64Encode(_image.readAsBytesSync());
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });

        //_imageString = base64Encode(_image.readAsBytesSync());
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget addMealText = Column(children: <Widget>[
      SizedBox(height: 60),
      Padding(
          padding: EdgeInsets.only(left: 10),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add Meal',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              )))
    ]);

    Widget mealName =
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Column(children: <Widget>[
        Center(
          //if no image, display 'No image selected'
          child: _image == null
              ? Text('No image selected')
              : Image.file(_image, height: 150, width: 150),
        ),
        RaisedButton(
          color: Colors.blueAccent,
          onPressed: getImageGallery,
          child: Text("Pick from Gallery"),
        ),
        RaisedButton(
          color: Colors.blue,
          onPressed: getImageCamera,
          child: Text("Pick from Camera"),
        ),
      ]),
      Column(children: <Widget>[
        Column(children: <Widget>[
          SizedBox(height: 30),
          Container(
            width: 200,
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Base dish',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ),
          Container(
              width: 200,
              child: TextField(
                style: TextStyle(color: Colors.grey, fontSize: 18),
                decoration: InputDecoration(
                  hintText: genDishName,
                  suffixIcon: Icon(Icons.search),
                ),
                onTap: () async {
                  final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GenDishSearchBar()));
                  setState(() {
                    genDishName = result.substring(0, result.indexOf('.'));
                    genDishId = result.substring(result.indexOf('.') + 1);
                  });
                },
              ))
        ]),
        Column(children: <Widget>[
          SizedBox(height: 10),
          Container(
              width: 200,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Custom name',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ))),
          Container(
            width: 200,
            child: TextField(
              decoration: InputDecoration(hintText: '(Optional)'),
              controller: customName,
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          )
        ]),
      ])
    ]);

    Widget dropDownMenu_Cat = Padding(
        padding: EdgeInsets.only(left: 10),
        child: Column(children: <Widget>[
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Category',
                //textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              )),
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
                items: <String>['Platter', 'Salad', 'Sandwich', 'Dessert']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ))
        ]));

    Widget dropDownMenu_Servings = Padding(
        padding: EdgeInsets.only(left: 10),
        child: Column(children: <Widget>[
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Servings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              )),
          Container(
              alignment: Alignment.centerLeft,
              child: DropdownButton<String>(
                value: dropDownValueServings,
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
                    dropDownValueServings = newValue;
                  });
                },
                items: <String>[
                  '1-2 persons',
                  '4 persons',
                  '8 persons',
                  '10 persons'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ))
        ]));

    Widget enterPrice = Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(children: <Widget>[
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Price',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              )),
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                  width: 150,
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Enter your price'),
                    controller: price,
                    style: TextStyle(fontSize: 16.0),
                  ))),
        ]));

    Widget description = Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Column(children: <Widget>[
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Description',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              )),
          TextField(
            keyboardType: TextInputType.multiline,
            //minLines: 4,
            maxLines: null,
            decoration:
                InputDecoration(hintText: 'What is special about your dish?'),
            controller: descriptionText,
            style: TextStyle(fontSize: 16.0),
          ),
        ]));

    Widget addButton = Positioned(
      left: MediaQuery.of(context).size.width / 4,
      bottom: 0,
      child: InkWell(
        onTap: () async {
          // final http.Response response = await http.post(
          //   baseURL + '/cook/api/cook-dish/add',
          //   headers: <String, String>{
          //     'Content-Type': 'multipart/form-data',
          //     'Authorization': "Bearer " + globals.token
          //   },
          //   body: jsonEncode(<String, String>{
          //     'custom_name': customName.text,
          //     'gendish_id': genDishId,
          //     'price': price.text,
          //     'category': dropDownValueCat,
          //     'description': descriptionText.text,
          //     'dish_pic': _imageString,
          //     //MODIFY by adding relevant COOK parts
          //   }),
          // );
          var request = http.MultipartRequest(
            'POST',
            Uri.parse(baseURL + '/cook/api/cook-dish/add'),
          );
          Map<String, String> headers = {
            "Authorization": "Bearer " + globals.token,
            "Content-type": "multipart/form-data"
          };
          request.files.add(http.MultipartFile(
              'dish_pic', _image.readAsBytes().asStream(), _image.lengthSync(),
              filename: _image.path, contentType: MediaType('image', 'jpeg')));
          request.headers.addAll(headers);
          request.fields.addAll({
            'custom_name': customName.text,
            'gendish_id': genDishId,
            'price': price.text,
            'category': dropDownValueCat,
            'description': descriptionText.text
          });
          print("request: " + request.toString());
          var response = await request.send();
          if (response.statusCode == 200) {
            // If the server did return a 200 CREATED response,
            // then parse the JSON and send user to login screen
            dynamic responseString = await response.stream.bytesToString();
            //dynamic decoded = jsonDecode(response.body);
            print("Received: " + responseString);
            print(_image.path);
            bool success = responseString['success'];
            if (success) {
              //_registerSuccessfulAlert();
              print("Successful!");
            } else {
              //handle errors
              print("Error: " + responseString['error']);
              //_registerErrorAlert(decoded['error']);
            }
          } else {
            // If the server did not return a 201 CREATED response,
            // then throw an exception.
            print("An unkown error occured");
            // print(customName.text +
            //     " " +
            //     genDishId +
            //     " " +
            //     price.text +
            //     " " +
            //     dropDownValueCat +
            //     " " +
            //     descriptionText.text +
            //     " " +
            //     _imageString);
            print(_image.path);
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          height: 50,
          child: Center(
              child: new Text("Add",
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

    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Stack(children: <Widget>[
        Column(children: <Widget>[
          Spacer(flex: 1),
          addMealText,
          mealName,
          Spacer(),
          dropDownMenu_Cat,
          Spacer(),
          dropDownMenu_Servings,
          Spacer(),
          enterPrice,
          Spacer(),
          description,
          Spacer(),
          addButton,
          Spacer(),
          // RaisedButton(
          //     color: Colors.lightGreenAccent,
          //     onPressed: getImage,
          //     child: Text("PICK FROM CAMERA")),
        ]),
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
      ]),
      // floatingActionButton: FloatingActionButton(
      //     onPressed: getImage,
      //     tooltip: 'Pick Image',
      //     child: Icon(Icons.add_a_photo)),
    );
  }
}
