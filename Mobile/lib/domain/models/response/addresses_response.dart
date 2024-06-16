import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddressesResponse {
  final bool resp;
  final String msg;
  final List<ListAddress> listAddresses;

  AddressesResponse({
    required this.resp,
    required this.msg,
    required this.listAddresses,
  });

  factory AddressesResponse.fromJson(Map<String, dynamic> json) =>
      AddressesResponse(
        resp: json["resp"],
        msg: json["msg"],
        listAddresses: json["listAddresses"] != null
            ? List<ListAddress>.from(
                json["listAddresses"].map((x) => ListAddress.fromJson(x)))
            : [],
      );
}

class ListAddress {
  final String reference;
  final double latitude;
  final double longitude;
  bool isDefault;

  ListAddress({
    required this.reference,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  set setIsDefault(bool value) {
    isDefault = value;
  }

  factory ListAddress.fromJson(Map<String, dynamic> json) => ListAddress(
        reference: json["reference"],
        latitude: (json["latitude"] as num).toDouble(),
        longitude: (json["longitude"] as num).toDouble(),
        isDefault: json["is_default"],
      );
}

class DeviceLocation {
  final String id;
  final String username;
  final String phone;
  final double latitude;
  final double longitude;
  final DateTime currentDate;

  DeviceLocation({
    required this.id,
    required this.username,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.currentDate,
  });

  factory DeviceLocation.fromJson(String id, Map<String, dynamic> json) {
    var location = json["location"] as Map<String, dynamic>;

    return DeviceLocation(
      id: id,
      username: json['username'],
      phone: json['phone'],
      latitude: location['latitude'],
      longitude: location['longitude'],
      currentDate: DateTime.parse(location['datetime']),
    );
  }
}
