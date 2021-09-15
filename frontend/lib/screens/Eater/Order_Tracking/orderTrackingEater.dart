import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:dishtodoor/config/config.dart';
import 'orderClass.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dishtodoor/config/appProperties.dart';

const deliverySteps = ['Pending', 'Cooking', 'Ready'];

class EaterTrackOrder extends StatefulWidget {
  final EaterOrderList orderList;
  EaterTrackOrder({Key key, this.orderList}) : super(key: key);
  @override
  EaterTrackOrderState createState() => EaterTrackOrderState();
}

class EaterTrackOrderState extends State<EaterTrackOrder> {
  EaterOrderList orderList = EaterOrderList();
  EaterOrderList done = EaterOrderList();
  EaterOrderList ongoing = EaterOrderList();
  bool isOrderEmpty = false;
  double ratingDish = 1.0;

  @override
  void initState() {
    orderFetching();
    super.initState();
  }

//fetching order details
  Future<void> orderFetching() async {
    String token = await storage.read(key: 'token');
    print("token: " + token);
    print("trying comm");
    final http.Response response = await http.get(
      baseURL + '/eater/api/orders/get',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token.toString(),
        //"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6OSwiaWF0IjoxNjEzMDQwOTgyfQ.5Pp6xPvfmqAeL09oWqX0sJugy3ryxsXdVfNSrHdv2TY",
      },
    );

