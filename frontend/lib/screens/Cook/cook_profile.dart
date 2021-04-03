import 'cook_profile_information.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dishtodoor/config/config.dart';
import 'package:dishtodoor/screens/auth/login.dart';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:geocoding/geocoding.dart';

class ProfileCook2 extends StatefulWidget {
  final String defaultLogo =
      "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500";
  ProfileCook2({Key key}) : super(key: key);
  @override
  _ProfileCookState2 createState() => _ProfileCookState2();
}

class _ProfileCookState2 extends State<ProfileCook2> {
  DateTime pickupDate;
  bool datePicked = false;
  CookProfileInformation cookProfileInformation;
  bool isCookEmpty = false;
  String locationName = "";
  TextEditingController fname = TextEditingController(text: "");
  TextEditingController lname = TextEditingController(text: "");

  @override
  void initState() {
    cookProfileInformationFetching();
    super.initState();
  }

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

  //delete notification token from backend
  Future<void> logoutNotif() async {
    String token = await storage.read(key: 'token');
    final http.Response response = await http.get(
      baseURL + '/cook/api/device/delete',
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
        print("Successfuly deleted notification token - cook!");
      } else {
        print("Error deleting notif token - cook: ");
      }
    } else {
      print(response.statusCode);
      print("An unkown error occured while deleting token - cook");
    }
  }

  Future<void> _changeLocationAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to change your location?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This action is permanent and irreversible.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                await _setLocation();
                return Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _setLocation() async {
    storage.delete(key: 'location');
    cookLocation.sendLoc().then((value) async {
      await storage.write(
          key: 'location',
          value: (cookLocation.cookLocation.latitude.toString() +
              ',' +
              cookLocation.cookLocation.longitude.toString()));
    });
    await cookProfileInformationFetching();
  }

