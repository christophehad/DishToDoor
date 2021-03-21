import 'package:dishtodoor/screens/Eater/Order_Tracking/orderClass.dart';

class CookProfileInformation {
  final String email;
  final String phone;
  final bool is_verified;
  final String date_added;
  final CookProfile cookProfile;

  CookProfileInformation(
      {this.email,
      this.phone,
      this.is_verified,
      this.date_added,
      this.cookProfile});

  factory CookProfileInformation.fromJson(Map<String, dynamic> json) {
//what put for dishPic
    return CookProfileInformation(
      email: json['email'],
      phone: json['phone'],
      is_verified: json['is_verified'],
      date_added: json['date_added'],
      cookProfile: CookProfile.fromJson(json['profile']),
      // dishPic: defaultLogo,
    );
  }
}
