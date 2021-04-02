import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:dishtodoor/config/config.dart';
import 'package:dishtodoor/screens/Cook/orderClassCook.dart';

void main() => runApp(OrderApp());

class OrderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Horizontal Timeline',
      home: CookTrackOrder(),
    );
  }
}

const deliverySteps = ['Pending', 'Cooking', 'Ready'];

class CookTrackOrder extends StatefulWidget {
  final List<CookOrderList> orderList;
  CookTrackOrder({Key key, this.orderList}) : super(key: key);
  @override
  CookTrackOrderState createState() => CookTrackOrderState();
}

class CookTrackOrderState extends State<CookTrackOrder> {
  List<CookOrderList> orderList = List<CookOrderList>();
  Color doneButton = Colors.grey;

  @override
  void initState() {
    //orderList =
    //    widget.orderList == null ? widget.orderList : List<CookOrderList>();
    orderFetching();
    super.initState();
  }

//fetching order details
  Future<void> orderFetching() async {
    String token = await storage.read(key: 'token');
    print("token: " + token);
    print("trying comm");
    final http.Response response = await http.get(
      baseURL + '/cook/api/orders/get',
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
          if (orderList.isEmpty) {
            orderList.add(CookOrderList.fromJson(decoded['pending_orders']));
            orderList.add(CookOrderList.fromJson(decoded['current_orders']));
            orderList.add(CookOrderList.fromJson(decoded['past_orders']));
          } else {
            orderList[0] = CookOrderList.fromJson(decoded['pending_orders']);
            orderList[1] = CookOrderList.fromJson(decoded['current_orders']);
            orderList[2] = CookOrderList.fromJson(decoded['past_orders']);
          }
        });
        print("Successful!");
      } else {
        print("Error: " + decoded['error']);
      }
    } else {
      print(response.statusCode);
      print("An unkown error occured");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (orderList.isEmpty) {
      print("orderList is null");
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (orderList[0].cookOrderList == null &&
        orderList[1].cookOrderList == null &&
        orderList[2].cookOrderList == null) {
      print("orderList[i] is null");
      //TODO: mod this
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
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Positioned(
                    //       top: 45,
                    //       left: 5,
                    //       child: IconButton(
                    //         color: Colors.black,
                    //         icon: Icon(Icons.arrow_back),
                    //         onPressed: () {
                    //           Navigator.pop(context);
                    //         },
                    //       ),
                    //     ),
                    //   ],
                    // ),
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
    print("orderList:" + orderList.toString());
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
                    child: sectionTimeline(orderList),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void statusUpdate(CookOrder order) {
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

  Widget sectionTimeline(List<CookOrderList> status) {
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: [
        Card(
          elevation: 2,
          child: ExpansionTile(
            backgroundColor: Colors.white,
            title: Text(
              "Pending Orders",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
            ),
            trailing: numberOfOrders(status[0]),
            children: [
              ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: status[0].cookOrderList.map((p) {
                  return pendingTimeline(p);
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
              "Current Orders",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
            ),
            trailing: numberOfOrders(status[1]),
            children: [
              ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: status[1].cookOrderList.map((p) {
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
            trailing: numberOfOrders(status[2]),
            children: [
              ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: status[2].cookOrderList.map((p) {
                  return pastTimeline(p);
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget pendingTimeline(CookOrder order) {
    statusUpdate(order);
    var colorAccept = Colors.green;
    var colorReject = Colors.red;
    return Card(
      child: Column(
        children: [
          //TODO clickable tile to show order

          Card(
            elevation: 2,
            child: ExpansionTile(
              backgroundColor: Colors.white,
              title: Text(
                "Order " +
                    order.orderId.toString() +
                    " - " +
                    order.eater.firstName +
                    " " +
                    order.eater.lastName,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    child: Icon(
                      Icons.check_circle_outline,
                      color: colorAccept,
                    ),
                    onTap: () async {
                      await acceptOrder(order);
                    },
                  ),
                  InkWell(
                    child: Icon(
                      Icons.block,
                      color: colorReject,
                    ),
                    onTap: () async {
                      await rejectOrder(order);
                    },
                  ),
                ],
              ),
              children: [
                ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  children: order.dishes.map((p) {
                    return dishesCards(p);
                  }).toList(),
                ),
              ],
            ),
          ),

          // ListTile(
          //   dense: true,
          //   title: Text(
          //     "Order " + order.orderId.toString(),
          //     style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          //   ),
          //   subtitle: Text(order.eater.firstName + " " + order.eater.lastName),
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     InkWell(
          //       child: Icon(
          //         Icons.check_circle_outline,
          //         color: colorAccept,
          //       ),
          //       onTap: () async {
          //         if (await acceptOrder(order) == true) {
          //           colorAccept = Colors.green;
          //         }
          //       },
          //     ),
          //     InkWell(
          //       child: Icon(
          //         Icons.block,
          //         color: colorReject,
          //       ),
          //       onTap: () async {
          //         if (await rejectOrder(order) == true) {
          //           colorReject = Colors.red;
          //         }
          //       },
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget pastTimeline(CookOrder order) {
    statusUpdate(order);
    return Card(
      child: Column(
        children: [
          //TODO clickable tile to show order

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
              subtitle:
                  Text(order.eater.firstName + " " + order.eater.lastName),
              children: [
                ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  children: order.dishes.map((p) {
                    return dishesCards(p);
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget deliveryTimeline(CookOrder order) {
    statusUpdate(order);
    return Card(
      child: Column(
        children: [
          //TODO clickable tile to show order

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
                          order.eater.firstName +
                          " " +
                          order.eater.lastName,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () async {
                          await _cancelAlert(order);
                        },
                      ),
                      TextButton(
                        child: Text("Ready",
                            style: TextStyle(color: Colors.green)),
                        onPressed: () async {
                          await readyOrder(order);
                        },
                      ),
                      TextButton(
                        child:
                            Text("Done", style: TextStyle(color: doneButton)),
                        onPressed: () async {
                          await _completeAlert(order);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              trailing: InkWell(
                child: Icon(Icons.call_rounded, color: Colors.blue),
                onTap: () {
                  //call eater
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
                      return dishesCards(p);
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

  Widget numberOfOrders(CookOrderList status) {
    return Container(
      width: 30,
      height: 30,
      child: Center(
        child: Text(
          status.cookOrderList.length.toString(),
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

  //List creation -- cooks cards
  Widget dishesCards(OrderDish dish) {
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
                title: Text(dish.name + " x" + dish.quantity.toString()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> acceptOrder(CookOrder order) async {
    String token = await storage.read(key: 'token');
    print("token: " + token);
    print("trying comm acceptOrder");
    final http.Response response = await http.get(
      baseURL + '/cook/api/orders/approve?order_id=' + order.orderId.toString(),
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
        orderFetching();
        print("Successful!");
        return true;
      } else {
        print("Error: " + decoded['error']);
        return false;
      }
    } else {
      print(response.statusCode);
      print("An unkown error occured");
      return false;
    }
  }

  Future<bool> rejectOrder(CookOrder order) async {
    String token = await storage.read(key: 'token');
    print("token: " + token);
    print("trying comm rejectOrder");
    final http.Response response = await http.get(
      baseURL + '/cook/api/orders/reject?order_id=' + order.orderId.toString(),
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
        orderFetching();
        print("Successful!");
        return true;
      } else {
        print("Error: " + decoded['error']);
        return false;
      }
    } else {
      print(response.statusCode);
      print("An unkown error occured");
      return false;
    }
  }

  Future<bool> cancelOrder(CookOrder order) async {
    String token = await storage.read(key: 'token');
    print("token: " + token);
    print("trying comm cancelOrder");
    final http.Response response = await http.get(
      baseURL + '/cook/api/orders/cancel?order_id=' + order.orderId.toString(),
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
        orderFetching();
        print("Successful!");
        return true;
      } else {
        print("Error: " + decoded['error']);
        return false;
      }
    } else {
      print(response.statusCode);
      print("An unkown error occured");
      return false;
    }
  }

  Future<bool> completeOrder(CookOrder order) async {
    String token = await storage.read(key: 'token');
    print("token: " + token);
    print("trying comm completeOrder");
    final http.Response response = await http.get(
      baseURL +
          '/cook/api/orders/complete?order_id=' +
          order.orderId.toString(),
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
        orderFetching();
        print("Successful!");
        return true;
      } else {
        print("Error: " + decoded['error']);
        return false;
      }
    } else {
      print(response.statusCode);
      print("An unkown error occured");
      return false;
    }
  }

  Future<bool> readyOrder(CookOrder order) async {
    setState(() {
      doneButton = Colors.blue;
    });
    String token = await storage.read(key: 'token');
    print("token: " + token);
    print("trying comm readyOrder");
    final http.Response response = await http.get(
      baseURL + '/cook/api/orders/ready?order_id=' + order.orderId.toString(),
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
        orderFetching();
        print("Successful!");
        return true;
      } else {
        print("Error: " + decoded['error']);
        return false;
      }
    } else {
      print(response.statusCode);
      print("An unkown error occured");
      return false;
    }
  }

//Alert Dialaog
  Future<void> _cancelAlert(CookOrder order) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to cancel this order?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This action is permanent and irreversible.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes, Cancel'),
              onPressed: () async {
                await cancelOrder(order);
                return Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeAlert(CookOrder order) async {
    print("order step" + order.completedStep.toString());
    if (order.completedStep < 2) {
      return showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title:
                Text("You can't complete an order that wasn't picked up yet!"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Make sure to mark the dish as ready for pickup first.'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Proceed'),
                onPressed: () {
                  return Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
    return await completeOrder(order);
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
        child: InkWell(
          onTap: () {
            //send info for update then refresh
          },
          child: Image.asset('assets/delivery/$index.png', height: 50),
        ),
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
