class Device {
  final String id;
  final String username;

  Device({
    required this.id,
    required this.username,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json["id"],
        username: json["username"],
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
