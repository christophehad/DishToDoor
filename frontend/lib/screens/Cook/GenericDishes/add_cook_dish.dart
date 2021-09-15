import 'package:dishtodoor/screens/Cook/GenericDishes/search_gendish.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dishtodoor/config/config.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:dishtodoor/screens/PageNavigation/page_navigator_cook.dart';
import 'package:dishtodoor/config/appProperties.dart';

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

  void _showPicker(context) async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        getImageGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      getImageCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget profilePic() {
    if (_image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.file(_image, width: 100, height: 100, fit: BoxFit.fill),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(50)),
        width: 100,
        height: 100,
        child: Icon(
          Icons.camera_alt,
          color: Colors.grey[800],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget addMealText() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Add Meal',
            style: TextStyle(
              color: Colors.black,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    Widget mealName() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: GestureDetector(
              onTap: () {
                _showPicker(context);
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xffFDCF09),
                child: profilePic(),
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 6,
          ),
          Column(
            children: <Widget>[
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
                        if (result != null) {
                          setState(() {
                            genDishName =
                                result.substring(0, result.indexOf('.'));
                            genDishId =
                                result.substring(result.indexOf('.') + 1);
                          });
                        }
                      },
                    ))
              ]),
              Column(
                children: <Widget>[
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
                  ),
                ],
              ),
            ],
          )
        ],
      );
    }

    Widget dropDownMenuCat() {
      return Column(
        children: <Widget>[
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
              style: TextStyle(color: darkBlue),
              underline: Container(
                height: 2,
                color: darkBlue,
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
            ),
          )
        ],
      );
    }

    Widget dropDownMenuServings() {
      return Column(
        children: <Widget>[
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
              style: TextStyle(color: darkBlue),
              underline: Container(
                height: 2,
                color: darkBlue,
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
            ),
          ),
        ],
      );
    }

    Widget enterPrice() {
      return Column(
        children: <Widget>[
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
              ),
            ),
          ),
        ],
      );
    }

    Widget description() {
      return Column(
        children: <Widget>[
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
        ],
      );
    }

    Widget addButton = Center(
      child: InkWell(
        onTap: () async {
          String token = await storage.read(key: 'token');
          var request = http.MultipartRequest(
            'POST',
            Uri.parse(baseURL + '/cook/api/cook-dish/add'),
          );
          Map<String, String> headers = {
            "Authorization": "Bearer " + token.toString(),
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
            String jsonsDataString = responseString.toString();
            final jsonData = jsonDecode(jsonsDataString);
            bool success = jsonData['success'];
            if (success) {
              print("Successful!");
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => PageNavigatorCook(
                            indexInput: 0,
                          )));
            } else {
              print("Error: ");
            }
          } else {
            print("An unkown error occured");
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

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(children: <Widget>[
            Spacer(flex: 2),
            addMealText(),
            Spacer(flex: 1),
            mealName(),
            Spacer(),
            dropDownMenuCat(),
            Spacer(),
            dropDownMenuServings(),
            Spacer(),
            enterPrice(),
            Spacer(),
            description(),
            Spacer(),
            addButton,
            Spacer(),
          ]),
        ),
      ),
    );
  }
}
