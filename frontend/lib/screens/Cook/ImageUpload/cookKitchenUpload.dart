import 'package:dishtodoor/screens/Cook/ImageUpload/imageUploadClass.dart';
import 'package:dishtodoor/screens/Cook/ImageUpload/waitingPage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dishtodoor/config/config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SingleImageUpload extends StatefulWidget {
  @override
  _SingleImageUploadState createState() {
    return _SingleImageUploadState();
  }
}

class _SingleImageUploadState extends State<SingleImageUpload> {
  List<Object> images = List<Object>();
  File _imageFile;
  final picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    setState(() {
      images.add("Add Image");
      images.add("Add Image");
      images.add("Add Image");
      images.add("Add Image");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            introduction(),
            SizedBox(height: 50),
            Expanded(
              child: buildGridView(),
            ),
            uploadButton(),
          ],
        ),
      ),
    );
  }

  Widget introduction() {
    return Column(
      children: [
        Text(
          "Hi! You aren't verified yet, please upload pictures of your kitchen to start the verification process. \n",
          style: TextStyle(fontSize: 18),
        ),
        Text(
          "Ideally, upload a picture of your fridge, your stove, your oven and a global view of your work area.",
          style: TextStyle(fontSize: 18),
        )
      ],
    );
  }

  Widget uploadButton() {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
      child: ListTile(
        onTap: () async {
          await uploadPictures();
        },
        title: Center(
          child: Text(
            "Upload",
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGridView() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1,
      children: List.generate(images.length, (index) {
        if (images[index] is ImageUploadModel) {
          ImageUploadModel uploadModel = images[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: <Widget>[
                Image.file(
                  uploadModel.imageFile,
                  width: 300,
                  height: 300,
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: InkWell(
                    child: Icon(
                      Icons.remove_circle,
                      size: 20,
                      color: Colors.red,
                    ),
                    onTap: () {
                      setState(() {
                        images.replaceRange(index, index + 1, ['Add Image']);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Card(
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                _showPicker(context, index);
              },
            ),
          );
        }
      }),
    );
  }

  void _showPicker(context, int index) async {
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
                        _onAddImageClick(index);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      getImageCamera(index);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future _onAddImageClick(int index) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          getFileImage(index);
        });
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadPictures() async {
    print("sending call to backend");
    String token = await storage.read(key: 'token');
    print(token);
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(baseURL + '/cook/api/kitchen/pic/upload'),
    );
    Map<String, String> headers = {
      "Authorization": "Bearer " + token.toString(),
      "Content-type": "multipart/form-data"
    };
    if (images[0] != "Add Image") {
      print("in images[0]");
      ImageUploadModel uploadModel = images[0];
      if (uploadModel.imageFile != null) {
        print(uploadModel.imageFile.path);
        request.files.add(
          http.MultipartFile(
            'kitchen_pic',
            uploadModel.imageFile.readAsBytes().asStream(),
            uploadModel.imageFile.lengthSync(),
            filename: uploadModel.imageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }
    }
    if (images[1] != "Add Image") {
      print("in images[1]");
      ImageUploadModel uploadModel1 = images[1];
      if (uploadModel1.imageFile != null) {
        request.files.add(
          http.MultipartFile(
            'kitchen_pic1',
            uploadModel1.imageFile.readAsBytes().asStream(),
            uploadModel1.imageFile.lengthSync(),
            filename: uploadModel1.imageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }
    }
    if (images[2] != "Add Image") {
      ImageUploadModel uploadModel2 = images[1];
      if (uploadModel2.imageFile != null) {
        request.files.add(
          http.MultipartFile(
            'kitchen_pic2',
            uploadModel2.imageFile.readAsBytes().asStream(),
            uploadModel2.imageFile.lengthSync(),
            filename: uploadModel2.imageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }
    }
    if (images[3] != "Add Image") {
      ImageUploadModel uploadModel3 = images[1];
      if (uploadModel3.imageFile != null) {
        request.files.add(
          http.MultipartFile(
            'kitchen_pic3',
            uploadModel3.imageFile.readAsBytes().asStream(),
            uploadModel3.imageFile.lengthSync(),
            filename: uploadModel3.imageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }
    }
    request.headers.addAll(headers);

    print("request: " + request.toString());
    var response = await request.send();

    if (response.statusCode == 200) {
      dynamic responseString = await response.stream.bytesToString();
      print("Received: " + responseString);
      String jsonsDataString = responseString.toString();
      final jsonData = jsonDecode(jsonsDataString);
      bool success = jsonData['success'];
      if (success) {
        print("Successful cookProfile modification!");
        await storage.write(key: 'kitchenPics', value: 'true');
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => WaitingPage()));
      } else {
        await storage.write(key: 'kitchenPics', value: 'false');
        print("Error cook profile mode: " + jsonData['error']);
      }
    } else {
      print(response.statusCode);
      print("An unkown error occured cook profile mod");
      print(_imageFile.path);
    }
  }

  Future getImageCamera(int index) async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          getFileImage(index);
        });
        //_imageString = base64Encode(_image.readAsBytesSync());
      } else {
        print('No image selected.');
      }
    });
  }

  void getFileImage(int index) async {
    setState(() {
      ImageUploadModel imageUpload = new ImageUploadModel();
      imageUpload.isUploaded = false;
      imageUpload.uploading = false;
      imageUpload.imageFile = _imageFile;
      imageUpload.imageUrl = '';
      images.replaceRange(index, index + 1, [imageUpload]);
    });
  }
}
