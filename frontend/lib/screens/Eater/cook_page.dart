import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:dishtodoor/screens/Map/cookClass.dart';
import 'package:dishtodoor/screens/Eater/Checkout_Processs/bloc/cart_items.dart';
import 'package:dishtodoor/screens/Eater/Checkout_Processs/pages/checkout_screen.dart';

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
  }

  //List creation -- cooks cards
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
                trailing: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    dish.avgRating != 0.0
                        ? Icon(Icons.star, color: Colors.yellow)
                        : Text(""),
                    dish.avgRating != 0.0
                        ? Text(dish.avgRating.toStringAsFixed(1))
                        : Text(""),
                  ],
                ),
                title: Text(dish.name + "\n" + dish.price.toString() + "LBP"),
                subtitle: Text(dish.description),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text("Add to cart"),
                    onPressed: () {
                      bloc.addToCart(CartTuple(
                          dish: dish,
                          count: 1,
                          cookFname: widget.cook.firstName,
                          cookLname: widget.cook.lastName));
                    },
                  ),
                  TextButton(
                    child: const Text("Buy now"),
                    onPressed: () {
                      bloc.addToCart(CartTuple(
                          dish: dish,
                          count: 1,
                          cookFname: widget.cook.firstName,
                          cookLname: widget.cook.lastName));
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => Checkout()));
                    },
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

//check time range
  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    print(currentDate);
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  TextSpan _openingCheck(startDate, endDate) {
    if (isCurrentDateInRange(startDate, endDate)) {
      return TextSpan(
        text: "Open now - ",
        style: TextStyle(color: Colors.blueAccent),
      );
    } else {
      return TextSpan(
        text: "Closed - ",
        style: TextStyle(color: Colors.redAccent),
      );
    }
  }

  Widget _openNow(BuildContext context) {
    return RichText(
        text: TextSpan(
            style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 13),
            children: [
          _openingCheck(widget.cook.opening, widget.cook.closing),
          TextSpan(
              text: widget.cook.opening.toLocal().hour.toString() +
                  ':' +
                  widget.cook.opening.toLocal().minute.toString() +
                  ' - ',
              style:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          TextSpan(
              text: widget.cook.closing.toLocal().hour.toString() +
                  ':' +
                  widget.cook.closing.toLocal().minute.toString(),
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
                  widget.cook.distance.toStringAsFixed(2) + "Km away",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
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

  Widget body() {
    return Scaffold(
      body: Stack(
        children: [
          picture(context),
          scrollableList(context),
          Positioned(
            top: 45,
            left: 5,
            child: IconButton(
              color: Colors.white,
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 45,
            right: 15,
            child: IconButton(
              color: Colors.white,
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => Checkout()));
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return body();
  }
}
