class DeviceAllResponse {
  final bool resp;
  final String msg;
  final List<Device> categories;

  DeviceAllResponse({
    required this.resp,
    required this.msg,
    required this.categories,
  });

  factory DeviceAllResponse.fromJson(Map<String, dynamic> json) =>
      DeviceAllResponse(
        resp: json["resp"],
        msg: json["msg"],
        categories: json["categories"] != null
            ? List<Device>.from(
                json["categories"].map((x) => Device.fromJson(x)))
            : [],
      );
}

class Device {
  final String id;
  final String username;
  final String? street;

  Device({
    required this.id,
    required this.username,
    required this.street,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json["id"],
        username: json["username"],
        street: json["street"],
      );
}

class DeviceNetwork {
  final String deviceKey;
  final String username;

  DeviceNetwork({
    required this.deviceKey,
    required this.username,
  });

  factory DeviceNetwork.fromJson(Map<String, dynamic> json) => DeviceNetwork(
        deviceKey: json["deviceKey"],
        username: json["username"],
      );
}
