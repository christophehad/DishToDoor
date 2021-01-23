import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//GET HERE FROM EMAIL LOGIN SCREEN
//This is an attempt at getting the current device location after asking user for permission
//TO-DO: add support for ios for both API google maps and geolocator enabling
//TO-DO: add diameter + dishes

class Map_main extends StatefulWidget {
  @override
  _Map_mainState createState() => _Map_mainState();
}

class _Map_mainState extends State<Map_main> {
  LatLng _initialcameraposition = LatLng(0, 0);
  GoogleMapController _controller;
  Location _location = Location();
  bool isMapCreated = false;

  changeMapMode() {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    if (!darkModeOn)
      getJsonFile("assets/map_theme.json").then(setMapStyle);
    else
      getJsonFile("assets/night_mode.json").then(setMapStyle);
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void setMapStyle(String mapStyle) {
    _controller.setMapStyle(mapStyle);
  }

  void _onMapCreated(GoogleMapController _cntlr) async {
    isMapCreated = true;
    changeMapMode();
    setState(() {});
    _controller = _cntlr;
    var _loc = await _location.getLocation();
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(_loc.latitude, _loc.longitude), zoom: 17),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: _initialcameraposition),
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
            ),
            Positioned(
              top: 35,
              left: 5,
              child: IconButton(
                color: Colors.white,
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
