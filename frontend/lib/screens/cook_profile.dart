// import 'package:flutter/material.dart';

// class ProfileCook2 extends StatefulWidget {
//   ProfileCook2({Key key}) : super(key: key);
//   @override
//   _ProfileCookState2 createState() => _ProfileCookState2();
// }

// class _ProfileCookState2 extends State<ProfileCook2> {
//   DateTime pickupDate;
//   bool datePicked = false;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.teal[200],
//       body:SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//              CircleAvatar(
//                radius: 50,
//                backgroundImage:NetworkImage(cook.logo),//check here
//              ),
//              Text(,//get name
//              style: TextStyle(
//                fontSize: 40.0,
//                color: Colors.white,
//                fontWeight: FontWeight.bold
//                ),
//              ),
//               SizedBox(
//               height: 20,
//               width: 200,
//               child: Divider(
//                 color: Colors.teal.shade700,
//                 ),
//                 ),
//                Card(
//                 color: Colors.white,
//                 margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 25.0),
//                 child: ListTile(
//                   leading: Icon(
//                    Icons.phone,
//                    color: Colors.teal,
//                   )
//                   title:Text(
//                     //add phone number
//                     style: TextStyle(
//                        fontSize: 20.0,
//                        color: Colors.teal,
//                     )
//                   )
//                 )
//               ),
//               Card(
//                 color: Colors.white,
//                 margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 25.0),
//                 child: ListTile(
//                   leading: Icon(
//                    Icons.email,
//                    color: Colors.teal,
//                   )
//                   title:Text(
//                     //add email
//                     style: TextStyle(
//                        fontSize: 20.0,
//                        color: Colors.teal,
//                     )
//                   )
//                 )
//               ),
//               Card(
//                 color: Colors.white,
//                 margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 25.0),
//                 child: ListTile(
//                   leading: Icon(
//                    Icons.location_city,
//                    color: Colors.teal,
//                   )
//                   title:Text(
//                     //add location
//                     style: TextStyle(
//                        fontSize: 20.0,
//                        color: Colors.teal,
//                     )
//                   )
//                 )
//               ),
//                 Card(
//                 color: Colors.white,
//                 margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 25.0),
//                 child: ListTile(
//                   leading: Icon(
//                    Icons.check,
//                    color: Colors.teal,
//                   )
//                   title:Text(
//                     //add verified since
//                     style: TextStyle(
//                        fontSize: 20.0,
//                        color: Colors.teal,
//                     )
//                   )
//                 )
//               )
//           ],
//           )

//       ),
//     );
//   }
// }
