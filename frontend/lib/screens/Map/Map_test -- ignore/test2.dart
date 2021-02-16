import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:dishtodoor/screens/Map/custom_info_widget.dart';
import 'package:dishtodoor/screens/Map/cookClass.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => MainMap2(),
      },
    );
  }
}

//GET HERE FROM EMAIL LOGIN SCREEN
//This is an attempt at getting the current device location after asking user for permission

class MainMap2 extends StatefulWidget {
  final CookList cookList;
  MainMap2({Key key, this.cookList}) : super(key: key);
  @override
  _MainMapState createState() => _MainMapState();
}

//Attributes of point/marker on map
class PointObject {
  final Widget child;
  final LatLng location;
  final BitmapDescriptor icon;
  final CookMap cookPoint;

  PointObject({this.child, this.location, this.icon, this.cookPoint});
}

class _MainMapState extends State<MainMap2> {
  //cook classes
  //CookList cooks;

  PanelController _pc = new PanelController();
  final double _initFabHeight = 120.0;
  // ignore: unused_field
  double _fabHeight;
  double _panelHeightOpen = 450;
  double _panelHeightClosed = 95.0;

  LatLng _finaluserlocation;
  LatLng _initialcameraposition = LatLng(0, 0);
  GoogleMapController _controller;
  Location _location = Location();
  bool isMapCreated = false;
  StreamSubscription _mapIdleSubscription;
  InfoWidgetRoute _infoWidgetRoute;
  BitmapDescriptor sourceIcon; //to be modified later
  BitmapDescriptor destIcon; //to be modified later
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    //cooks = widget.cookList;
    setSourceAndDestinationIcons();
    _fabHeight = _initFabHeight;
  }

//Google maps enclosed in _body
  Widget _body() {
    return GoogleMap(
      padding: EdgeInsets.only(bottom: 100, top: 50),
      initialCameraPosition: CameraPosition(target: _initialcameraposition),
      mapType: MapType.normal,
      markers: _markers,
      onMapCreated: _onMapCreated,
      circles: _circles,
      myLocationEnabled: true,
      onCameraMove: (newPosition) {
        _mapIdleSubscription?.cancel();
        _mapIdleSubscription =
            Future.delayed(Duration(milliseconds: 150)).asStream().listen((_) {
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
      },
    );
  }

//Convert asset image to BitmapDescriptor
  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/map/driving_pin.png');

    destIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/map/destination_map_marker.png');
  }

//sliding up panel content -- infinite scroll
  Widget _panel(ScrollController sc) {
    print("panel creation");
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: sc,
          children: <Widget>[
            SizedBox(
              height: 12.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
              ],
            ),
            SizedBox(
              height: 18.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Explore Cooks",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 24.0,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 36.0,
            ),
            Container(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: ListTile(
                title: Text(
                    "It looks like there are currently no cooks around you."),
                subtitle:
                    Text("visit this page in a few days and have a look!"),
              ),
            ),
            SizedBox(
              height: 24,
            ),
          ],
        ));
  }

//Changes map type between custom-daylight and nightmode
  changeMapMode() {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    if (!darkModeOn)
      getJsonFile("assets/map_theme.json").then(setMapStyle);
    else
      getJsonFile("assets/night_mode.json").then(setMapStyle);
  }

  //for changeMapMode
  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void setMapStyle(String mapStyle) {
    _controller.setMapStyle(mapStyle);
  }

//things to do when map is created
  void _onMapCreated(GoogleMapController _cntlr) async {
    print("creating map");
    var _loc = await _location.getLocation();
    setState(() {
      _finaluserlocation = LatLng(_loc.latitude, _loc.longitude);
    });
    isMapCreated = true;
    changeMapMode();
    setState(() {});
    _controller = _cntlr;

    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _finaluserlocation, zoom: 17),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          _body(),
          SlidingUpPanel(
            controller: _pc,
            maxHeight: _panelHeightOpen,
            minHeight: _panelHeightClosed,
            parallaxEnabled: true,
            parallaxOffset: .5,
            panelBuilder: (sc) => _panel(sc),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
            onPanelSlide: (double pos) => setState(
              () {
                _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                    _initFabHeight;
              },
            ),
          ),
        ],
      ),
    );
  }
}
