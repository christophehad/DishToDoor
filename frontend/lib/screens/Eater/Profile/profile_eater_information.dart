import 'package:dishtodoor/screens/Cook/OrderTracking/orderClassCook.dart';

class ProfileEaterInformation {
  final String email;
  final String phone;
  final DateTime dateAdded;
  final EaterProfile eaterProfile;

  ProfileEaterInformation(
      {this.email, this.phone, this.dateAdded, this.eaterProfile});

  factory ProfileEaterInformation.fromJson(Map<String, dynamic> json) {
    return ProfileEaterInformation(
      email: json['email'],
      phone: json['phone'],
      dateAdded: DateTime.parse(json['date_added']),
      eaterProfile: EaterProfile.fromJson(json['profile']),
    );
  }
}
