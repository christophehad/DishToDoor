import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddGenericDish extends StatefulWidget {
  @override
  _AddGenericDish createState() => _AddGenericDish();
}

class _AddGenericDish extends State<AddGenericDish> {
  TextEditingController email = TextEditingController(text: "");
  TextEditingController password = TextEditingController(text: "");

  String dropdownvalue_cat = 'Platter';
  String dropdownvalue_servings = '1-2 persons';

  File _image;
  final picker = ImagePicker();

  Future getImageCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //search input field
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
        //SizedBox(height: 90),
        // Padding(
        //     padding: const EdgeInsets.all(5),
        //     child: Container(child: showImage(), height: 150, width: 150)),
        Center(
          child: _image == null
              ? Text('No image selected.')
              : Image.file(_image, height: 150, width: 150),
        ),
        RaisedButton(
          color: Colors.blueAccent,
          onPressed: getImageGallery,
          child: Text("Pick from gallery"),
        ),
        RaisedButton(
          color: Colors.blue,
          onPressed: getImageCamera,
          child: Text("Pick from camera"),
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
                  //textAlign: TextAlign.center,
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
                  //hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                  hintText: "Search",
                  suffixIcon: Icon(Icons.search),
                  // enabledBorder: UnderlineInputBorder(
                  //   borderSide: BorderSide(color: Colors.grey, width: 2),
                  // ), //under line border, set OutlineInputBorder() for all side border
                  // focusedBorder: UnderlineInputBorder(
                  //   borderSide: BorderSide(color: Colors.grey, width: 2),
                  // ), // focused border color
                ), //decoration for search input field
                onChanged: (value) {
                  //query = value; //update the value of query
                  //getSuggestion(); //start to get suggestion
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
              //controller: email,
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
                value: dropdownvalue_cat,
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
                    dropdownvalue_cat = newValue;
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
                value: dropdownvalue_servings,
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
                    dropdownvalue_servings = newValue;
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
                    //controller: email,
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
            //controller: email,
            style: TextStyle(fontSize: 16.0),
          ),
        ]));

    Widget addButton = Positioned(
      left: MediaQuery.of(context).size.width / 4,
      bottom: 0,
      child: InkWell(
        onTap: () {
          //Add OTP page navigation
          // Navigator.of(context)
          //     .push(MaterialPageRoute(builder: (_) => PageNavigator()));
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
