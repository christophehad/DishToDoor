import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:dishtodoor/screens/Map/custom_info_widget.dart';

import 'package:dishtodoor/screens/auth/register_as_eater.dart'; // for testing

import 'package:sliding_up_panel/sliding_up_panel.dart';

void main() => runApp(MyApp());

class PointObject {
  final Widget child;
  final LatLng location;
  final BitmapDescriptor icon;

  PointObject({this.child, this.location, this.icon});
}

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
        "/": (context) => HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PanelController _pc = new PanelController();
  final double _initFabHeight = 120.0;
  // ignore: unused_field
  double _fabHeight;
  double _panelHeightOpen = 450;
  double _panelHeightClosed = 95.0;

  Set<PointObject> _points = {}; //actual locations of users
  StreamSubscription _mapIdleSubscription;
  InfoWidgetRoute _infoWidgetRoute;
  GoogleMapController _mapController;
  BitmapDescriptor sourceIcon; //to be modified later
  BitmapDescriptor destIcon;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    setSourceAndDestinationIcons();
    _fabHeight = _initFabHeight;
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/map/driving_pin.png');

    destIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/map/destination_map_marker.png');
  }

  void setPoints() {
//advanced with picture
    _points.add(PointObject(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              child: CircleAvatar(
                backgroundImage: AssetImage("assets/map/friend1.jpg"),
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
      location: LatLng(47.6, 8.8796),
      icon: sourceIcon,
    ));

//simple
    _points.add(PointObject(
      child: Text('Sami Thawak2'),
      location: LatLng(47.6, 8.9),
      icon: destIcon,
    ));
  }

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
    // _markers.add(Marker(
    //   // This marker id can be anything that uniquely identifies each marker.
    //   markerId: MarkerId(point.location.latitude.toString() +
    //       point.location.longitude.toString()),
    //   position: point.location,
    //   onTap: () {
    //     _onTap(point);
    //   },
    //   icon: sourceIcon,
    // ));

    // _markers.add(Marker(
    //   // This marker id can be anything that uniquely identifies each marker.
    //   markerId: MarkerId(point2.location.latitude.toString() +
    //       point2.location.longitude.toString()),
    //   position: point2.location,
    //   onTap: () {
    //     _onTap(point2);
    //   },
    //   icon: destIcon,
    // ));
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
        ],
      ),
    );
  }

//Google maps enclosed in _body
  Widget _body() {
    return GoogleMap(
      padding: EdgeInsets.only(bottom: 100, top: 30),
      initialCameraPosition: CameraPosition(
        target: const LatLng(47.6, 8.6796),
        zoom: 10,
      ),

      markers: _markers,

      // Set<Marker>()
      //   ..add(Marker(
      //     markerId: MarkerId(point.location.latitude.toString() +
      //         point.location.longitude.toString()),
      //     position: point.location,
      //     onTap: () => _onTap(point),
      //     icon: sourceIcon,
      //   )),
      onMapCreated: (mapController) {
        _mapController = mapController;
        setPoints();
        setMapPins();
        circleCreation();
      },

      circles: _circles,

      /// This fakes the onMapIdle, as the googleMaps on Map Idle does not always work
      /// (see: https://github.com/flutter/flutter/issues/37682)
      /// When the Map Idles and a _infoWidgetRoute exists, it gets displayed.
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

  /// now my _onTap Method. First it creates the Info Widget Route and then
  /// animates the Camera twice:
  /// First to a place near the marker, then to the marker.
  /// This is done to ensure that onCameraMove is always called

  circleCreation() {
    for (var i in _points) {
      _circles.add(Circle(
        circleId: CircleId(
            i.location.latitude.toString() + i.location.longitude.toString()),
        center: i.location,
        radius: 50,
        strokeWidth: 10,
        strokeColor: Colors.black,
      ));
    }

    // Set<Circle>()
    //   ..add(Circle(
    //     circleId: CircleId(point.location.latitude.toString() +
    //         point.location.longitude.toString()),
    //     center: point.location,
    //     radius: 50,
    //     strokeWidth: 10,
    //     strokeColor: Colors.black,
    //   ));
  }

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

    await _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            point.location.latitude - 0.0001,
            point.location.longitude,
          ),
          zoom: 15,
        ),
      ),
    );
    await _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            point.location.latitude,
            point.location.longitude,
          ),
          zoom: 15,
        ),
      ),
    );
  }
}
