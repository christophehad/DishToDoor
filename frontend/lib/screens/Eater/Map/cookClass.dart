import 'package:google_maps_flutter/google_maps_flutter.dart';

//TODO change default values

//definition of a list of cooks for convenience and automation
class CookList {
  final List<CookMap> cooksList;

  CookList({
    this.cooksList,
  });

  factory CookList.fromJson(List<dynamic> json) {
    List<CookMap> cooks = new List<CookMap>();
    cooks = json.map<CookMap>((i) => CookMap.fromJson(i)).toList();

    return new CookList(cooksList: cooks);
  }
}

class DishList {
  List<CookDish> dishList = List<CookDish>();

  DishList({
    this.dishList,
  });

  factory DishList.fromJson(List<dynamic> json) {
    List<CookDish> dishes = new List<CookDish>();
    dishes = json.map<CookDish>((i) => CookDish.fromJson(i)).toList();

    return new DishList(dishList: dishes);
  }
}

// DateTime dateFormatting(String s) {
//   final formatter = DateFormat.Hms();
//   return formatter.parse(s);
// }

//definition of cooks and construction from Json
class CookMap {
  final String firstName;
  final String lastName;
  final String logo;
  final double lat;
  final double lon;
  final double distance;
  final DateTime opening;
  final DateTime closing;
  final List<CookDish> dishes;

  LatLng getLocation() {
    return LatLng(lat, lon);
  }

  CookMap(
      {this.firstName,
      this.lastName,
      this.logo,
      this.lat,
      this.lon,
      this.distance,
      this.dishes,
      this.opening,
      this.closing});

  factory CookMap.fromJson(Map<String, dynamic> json) {
    var list = json['dishes'] as List;
    String defaultLogo = json['logo'];
    print(list.runtimeType);
    List<CookDish> dishesList = list.map((i) => CookDish.fromJson(i)).toList();
    //TODO add default logo to database
    if (defaultLogo == null) {
      defaultLogo =
          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png";
    } else {
      defaultLogo = json['logo'];
    }

    return new CookMap(
      firstName: json['first_name'],
      lastName: json['last_name'],
      logo: defaultLogo,
      lat: json['lat'],
      lon: json['lon'],
      distance: json['distance'] * 1.0,
      opening: DateTime.parse(json['opening_time']),
      closing: DateTime.parse(json['closing_time']),
      dishes: dishesList,
    );
  }
}

//definition of dishes that for a cook and construction from Json
class CookDish {
  final int dishID;
  final int gendishID;
  final String name;
  final int price;
  final String category;
  final String description;
  final String dishPic;
  final double avgRating;
  final List<DishRating> rating;
  bool available = false;

  CookDish(
      {this.dishID,
      this.gendishID,
      this.name,
      this.price,
      this.category,
      this.description,
      this.dishPic,
      this.avgRating,
      this.rating});

  factory CookDish.fromJson(Map<String, dynamic> json) {
    String defaultLogo =
        "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500";
    double defaultRating = 0.0;
    var defaultRatingsList = List<DishRating>();
    if (json['dish_pic'] == null) {
      defaultLogo =
          "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500";
    } else {
      defaultLogo = json['dish_pic'];
    }
    if (json['avg_rating'] != null) {
      defaultRating = json['avg_rating'] * 1.0;
    }
    if (json['ratings'] != null) {
      var list = json['ratings'] as List;
      defaultRatingsList = list.map((i) => DishRating.fromJson(i)).toList();
    }

    return CookDish(
      dishID: json['dish_id'],
      gendishID: json['gendish_id'],
      name: json['name'],
      price: json['price'],
      category: json['category'],
      description: json['description'],
      dishPic: defaultLogo,
      avgRating: defaultRating,
      rating: defaultRatingsList,
    );
  }
}

class DishRating {
  final EaterProfile eater;
  final double rating;
  final DateTime date;

  DishRating({
    this.eater,
    this.rating,
    this.date,
  });

  factory DishRating.fromJson(Map<String, dynamic> json) {
    return DishRating(
      eater: EaterProfile.fromJson(json['eater']),
      rating: json['rating'] * 1.0,
      date: DateTime.parse(json['date']),
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
