import 'package:firebase_auth/firebase_auth.dart';
import 'package:vision_aid/domain/models/response/addresses_response.dart';

class ResponseLogin {
  final bool resp;
  final String msg;
  final UserToken user;
  final String token;

  ResponseLogin({
    required this.resp,
    required this.msg,
    required this.token,
    required this.user,
  });

  factory ResponseLogin.fromJson(Map<String, dynamic> json) => ResponseLogin(
        resp: json["resp"],
        msg: json["msg"],
        user: UserToken.fromJson(json["user"] ?? {}),
        token: json["token"] ?? '',
      );
}

class UserToken {
  final String uid;
  final String name;
  final String image;
  final String email;
  final String phone;
  ListAddress? address;
  final String notificationToken;

  UserToken(
      {required this.uid,
      required this.name,
      required this.phone,
      required this.image,
      required this.email,
      required this.address,
      required this.notificationToken});

  factory UserToken.fromJson(Map<String, dynamic> json) => UserToken(
      uid: json["uid"] ?? 0,
      name: json["name"] ?? '',
      phone: json["phone"] ?? '',
      image: json["image"] ?? '',
      email: json["email"] ?? '',
      address: json["address"] != null
          ? ListAddress.fromJson(json["address"] as Map<String, dynamic>)
          : null,
      notificationToken: json["notification_token"] ?? '');
}
