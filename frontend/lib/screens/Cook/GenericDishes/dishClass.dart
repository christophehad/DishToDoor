class GenDishList {
  final List<GenDish> genDishList;

  GenDishList({
    this.genDishList,
  });

  factory GenDishList.fromJson(List<dynamic> json) {
    List<GenDish> genDishes = new List<GenDish>();
    genDishes = json.map<GenDish>((i) => GenDish.fromJson(i)).toList();

    return new GenDishList(genDishList: genDishes);
  }
}

class GenDish {
  final int id;
  final String name;
  final String category;

  GenDish({this.id, this.name, this.category});

  factory GenDish.fromJson(Map<String, dynamic> json) {
    return GenDish(
      id: json['id'],
      name: json['name'],
      category: json['category'],
    );
  }
}
