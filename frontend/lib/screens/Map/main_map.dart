import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'custom_info_widget.dart';
import 'package:dishtodoor/screens/auth/register_as_eater.dart';

//GET HERE FROM EMAIL LOGIN SCREEN
//This is an attempt at getting the current device location after asking user for permission
//TO-DO: add support for ios for both API google maps and geolocator enabling
//TO-DO: add diameter + dishes

class MapMain extends StatefulWidget {
  @override
  _MapMainState createState() => _MapMainState();
}

//Attributes of point/marker on map
//TODO modify when communication API finalized
class PointObject {
  final Widget child;
  final LatLng location;
  final BitmapDescriptor icon;

  PointObject({this.child, this.location, this.icon});
}

class _MapMainState extends State<MapMain> {
  LatLng _initialcameraposition = LatLng(0, 0);
  GoogleMapController _controller;
  Location _location = Location();
  bool isMapCreated = false;
  Set<PointObject> _points = {}; //markers of cooks
  StreamSubscription _mapIdleSubscription;
  InfoWidgetRoute _infoWidgetRoute;
  BitmapDescriptor sourceIcon; //to be modified later
  BitmapDescriptor destIcon; //to be modified later
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    setSourceAndDestinationIcons();
  }

//Convert asset image to BitmapDescriptor
//TODO modify to type of images sent by backend
//TODO try to see if pin icon can be picture of someone cropped as circle
  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');

    destIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination_map_marker.png');
  }

//Creation of the cook instances
//TODO modify to take parameters from backend call
  void setPoints() {
    //advanced with picture
    _points.add(PointObject(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(
                    "assets/friend1.jpg",
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              child: Text("Sami Thawak"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        RegisterEaterPage())); //placeholder destination
              },
            ),
          ),
        ],
      ),
      location: LatLng(33.87, 35.5097),
      icon: sourceIcon,
    ));

//simple
    _points.add(PointObject(
      child: Text('Sami Thawak2'),
      location: LatLng(33.873, 35.5097),
      icon: destIcon,
    ));
  }

//Creation of the markers and functionality
  void setMapPins() {
    // source pin
    for (PointObject i in _points) {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(
            i.location.latitude.toString() + i.location.longitude.toString()),
        position: i.location,
        onTap: () {
          _onTap(i);
        },
        icon: i.icon,
      ));
    }
  }

//Changes map type between custom-daylight and nightmode
//TODO add button do overwrite night_mode in settings
  changeMapMode() {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    if (!darkModeOn)
      getJsonFile("assets/map_theme.json").then(setMapStyle);
    else
      getJsonFile("assets/night_mode.json").then(setMapStyle);
  }

  //Styling: create circle under mnarker
  circleCreation() {
    for (var i in _points) {
      _circles.add(Circle(
        circleId: CircleId(
            i.location.latitude.toString() + i.location.longitude.toString()),
        center: i.location,
        radius: 10,
        strokeWidth: 4,
        strokeColor: Colors.black,
      ));
    }
  }

//define functionality on tap of marker
  _onTap(PointObject point) async {
    final RenderBox renderBox = context.findRenderObject();
    Rect _itemRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;

    _infoWidgetRoute = InfoWidgetRoute(
      child: point.child,
      buildContext: context,
      textStyle: const TextStyle(
        fontSize: 14,
        color: Colors.black,
      ),
      mapsWidgetSize: _itemRect,
    );

    await _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            point.location.latitude - 0.0001,
            point.location.longitude,
          ),
          zoom: 17,
        ),
      ),
    );
    await _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            point.location.latitude,
            point.location.longitude,
          ),
          zoom: 17,
        ),
      ),
    );
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void setMapStyle(String mapStyle) {
    _controller.setMapStyle(mapStyle);
  }

//things to do when map is created
  void _onMapCreated(GoogleMapController _cntlr) async {
    isMapCreated = true;
    setPoints();
    setMapPins();
    circleCreation();
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
                markers: _markers,
                onMapCreated: _onMapCreated,
                circles: _circles,
                myLocationEnabled: true,
                onCameraMove: (newPosition) {
                  _mapIdleSubscription?.cancel();
                  _mapIdleSubscription =
                      Future.delayed(Duration(milliseconds: 150))
                          .asStream()
                          .listen((_) {
                    if (_infoWidgetRoute != null) {
                      Navigator.of(context, rootNavigator: true)
                          .push(_infoWidgetRoute)
                          .then<void>(
                        (newValue) {
                          _infoWidgetRoute = null;
                        },
                      );
                    }
                  });
                }),
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
