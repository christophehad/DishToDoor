import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dishtodoor/screens/Cook/Profile/set_cook_location.dart';

String baseURL = "https://dishtodoor.azurewebsites.net/";
// Create storage
final storage = new FlutterSecureStorage();
//store cook location
CookLoc cookLocation = CookLoc();