    if (response.statusCode == 200) {
      dynamic decoded = jsonDecode(response.body);
      print("Received: " + decoded.toString());
      bool success = decoded['success'];
      if (success) {
        setState(() {
          orderList = EaterOrderList.fromJson(decoded['orders']);
          isOrderEmpty = false;
          done = EaterOrderList();
          done.eaterOrderList = List<EaterOrder>();
          ongoing = EaterOrderList();
          ongoing.eaterOrderList = List<EaterOrder>();
        });
        classifyDishes(orderList);
        print("Successful!");
      } else {
        print("Error: " + decoded['error']);
        setState(() {
          isOrderEmpty = true;
        });
      }
    } else {
      print(response.statusCode);
      print("An unkown error occured");
      setState(() {
        isOrderEmpty = true;
      });
    }
  }

  Future<void> sendDishRating(
      EaterOrder order, OrderDish dish, double ratingDish) async {
    String token = await storage.read(key: 'token');
    final http.Response response = await http.post(
      baseURL + '/eater/api/dish/rate',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token.toString(),
      },
      body: jsonEncode(<String, String>{
        'dish_id': dish.dishID.toString(),
        'order_id': order.orderId.toString(),
        'rating': ratingDish.toString(),
      }),
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 CREATED response,
      // then parse the JSON and send user to login screen
      dynamic decoded = jsonDecode(response.body);
      print("Received: " + decoded.toString());
      bool success = decoded['success'];
      if (success) {
        print("Successful!");
      } else {
        //handle errors
        print("Error: " + decoded['error']);
      }
    }
  }

  void classifyDishes(EaterOrderList orderList) {
    int i = 0;
    while (i < orderList.eaterOrderList.length) {
      if (orderList.eaterOrderList[i].generalStatus == "completed" ||
          orderList.eaterOrderList[i].generalStatus == "cancelled" ||
          orderList.eaterOrderList[i].generalStatus == "rejected") {
        setState(() {
          done.eaterOrderList.add(orderList.eaterOrderList[i]);
        });
      } else {
        setState(() {
          ongoing.eaterOrderList.add(orderList.eaterOrderList[i]);
        });
      }
      ++i;
    }
    setState(() {
      ongoing.eaterOrderList = ongoing.eaterOrderList.reversed.toList();
    });
  }

  Widget rateDish(EaterOrder order, OrderDish dish) {
    return RatingBar.builder(
      initialRating: 3,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        setState(() {
          ratingDish = rating;
        });
        print(rating);
      },
    );
  }

  Widget rateButton(BuildContext context, EaterOrder order, OrderDish dish) {
    return InkWell(
      child: Icon(
        Icons.star,
        color: dish.rated ? Colors.amberAccent : Colors.grey,
      ),
      onTap: () {
        _showPicker(context, order, dish);
      },
    );
  }

  void _showPicker(context, EaterOrder order, OrderDish dish) async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new ListTile(
                leading: new Text("Rate Dish"),
                title: rateDish(order, dish),
                trailing: InkWell(
                  child: Text(
                    "Done",
                    style: TextStyle(color: blue),
                  ),
                  onTap: () {
                    sendDishRating(order, dish, ratingDish);
                  },
                ),
              ),
            ),
          );
        });
  }

  Future<void> _launchCaller(String number) async {
    String url = "tel:" + number;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (orderList.eaterOrderList == null && isOrderEmpty == false) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (isOrderEmpty == true) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F8F8),
              Colors.white,
            ],
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            accentColor: const Color(0xFF35577D).withOpacity(0.2),
          ),
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              extendBodyBehindAppBar: true,
              body: Center(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Your Orders",
                            style: TextStyle(
                                fontSize: 23, fontWeight: FontWeight.bold)),
                        SizedBox(width: MediaQuery.of(context).size.width / 2),
                        IconButton(
                          color: Colors.black,
                          icon: Icon(Icons.refresh),
                          onPressed: () {
                            orderFetching();
                          },
                        ),
                      ],
                    ),
                    Expanded(
                      child: Expanded(
                        child: Text(
                          "It looks like you don't have any orders yet!",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F8F8),
            Colors.white,
          ],
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          accentColor: const Color(0xFF35577D).withOpacity(0.2),
        ),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            body: Center(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Your Orders",
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.bold)),
                      SizedBox(width: MediaQuery.of(context).size.width / 2),
                      IconButton(
                        color: Colors.black,
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          orderFetching();
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: sectionTimeline(ongoing, done),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionTimeline(EaterOrderList ongoing, EaterOrderList done) {
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: [
        Card(
          elevation: 2,
          child: ExpansionTile(
            backgroundColor: Colors.white,
            title: Text(
              "Current Orders",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
            ),
            trailing: numberOfOrders(ongoing),
            children: [
              ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: ongoing.eaterOrderList.map((p) {
                  return deliveryTimeline(p);
                }).toList(),
              ),
            ],
          ),
        ),
        Card(
          elevation: 2,
          child: ExpansionTile(
            backgroundColor: Colors.white,
            title: Text(
              "Past Orders",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
            ),
            trailing: numberOfOrders(done),
            children: [
              ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: done.eaterOrderList.map((p) {
                  return pastTimeline(p);
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget pastTimeline(EaterOrder order) {
    statusUpdate(order);
    return Card(
      child: Column(
        children: [
          Card(
            elevation: 2,
            child: ExpansionTile(
              backgroundColor: Colors.white,
              title: Text(
                "Order " +
                    order.orderId.toString() +
                    " - " +
                    order.generalStatus.toString(),
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(order.cook.firstName + " " + order.cook.lastName),
              children: [
                ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  children: order.dishes.map((p) {
                    return dishesCards(order, p);
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget deliveryTimeline(EaterOrder order) {
    statusUpdate(order);
    return Card(
      child: Column(
        children: [
          Card(
            elevation: 2,
            child: ExpansionTile(
              backgroundColor: Colors.white,
              title: Column(
                children: [
                  ListTile(
                    dense: true,
                    title: Text(
                      "Order " +
                          order.orderId.toString() +
                          " - " +
                          order.cook.firstName +
                          " " +
                          order.cook.lastName,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      "pickup time: " +
                          DateFormat('kk:mm').format(order.scheduledTime) +
                          "\n" +
                          "total: " +
                          order.totalPrice.toString() +
                          " LBP",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              trailing: InkWell(
                child: Icon(Icons.call_rounded, color: blue),
                onTap: () async {
                  //TODO add cook number to CookProfile - Christophe
                  await _launchCaller(order.cook.phone);
                },
              ),
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: deliverySteps.length,
                    itemBuilder: (BuildContext context, int index) {
                      final step = deliverySteps[index];
                      var indicatorSize = 30.0;
                      var beforeLineStyle = LineStyle(
                        color: Colors.green.withOpacity(0.8),
                      );

                      _DeliveryStatus status;
                      LineStyle afterLineStyle;
                      if (index < order.completedStep) {
                        status = _DeliveryStatus.done;
                      } else if (index > order.completedStep) {
                        status = _DeliveryStatus.todo;
                        indicatorSize = 20;
                        beforeLineStyle =
                            const LineStyle(color: Color(0xFF747888));
                      } else if (order.generalStatus == "rejected" ||
                          order.generalStatus == "cancelled") {
                        afterLineStyle =
                            const LineStyle(color: Color(0xFF747888));
                        status = _DeliveryStatus.rejected;
                      } else {
                        afterLineStyle =
                            const LineStyle(color: Color(0xFF747888));
                        status = _DeliveryStatus.doing;
                      }

                      return TimelineTile(
                        axis: TimelineAxis.horizontal,
                        alignment: TimelineAlign.center,
                        isFirst: index == 0,
                        isLast: index == deliverySteps.length - 1,
                        beforeLineStyle: beforeLineStyle,
                        afterLineStyle: afterLineStyle,
                        indicatorStyle: IndicatorStyle(
                          width: indicatorSize,
                          height: indicatorSize,
                          indicator: _IndicatorDelivery(status: status),
                        ),
                        startChild: _StartChildDelivery(index: index),
                        endChild: _EndChildDelivery(
                          text: step,
                          current: index == order.completedStep,
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: order.dishes.map((p) {
                      return dishesCards(order, p);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget numberOfOrders(EaterOrderList orderList) {
    return Container(
      width: 30,
      height: 30,
      child: Center(
        child: Text(
          orderList.eaterOrderList.length.toString(),
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
        color: Colors.white,
      ),
    );
  }

  void statusUpdate(EaterOrder order) {
    switch (order.generalStatus) {
      case "pending":
        {
          setState(() => order.completedStep = 0);
        }
        break;

      case "approved":
        {
          setState(() => order.completedStep = 1);
        }
        break;

      case "rejected":
        {
          setState(() => order.completedStep = 0);
        }
        break;

      case "cancelled":
        {
          setState(() => order.completedStep = 1);
        }
        break;

      case "ready":
        {
          setState(() => order.completedStep = 2);
        }
        break;

      case "completed":
        {
          setState(() => order.completedStep = 3);
        }
        break;

      default:
        {}
        break;
    }
  }

  //List creation -- cooks cards
  Widget dishesCards(EaterOrder order, OrderDish dish) {
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
                trailing: rateButton(context, order, dish),
                title: Text(dish.name +
                    " x" +
                    dish.quantity.toString() +
                    "\n" +
                    dish.price.toString() +
                    "LBP"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _DeliveryStatus { done, doing, todo, rejected }

class _StartChildDelivery extends StatelessWidget {
  const _StartChildDelivery({Key key, this.index}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Image.asset('assets/delivery/$index.png', height: 50),
      ),
    );
  }
}

class _EndChildDelivery extends StatelessWidget {
  const _EndChildDelivery({
    Key key,
    @required this.text,
    @required this.current,
  }) : super(key: key);

  final String text;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      alignment: Alignment.topCenter,
      constraints: const BoxConstraints(minWidth: 125, maxHeight: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class _IndicatorDelivery extends StatelessWidget {
  const _IndicatorDelivery({Key key, this.status}) : super(key: key);

  final _DeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case _DeliveryStatus.done:
        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          child: const Center(
            child: Icon(Icons.check, color: Colors.white),
          ),
        );

      case _DeliveryStatus.rejected:
        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          child: const Center(
            child: Icon(Icons.warning, color: Colors.white),
          ),
        );

      case _DeliveryStatus.doing:
        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          child: const Center(
            child: SizedBox(
              height: 15,
              width: 15,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        );
      case _DeliveryStatus.todo:
        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF747888),
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF5D6173),
              ),
            ),
          ),
        );
    }
    return Container();
  }
}
