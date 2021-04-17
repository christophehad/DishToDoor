import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:dishtodoor/config/config.dart';

class CookLoc {
  LatLng cookLocation;

  CookLoc();

  Future<LatLng> _getLoc() async {
    print("in get loc");
    Location loc = Location();
    var _loc = await loc.getLocation();
    this.cookLocation = LatLng(_loc.latitude, _loc.longitude);
    print(_loc.latitude.toString() + ", " + _loc.longitude.toString());
    return this.cookLocation;
  }

  Future<void> sendLoc() async {
    print("in sendLoc");
    _getLoc().then((value) async {
      print("sending call to backend");
      String token = await storage.read(key: 'token');
      print(value.latitude.toString() + ", " + value.longitude.toString());
      final requestBody = jsonEncode({
        'lat': value.latitude,
        'lon': value.longitude,
      });
      final http.Response response = await http.post(
        baseURL + '/cook/api/location/set',
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
          print("Successful!");
        } else {
          print("Error: " + decoded['error']);
        }
      } else {
        print(response.statusCode);
        print("An unkown error occured");
      }
    });
  }
}
