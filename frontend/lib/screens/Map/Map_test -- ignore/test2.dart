import 'dart:convert';
import 'package:dishtodoor/screens/Eater/cook_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:dishtodoor/config/config.dart';

import 'package:dishtodoor/screens/Map/custom_info_widget.dart';
import 'package:dishtodoor/screens/Map/cookClass.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       initialRoute: "/",
//       routes: {
//         "/": (context) => HomePage(),
//       },
//     );
//   }
// }

//GET HERE FROM EMAIL LOGIN SCREEN
//This is an attempt at getting the current device location after asking user for permission
//TO-DO: add support for ios for both API google maps and geolocator enabling
//TO-DO: add diameter

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
  //cook classes
  CookList cooks;

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
    _fabHeight = _initFabHeight;
  }

//send location to backend
  void locsharing() async {
    final http.Response response = await http.get(
      baseURL +
          '/eater/api/dish/around?lat=' +
          _finaluserlocation.latitude.toString() +
          '&lon=' +
          _finaluserlocation.longitude.toString(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON and send user to login screen
      dynamic decoded = jsonDecode(response.body);
      print("Received: " + decoded.toString());
      bool success = decoded['success'];

      if (success) {
        cooks = CookList(cooksList: decoded['cooks']);
        //_registerSuccessfulAlert();
        print("Successful!");
      } else {
        //handle errors
        print("Error: " + decoded['error']);
        //_registerErrorAlert(decoded['error']);
      }
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      print("An unkown error occured");
    }
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
//TODO modify to type of images sent by backend
//TODO try to see if pin icon can be picture of someone cropped as circle
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  cooksCards(),
                ],
              ),
            ),
            SizedBox(
              height: 24,
            ),
          ],
        ));
  }

  //List creation -- cooks cards
  //TODO automate process using GET -- backend communication
  //TODO add link to cook's page on tap
  Widget cooksCards() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage("assets/map/friend1.jpg"),
                ),
                title: Text("Fady's Kitchen"),
                subtitle: Text("Distance xkm | Today's dishes maybe?"),
              ),
              TextButton(
                child: const Text('Order Here'),
                onPressed: () {/* ... */},
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage("assets/map/friend2.jpg"),
                ),
                title: Text("Karam's Kitchen"),
                subtitle: Text("Today's dishes maybe?"),
              ),
              TextButton(
                child: const Text('Order Here'),
                onPressed: () {/* ... */},
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage("assets/map/friend1.jpg"),
                ),
                title: Text("Test's Kitchen"),
                subtitle: Text("Today's dishes maybe?"),
              ),
              TextButton(
                child: const Text('Order Here'),
                onPressed: () {/* ... */},
              ),
            ],
          ),
        ),
      ],
    );
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
                    "assets/map/friend1.jpg",
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
                    builder: (_) => CookPageEater(
                        cook:
                            CookMap()))); //placeholder destination -- change later
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
          if (_pc.isPanelClosed) _onTap(i);
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
    _finaluserlocation = LatLng(_loc.latitude, _loc.longitude);
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _finaluserlocation, zoom: 17),
      ),
    );
    //locsharing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          SlidingUpPanel(
            controller: _pc,
            maxHeight: _panelHeightOpen,
            minHeight: _panelHeightClosed,
            parallaxEnabled: true,
            parallaxOffset: .5,
            body: _body(),
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
    );
  }
}
