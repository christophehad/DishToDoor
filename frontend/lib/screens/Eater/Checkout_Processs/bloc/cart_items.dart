/// The [dart:async] is neccessary for using streams
import 'dart:async';

import 'package:dishtodoor/screens/Eater/Map/cookClass.dart';

class CartTuple {
  final CookDish dish;
  final String cookFname;
  final String cookLname;
  int count = 0;

  CartTuple({this.dish, this.count, this.cookFname, this.cookLname});

  void increment() {
    count = count + 1;
  }

  void decrement() {
    if (count >= 1) {
      count = count - 1;
    }
    return;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'dish_id': dish.dishID,
        'quantity': count,
      };
}

class CartItems {
  /// The [cartStreamController] is an object of the StreamController class
  /// .broadcast enables the stream to be read in multiple screens of our app
  final cartStreamController = StreamController.broadcast();

  /// The [getStream] getter would be used to expose our stream to other classes
  Stream get getStream => cartStreamController.stream;

  List<CartTuple> cartItems = [];
  DateTime pickupDate;

  void addToCart(CartTuple item) {
    var contain =
        cartItems.where((element) => element.dish.dishID == item.dish.dishID);
    if (contain.isEmpty) {
      cartItems.add(item);
      print("does not contain");
    } else {
      var itemIndex = cartItems
          .indexWhere((element) => element.dish.dishID == item.dish.dishID);
      cartItems[itemIndex].count++;
      print("contain: " + cartItems[itemIndex].count.toString());
    }
    cartStreamController.sink.add(cartItems);
  }

  void removeFromCart(CartTuple item) {
    var contain =
        cartItems.where((element) => element.dish.dishID == item.dish.dishID);
    if (contain.isNotEmpty) {
      var itemIndex = cartItems
          .indexWhere((element) => element.dish.dishID == item.dish.dishID);
      cartItems[itemIndex].count--;
      if (cartItems[itemIndex].count == 0) {
        cartItems.removeAt(itemIndex);
      }
    }

    cartStreamController.sink.add(cartItems);
  }

  void emptyCart() {
    cartItems.clear();
    pickupDate = DateTime.now();
  }

  int totalCost() {
    int sum = 0;
    for (var i in cartItems) {
      sum += i.dish.price * i.count;
    }
    return sum;
  }

  /// The [dispose] method is used
  /// to automatically close the stream when the widget is removed from the widget tree
  void dispose() {
    cartStreamController.close(); // close our StreamController
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'dishes': cartItems,
        'total': this.totalCost(),
        'scheduled_time': pickupDate.toString(),
      };
}

final bloc = CartItems();
