import 'package:google_maps_flutter/google_maps_flutter.dart';

//TODO change default values

//definition of a list of EaterOrder for convenience and automation
class EaterOrderList {
  final List<EaterOrder> eaterOrderList;

  EaterOrderList({
    this.eaterOrderList,
  });

  factory EaterOrderList.fromJson(List<dynamic> json) {
    List<EaterOrder> cooks = new List<EaterOrder>();
    cooks = json.map<EaterOrder>((i) => EaterOrder.fromJson(i)).toList();

    return new EaterOrderList(eaterOrderList: cooks);
  }
}

//definition of EaterOrder and construction from Json
class EaterOrder {
  final int orderId;
  final int totalPrice;
  final CookProfile cook;
  final String generalStatus;
  final DateTime scheduledTime;
  final List<OrderDish> dishes;
  int completedStep = 0;

  EaterOrder(
      {this.cook,
      this.dishes,
      this.generalStatus,
      this.orderId,
      this.scheduledTime,
      this.totalPrice});

  factory EaterOrder.fromJson(Map<String, dynamic> json) {
    var list = json['dishes'] as List;
    List<OrderDish> dishesList =
        list.map((i) => OrderDish.fromJson(i)).toList();

    var cook = CookProfile.fromJson(json['cook']);

    //TODO add default logo to database
    String defaultLogo = json['logo'];
    if (defaultLogo == null) {
      defaultLogo =
          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";
    } else {
      defaultLogo = json['logo'];
    }

    return new EaterOrder(
      cook: cook,
      dishes: dishesList,
      generalStatus: json['general_status'],
      orderId: json['order_id'],
      scheduledTime: DateTime.parse(json['scheduled_time']),
      totalPrice: json['total_price'],
    );
  }
}

//definition of cook and construction from Json
class CookProfile {
  final String firstName;
  final String lastName;
  final String logo;
  final double lat;
  final double lon;
  final DateTime opening;
  final DateTime closing;

  LatLng getLocation() {
    return LatLng(lat, lon);
  }

  CookProfile(
      {this.firstName,
      this.lastName,
      this.logo,
      this.lat,
      this.lon,
      this.opening,
      this.closing});

  factory CookProfile.fromJson(Map<String, dynamic> json) {
    String defaultLogo =
        "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500";

    if (json['logo'] == null) {
    } else {
      defaultLogo = json['logo'];
    }

    return CookProfile(
      firstName: json['first_name'],
      lastName: json['last_name'],
      logo: defaultLogo,
      lat: json['lat'],
      lon: json['lon'],
      opening: DateTime.parse(json['opening_time']),
      closing: DateTime.parse(json['closing_time']),
    );
  }
}

//definition of dish and construcion from json
class OrderDish {
  final int dishID;
  final String name;
  final int price;
  final int quantity;
  final String dishPic;

  OrderDish({this.dishID, this.dishPic, this.name, this.price, this.quantity});

  factory OrderDish.fromJson(Map<String, dynamic> json) {
    String defaultLogo =
        "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500";

    if (json['dish_pic'] == null) {
      defaultLogo =
          "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500";
    } else {
      defaultLogo = json['dish_pic'];
    }

    return OrderDish(
      dishID: json['dish_id'],
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
      dishPic: defaultLogo,
    );
  }
}