//for cook name modification
  Future<void> cookNameMod() async {
    String token = await storage.read(key: 'token');
    final requestBody = jsonEncode({
      'first_name': fname.text,
      'last_name': lname.text,
    });
    print(requestBody);
    final http.Response response = await http.post(
      baseURL + '/cook/api/profile/name/set',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token.toString(),
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      dynamic decoded = jsonDecode(response.body);
      print("Received: " + decoded.toString());
      bool success = decoded['success'];
      if (success) {
        await cookProfileInformationFetching();
        print("Successful! cook Name mod");
      } else {
        print("Error cook Name mod: " + decoded['error']);
      }
    } else {
      print(response.statusCode);
      print("An unkown error occured cook Name mod");
    }
  }

  //for cook profile fetching
  Future<void> cookProfileInformationFetching() async {
    print("trying comm order");
    String token = await storage.read(key: 'token');
    final http.Response response = await http.get(
      baseURL + '/cook/api/profile/get',
      headers: <String, String>{
        'Authorization': "Bearer " + token.toString(),
      },
    );

    if (response.statusCode == 200) {
      dynamic decoded = jsonDecode(response.body);
      print("Received: " + decoded.toString());
      bool success = decoded['success'];
      if (success) {
        setState(() {
          cookProfileInformation =
              CookProfileInformation.fromJson(decoded['cook']);
          isCookEmpty = true;
          fname = TextEditingController(
              text: cookProfileInformation.cookProfile.firstName);
          lname = TextEditingController(
              text: cookProfileInformation.cookProfile.lastName);
        });
        List<Placemark> addresses = await placemarkFromCoordinates(
            cookProfileInformation.cookProfile.lat,
            cookProfileInformation.cookProfile.lon);
        Placemark first = addresses.first;
        print("${first.locality} : ${first.name}");
        setState(() {
          locationName = first.subAdministrativeArea + ", " + first.name;
        });
        print("Successful!");
      } else {
        print("Error: " + decoded['error']);
        isCookEmpty = false;
      }
    } else {
      print(response.statusCode);
      isCookEmpty = false;
      print("An unkown error occured");
    }
  }

  //for cook profile pic modification
  Future<void> cookProfilePictureMod() async {
    print("sending call to backend");
    String token = await storage.read(key: 'token');
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(baseURL + '/cook/api/profile/pic/set'),
    );
    Map<String, String> headers = {
      "Authorization": "Bearer " + token.toString(),
      "Content-type": "multipart/form-data"
    };
    request.files.add(http.MultipartFile(
        'profile_pic', _image.readAsBytes().asStream(), _image.lengthSync(),
        filename: _image.path, contentType: MediaType('image', 'jpeg')));
    request.headers.addAll(headers);
    print("request: " + request.toString());
    var response = await request.send();

    if (response.statusCode == 200) {
      dynamic responseString = await response.stream.bytesToString();
      print("Received: " + responseString);
      print(_image.path);
      String jsonsDataString = responseString.toString();
      final jsonData = jsonDecode(jsonsDataString);
      bool success = jsonData['success'];
      if (success) {
        print("Successful cookProfile modification!");
        await cookProfileInformationFetching();
      } else {
        print("Error cook profile mode: " + jsonData['error']);
      }
    } else {
      print("An unkown error occured cook profile mod");
      print(_image.path);
    }
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
                        getImageGallery().then((value) async {
                          await cookProfilePictureMod();
                        });
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      getImageCamera().then((value) async {
                        await cookProfilePictureMod();
                      });
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
    if (cookProfileInformation.cookProfile.logo != widget.defaultLogo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.network(
          cookProfileInformation.cookProfile.logo,
          width: 100,
          height: 100,
          fit: BoxFit.fill,
        ),
      );
    } else if (_image != null) {
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

//Alert Dialaog
  Future<void> _changeNameAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change your name'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(hintText: 'First name'),
                  controller: fname,
                  style: TextStyle(fontSize: 14.0),
                ),
                TextField(
                  decoration: InputDecoration(hintText: 'Last name'),
                  controller: lname,
                  style: TextStyle(fontSize: 14.0),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Change'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cookProfileInformation == null && isCookEmpty == false) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Colors.teal[200],
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          InkWell(
            child: Text(
              cookProfileInformation.cookProfile.firstName +
                  " " +
                  cookProfileInformation.cookProfile.lastName,
              style: TextStyle(
                  fontSize: 40.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              await _changeNameAlert().then((value) async {
                await cookNameMod();
              });
            },
          ),
          SizedBox(
            height: 20,
            width: 200,
            child: Divider(
              color: Colors.teal.shade700,
            ),
          ),
          Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
              child: ListTile(
                  leading: Icon(
                    Icons.phone,
                    color: Colors.teal,
                  ),
                  title: Text(cookProfileInformation.phone,
                      //add phone number
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.teal,
                      )))),
          Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
              child: ListTile(
                  leading: Icon(
                    Icons.email,
                    color: Colors.teal,
                  ),
                  title: Text(cookProfileInformation.email,
                      //add email
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.teal,
                      )))),
          Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
              child: ListTile(
                  leading: Icon(
                    Icons.location_city,
                    color: Colors.teal,
                  ),
                  onTap: () {
                    _changeLocationAlert();
                  },
                  title: Text(locationName,
                      //add location
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.teal,
                      )))),
          Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
            child: ListTile(
              leading: Icon(
                Icons.check,
                color: Colors.teal,
              ),
              title: Text(
                "Cook since " +
                    cookProfileInformation.dateAdded.year.toString() +
                    "-" +
                    cookProfileInformation.dateAdded.month.toString() +
                    "-" +
                    cookProfileInformation.dateAdded.day.toString(),
                //add verified since
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.teal,
                ),
              ),
            ),
          ),
          Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
            child: ListTile(
              leading: Icon(
                Icons.timer,
                color: Colors.teal,
              ),
              title: Text(
                "Open: " +
                    cookProfileInformation.cookProfile.opening.hour.toString() +
                    ":" +
                    cookProfileInformation.cookProfile.opening.minute
                        .toString() +
                    ' - ' +
                    cookProfileInformation.cookProfile.closing.hour.toString() +
                    ":" +
                    cookProfileInformation.cookProfile.closing.minute
                        .toString(),
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.teal,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.teal,
              ),
              onTap: () async {
                await logoutNotif();
                await storage.deleteAll().then((value) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => Login(),
                    ),
                    (route) => false,
                  );
                });
              },
              title: Text(
                "Logout",
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.teal,
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
