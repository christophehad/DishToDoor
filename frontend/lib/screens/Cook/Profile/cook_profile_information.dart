import 'package:dishtodoor/screens/Eater/Order_Tracking/orderClass.dart';

class CookProfileInformation {
  final String email;
  final String phone;
  final bool isVerified;
  final DateTime dateAdded;
  final CookProfile cookProfile;

  CookProfileInformation(
      {this.email,
      this.phone,
      this.isVerified,
      this.dateAdded,
      this.cookProfile});

  factory CookProfileInformation.fromJson(Map<String, dynamic> json) {
//what put for dishPic
    return CookProfileInformation(
      email: json['email'],
      phone: json['phone'],
      isVerified: json['is_verified'],
      dateAdded: DateTime.parse(json['date_added']),
      cookProfile: CookProfile.fromJson(json['profile']),
      // dishPic: defaultLogo,
    );
  }
}
