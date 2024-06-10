part of 'device_bloc.dart';

@immutable
abstract class DeviceEvent {}

class OnGetDeviceLocationEvent extends DeviceEvent {
  final DocumentSnapshot documentSnapshot;

  OnGetDeviceLocationEvent(this.documentSnapshot);
}

class OnEditDeviceNetworkEvent extends DeviceEvent {
  final String deviceKey;
  final String ipAddress;
  final String name;
  final String password;

  OnEditDeviceNetworkEvent(this.deviceKey, this.ipAddress, this.name, this.password);
}

class OnAddDeviceEvent extends DeviceEvent {
  final String deviceKey;
  final String phone;
  final String username;

  OnAddDeviceEvent(this.deviceKey, this.phone, this.username);
}
// @immutable
// class onGetDeviceLocationEvent extends DeviceEvent {
//   final DocumentSnapshot documentSnapshot;
// }

@immutable
class onSubscribeDeviceLocationEvent extends DeviceEvent {
  final String deviceId;

  onSubscribeDeviceLocationEvent(this.deviceId);
}

@immutable
class onUnsubscribeDeviceLocationEvent extends DeviceEvent {
  final String deviceId;

  onUnsubscribeDeviceLocationEvent(this.deviceId);
}
