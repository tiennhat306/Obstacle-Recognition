part of 'device_bloc.dart';

@immutable
class DeviceState {
  final DeviceLocation? deviceLocation;

  const DeviceState({this.deviceLocation});

  DeviceState copyWith({
    DeviceLocation? deviceLocation,
  }) => DeviceState(
    deviceLocation: deviceLocation ?? this.deviceLocation,
  );
}




class LoadingDeviceState extends DeviceState {}

class SuccessDeviceState extends DeviceState {
  const SuccessDeviceState(DeviceLocation deviceLocation) : super(deviceLocation: deviceLocation);
}

class SuccessDeviceNetworkState extends DeviceState {}

class SuccessAddDeviceState extends DeviceState {}

class FailureDeviceState extends DeviceState {
  final String error;

  FailureDeviceState(this.error);
}


