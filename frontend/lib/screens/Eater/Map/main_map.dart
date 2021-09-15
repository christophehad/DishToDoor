import 'package:dishtodoor/screens/Eater/Map/cook_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:dishtodoor/config/config.dart';
import 'package:dishtodoor/screens/Eater/Map/custom_info_widget.dart';
import 'package:dishtodoor/screens/Eater/Map/cookClass.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dishtodoor/config/appProperties.dart';

//GET HERE FROM EMAIL LOGIN SCREEN
//This is an attempt at getting the current device location after asking user for permission

class MainMap extends StatefulWidget {
  final CookList cookList;
  MainMap({Key key, this.cookList}) : super(key: key);
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

class _MainMapState extends State<MainMap> {
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
  BitmapDescriptor cookPin; //to be modified later
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  CookList cooks = CookList();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  bool isOrderEmpty = false;

  @override
  void initState() {
    super.initState();
    getLoc().then((value) => locsharing());
    setSourceAndDestinationIcons();
    _fabHeight = _initFabHeight;
  }

//for Map building
  Future<void> getLoc() async {
    //checking if location services are enabled, else enable them
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        print("location service not enabled");
        return;
      }
    }

    //checking if permission to access location services is granted
    //else request permission
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print("permission for location not granted");
        return;
      }
    }
    //storing current user location in state variable
    var _loc = await _location.getLocation();
    setState(() {
      _finaluserlocation = LatLng(_loc.latitude, _loc.longitude);
    });
  }

  Future locsharing() async {
    //getting the unique user token
    String token = await storage.read(key: 'token');
    //sending an http get request to the "eater dishes around" API
    //and storing the result in response
    final http.Response response = await http.get(
      //including user location in request
      baseURL +
          '/eater/api/dish/around?lat=' +
          _finaluserlocation.latitude.toString() +
          '&lon=' +
          _finaluserlocation.longitude.toString(),
      //including user token in header
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token.toString(),
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON and send user to login screen
      dynamic decoded = jsonDecode(response.body);
      debugPrint("Received: " + decoded.toString(), wrapWidth: 1024);
      bool success = decoded['success'];
      print("success: " + success.toString());
      print(decoded['cooks']);
      if (success) {
        //convert the returned JSON object to a list of cooks
        //using a factory method inside the class CookList
        setState(() {
          cooks = CookList.fromJson(decoded['cooks']);
        });
        isOrderEmpty = false;
      } else {
        //handle errors
        setState(() {
          cooks = CookList();
        });
        isOrderEmpty = true;
        print("Error: " + decoded['error']);
      }
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      isOrderEmpty = true;
      print("An unkown error occured");
    }
  }

//Google maps enclosed in _body
  Widget _bodyWithCooks() {
    //map with cooks
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

  Widget _bodyCookless() {
    //body without cooks
    return GoogleMap(
      padding: EdgeInsets.only(bottom: 100, top: 50),
      initialCameraPosition: CameraPosition(target: _initialcameraposition),
      mapType: MapType.normal,
      onMapCreated: _onMapCreatedCookless,
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
    cookPin = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2), 'assets/map/cookPin.png');
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
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cooks.cooksList.map((p) {
                    return cooksCards(p);
                  }).toList()),
            ),
            SizedBox(
              height: 24,
            ),
          ],
        ));
  }

  String _checkIndex(List<CookDish> dish, int index) {
    if (dish.length > index) {
      return dish[index].name;
    }
    return "";
  }

  //List creation -- cooks cards
  Widget cooksCards(CookMap cook) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(cook.logo),
            ),
            title: Text(cook.firstName + "'s Kitchen"),
            subtitle: Text(
              "Distance " +
                  cook.distance.toStringAsFixed(2) +
                  "Km | " +
                  _checkIndex(cook.dishes, 0) +
                  ", " +
                  _checkIndex(cook.dishes, 1) +
                  ", " +
                  _checkIndex(cook.dishes, 2),
            ),
          ),
          TextButton(
            child: Text(
              'Order Here',
              style: TextStyle(color: blue),
            ),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CookPageEater(cook: cook)));
            },
          ),
        ],
      ),
    );
  }

//Creation of the cook instances
  void setPoints() {
    //advanced with picture
    for (var i in cooks.cooksList) {
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
                    image: NetworkImage(i.logo),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                child: Text(i.firstName + "'s Kitchen"),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CookPageEater(cook: i)));
                },
              ),
            ),
          ],
        ),
        location: i.getLocation(),
        icon: cookPin, //see what to do with this
        cookPoint: i,
      ));
    }
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
    setPoints();
    setMapPins();
    circleCreation();
    changeMapMode();
    setState(() {});
    _controller = _cntlr;

    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _finaluserlocation, zoom: 17),
      ),
    );
  }

  //things to do when map is created
  void _onMapCreatedCookless(GoogleMapController _cntlr) async {
    print("creating map");
    var _loc = await _location.getLocation();
    if (this.mounted) {
      setState(() {
        _finaluserlocation = LatLng(_loc.latitude, _loc.longitude);
      });
    }
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
    if (cooks.cooksList == null && isOrderEmpty == false) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (isOrderEmpty == true) {
      return Scaffold(
        body: _bodyCookless(),
      );
    }
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          _bodyWithCooks(),
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
