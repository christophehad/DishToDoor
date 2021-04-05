import 'package:flutter/material.dart';

Color blue = Colors.blueAccent;
Color mediumBlue = Colors.blueAccent.shade400;
Color darkBlue = Colors.blueAccent.shade700;
const Color transparentBlue = Color.fromRGBO(153, 179, 255, 0.7);
const Color darkGrey = Color(0xff202020);

const List<BoxShadow> shadow = [
  BoxShadow(color: Colors.black12, offset: Offset(0, 3), blurRadius: 6)
];

screenAwareSize(int size, BuildContext context) {
  double baseHeight = 640.0;
  return size * MediaQuery.of(context).size.height / baseHeight;
}
