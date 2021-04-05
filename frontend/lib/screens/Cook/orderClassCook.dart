//TODO change default values

//definition of a list of CookOrder for convenience and automation
class CookOrderList {
  final List<CookOrder> cookOrderList;

  CookOrderList({
    this.cookOrderList,
  });

  factory CookOrderList.fromJson(List<dynamic> json) {
    List<CookOrder> cooks = new List<CookOrder>();
    cooks = json.map<CookOrder>((i) => CookOrder.fromJson(i)).toList();

    return new CookOrderList(cookOrderList: cooks);
  }
}

//definition of CookOrder and construction from Json
class CookOrder {
  final int orderId;
  final int totalPrice;
  final EaterProfile eater;
  final String generalStatus;
  final DateTime scheduledTime;
  final List<OrderDish> dishes;
  int completedStep = 0;

  CookOrder(
      {this.eater,
      this.dishes,
      this.generalStatus,
      this.orderId,
      this.scheduledTime,
      this.totalPrice});

  factory CookOrder.fromJson(Map<String, dynamic> json) {
    var list = json['dishes'] as List;
    List<OrderDish> dishesList =
        list.map((i) => OrderDish.fromJson(i)).toList();

    var eater = EaterProfile.fromJson(json['eater']);

    return new CookOrder(
      eater: eater,
      dishes: dishesList,
      generalStatus: json['general_status'],
      orderId: json['order_id'],
      scheduledTime: DateTime.parse(json['scheduled_time']),
      totalPrice: json['total_price'],
    );
  }
}

//definition of cook and construction from Json
class EaterProfile {
  final String firstName;
  final String lastName;

  EaterProfile({
    this.firstName,
    this.lastName,
  });

  factory EaterProfile.fromJson(Map<String, dynamic> json) {
    return EaterProfile(
      firstName: json['first_name'],
      lastName: json['last_name'],
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
