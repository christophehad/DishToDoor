import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:timeline_tile/timeline_tile.dart';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dishtodoor/screens/auth/globals.dart' as globals;
import 'package:dishtodoor/config/config.dart';
import 'orderClass.dart';

void main() => runApp(OrderApp());

class OrderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Horizontal Timeline',
      home: Order(),
    );
  }
}

const deliverySteps = ['Pending', 'Cooking', 'Ready'];

class Order extends StatefulWidget {
  @override
  OrderState createState() => OrderState();
}

class OrderState extends State<Order> {
  EaterOrderList orderList;
  ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();

    super.initState();
  }

//fetching order details
  Future<void> orderFetching() async {
    print("trying comm");
    final http.Response response = await http.get(
      baseURL + '/eater/api/orders/get',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        //TODO replace token
        'Authorization': "Bearer " +
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6OSwiaWF0IjoxNjEzMDQwOTgyfQ.5Pp6xPvfmqAeL09oWqX0sJugy3ryxsXdVfNSrHdv2TY",
      },
    );

    if (response.statusCode == 200) {
      dynamic decoded = jsonDecode(response.body);
      print("Received: " + decoded.toString());
      bool success = decoded['success'];
      if (success) {
        setState(() {
          orderList = EaterOrderList.fromJson(decoded['orders']);
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Positioned(
                        top: 45,
                        left: 5,
                        child: IconButton(
                          color: Colors.black,
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
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
                    child: CustomScrollView(
                      slivers: orderList.eaterOrderList.map((p) {
                        return deliveryTimeline(p);
                      }).toList(),
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

  Widget deliveryTimeline(EaterOrder order) {
    statusUpdate(order);
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  dense: true,
                  title: Text(
                    "Order " + order.orderId.toString(),
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  subtitle:
                      Text(order.cook.firstName + " " + order.cook.lastName),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text("Call " + order.cook.firstName),
                      onPressed: () {
                        //call cook
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            constraints: const BoxConstraints(maxHeight: 180),
            color: const Color(0xFF5D6173),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              itemCount: deliverySteps.length,
              itemBuilder: (BuildContext context, int index) {
                final step = deliverySteps[index];
                var indicatorSize = 30.0;
                var beforeLineStyle = LineStyle(
                  color: Colors.white.withOpacity(0.8),
                );

                _DeliveryStatus status;
                LineStyle afterLineStyle;
                if (index < order.completedStep) {
                  status = _DeliveryStatus.done;
                } else if (index > order.completedStep) {
                  status = _DeliveryStatus.todo;
                  indicatorSize = 20;
                  beforeLineStyle = const LineStyle(color: Color(0xFF747888));
                } else if (order.generalStatus == "rejected" ||
                    order.generalStatus == "cancelled") {
                  afterLineStyle = const LineStyle(color: Color(0xFF747888));
                  status = _DeliveryStatus.rejected;
                } else {
                  afterLineStyle = const LineStyle(color: Color(0xFF747888));
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
          )
        ],
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
}

// class _DeliveryTimeline extends StatefulWidget {
//   final EaterOrder order;
//   _DeliveryTimeline({Key key, @required this.order}) : super(key: key);

//   @override
//   _DeliveryTimelineState createState() => _DeliveryTimelineState();
// }

// class _DeliveryTimelineState extends State<_DeliveryTimeline> {
//   ScrollController _scrollController;
//   StepState pending = StepState.disabled;
//   StepState cooking = StepState.disabled;
//   StepState completed = StepState.disabled;

//   bool complete = false;

//   void statusUpdate(EaterOrder order) {
//     switch (order.generalStatus) {
//       case "pending":
//         {
//           setState(() => widget.order.completedStep = 0);
//         }
//         break;

//       case "approved":
//         {
//           setState(() => widget.order.completedStep = 1);
//         }
//         break;

//       case "rejected":
//         {
//           setState(() => widget.order.completedStep = 0);
//         }
//         break;

//       case "cancelled":
//         {
//           setState(() => widget.order.completedStep = 1);
//         }
//         break;

//       case "completed":
//         {
//           setState(() => widget.order.completedStep = 3);
//         }
//         break;

//       default:
//         {}
//         break;
//     }
//   }

//   @override
//   void initState() {
//     _scrollController = ScrollController();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SliverToBoxAdapter(
//       child: Container(
//         margin: const EdgeInsets.all(8),
//         constraints: const BoxConstraints(maxHeight: 210),
//         color: const Color(0xFF5D6173),
//         child: ListView.builder(
//           scrollDirection: Axis.horizontal,
//           controller: _scrollController,
//           itemCount: deliverySteps.length,
//           itemBuilder: (BuildContext context, int index) {
//             final step = deliverySteps[index];
//             var indicatorSize = 30.0;
//             var beforeLineStyle = LineStyle(
//               color: Colors.white.withOpacity(0.8),
//             );

//             _DeliveryStatus status;
//             LineStyle afterLineStyle;
//             if (index < widget.order.completedStep) {
//               status = _DeliveryStatus.done;
//             } else if (index > widget.order.completedStep) {
//               status = _DeliveryStatus.todo;
//               indicatorSize = 20;
//               beforeLineStyle = const LineStyle(color: Color(0xFF747888));
//             } else if (widget.order.generalStatus == "rejected") {
//               afterLineStyle = const LineStyle(color: Color(0xFF747888));
//               status = _DeliveryStatus.rejected;
//             } else {
//               afterLineStyle = const LineStyle(color: Color(0xFF747888));
//               status = _DeliveryStatus.doing;
//             }

//             return TimelineTile(
//               axis: TimelineAxis.horizontal,
//               alignment: TimelineAlign.center,
//               isFirst: index == 0,
//               isLast: index == deliverySteps.length - 1,
//               beforeLineStyle: beforeLineStyle,
//               afterLineStyle: afterLineStyle,
//               indicatorStyle: IndicatorStyle(
//                 width: indicatorSize,
//                 height: indicatorSize,
//                 indicator: _IndicatorDelivery(status: status),
//               ),
//               startChild: _StartChildDelivery(index: index),
//               endChild: _EndChildDelivery(
//                 text: step,
//                 current: index == widget.order.completedStep,
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

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
            color: Colors.white,
          ),
          child: const Center(
            child: Icon(Icons.check, color: Color(0xFF5D6173)),
          ),
        );

      case _DeliveryStatus.rejected:
        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          child: const Center(
            child: Icon(Icons.warning, color: Color(0xFF5D6173)),
          ),
        );

      case _DeliveryStatus.doing:
        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF2ACA8E),
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
