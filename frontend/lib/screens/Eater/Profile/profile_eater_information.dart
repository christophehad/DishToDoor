import 'package:dishtodoor/screens/Cook/orderClassCook.dart';

class ProfileEaterInformation {
  final String email;
  final String phone;
  final String date_added;
  final EaterProfile eaterProfile;

  ProfileEaterInformation(
      {this.email, this.phone, this.date_added, this.eaterProfile});

  factory ProfileEaterInformation.fromJson(Map<String, dynamic> json) {
    return ProfileEaterInformation(
      email: json['email'],
      phone: json['phone'],
      date_added: json['date_added'],
      eaterProfile: EaterProfile.fromJson(json['profile']),
    );
  }
}
