import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:dishtodoor/screens/Map/cookClass.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => CookPageEater(
              cook: CookMap(
                  firstName: "fadi",
                  lastName: "z",
                  distance: 20,
                  lat: 33.7,
                  lon: 33.05,
                  logo:
                      "https://www.lark.com/wp-content/uploads/2020/01/Blog_thumb-46.jpg",
                  dishes: [
                    CookDish(
                        category: "Salad",
                        description: "Delicious salad",
                        dishID: 4,
                        dishPic:
                            "https://christophehad.blob.core.windows.net/dishtodoor/cookpic2.jpeg",
                        gendishID: 1,
                        name: "TestSalad",
                        price: 10000)
                  ]),
            ),
      },
    );
  }
}

//TODO pass cookID from map page
class CookPageEater extends StatefulWidget {
  final CookMap cook;
  CookPageEater({Key key, @required this.cook}) : super(key: key);
  @override
  _CookPageEaterState createState() => _CookPageEaterState();
}

class _CookPageEaterState extends State<CookPageEater> {
  // Address _cookaddress = Address(coordinates: Coordinates(0, 0));

  @override
  void initState() {
    super.initState();
    //_updateLocation();
  }

  // Future<Address> _getLocationAddress(double latitude, double longitude) async {
  //   final coordinates = new Coordinates(latitude, longitude);
  //   var addresses =
  //       await Geocoder.local.findAddressesFromCoordinates(coordinates);
  //   var first = addresses.first;
  //   print(first);
  //   return first;
  // }

  // void _updateLocation() async {
  //   _cookaddressLL = LatLng(33.8915104820843, 35.50438119723922);
  //   _cookaddress = await _getLocationAddress(
  //       _cookaddressLL.latitude, _cookaddressLL.latitude);
  //   if (_cookaddress == null) {
  //     _cookaddress = Address(addressLine: "Lebanon");
  //   }
  // }

  //List creation -- cooks cards
  //TODO automate process using GET -- backend communication
  //TODO add link to buy now on tap
  Widget cooksCards(CookDish dish) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Card(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(dish.dishPic),
                ),
                trailing: Text(dish.price.toString() + "LBP"),
                title: Text(dish.name + " | " + dish.category),
                subtitle: Text(dish.description),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text("Add to cart"),
                    onPressed: () {/* ... */},
                  ),
                  TextButton(
                    child: const Text("Buy now"),
                    onPressed: () {/* ... */},
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget picture(context) {
    return Positioned(
      top: 0.0,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 3,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: NetworkImage(widget.cook.logo),
          ),
        ),
      ),
    );
  }

//TODO nead opening hours
  Widget _openNow(BuildContext context) {
    return RichText(
        text: TextSpan(
            // set the default style for the children TextSpans
            style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 13),
            children: [
          TextSpan(
            text: 'Open now - ',
            style: TextStyle(color: Colors.blueAccent),
          ),
          TextSpan(
              text: '11am - 10pm',
              style:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
        ]));
  }

  Widget _getDirections() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          'Get Directions',
          style: TextStyle(
              fontSize: 13.0,
              fontStyle: FontStyle.italic,
              color: Colors.blueAccent),
        ),
        IconButton(
          icon: Icon(Icons.pin_drop),
          onPressed: () {
            MapsLauncher.launchCoordinates(widget.cook.lat, widget.cook.lon);
          },
          color: Colors.blueAccent,
        ),
      ],
    );
  }

  Widget scrollableList(context) {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Container(
          height: 2.1 * MediaQuery.of(context).size.height / 3,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.0),
              topRight: Radius.circular(18.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 16.0,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              ),
            ],
          ),
          child: ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
            children: [
              SizedBox(
                height: 6.0,
              ),
              //Design, TODO get specialty from backend
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  widget.cook.firstName + "'s Kitchen",
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Specialty?",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.grey),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  widget.cook.distance.toStringAsFixed(2) + "Km away",
                  style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 15,
                      color: Colors.grey),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: _openNow(context),
              ),
              SizedBox(
                height: 8.0,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: _getDirections(),
              ),
              SizedBox(
                height: 8.0,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Column(
                    children: widget.cook.dishes.map((p) {
                  return cooksCards(p);
                }).toList()),
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          picture(context),
          scrollableList(context),
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
