class DishList {
  final List<GenDish> dishList;

  DishList({
    this.dishList,
  });

  factory DishList.fromJson(List<dynamic> json) {
    List<GenDish> dishes = new List<GenDish>();
    dishes = json.map<GenDish>((i) => GenDish.fromJson(i)).toList();

    return new DishList(dishList: dishes);
  }
}

class GenDish {
  final int genDishID;
  final String genDishName;
  final String category;

  GenDish({this.genDishID, this.genDishName, this.category});

  factory GenDish.fromJson(Map<String, dynamic> json) {
    return GenDish(
      genDishID: json['id'],
      genDishName: json['name'],
      category: json['category'],
    );
  }
}
