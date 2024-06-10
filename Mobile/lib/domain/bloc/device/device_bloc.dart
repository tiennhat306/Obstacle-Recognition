import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:vision_aid/domain/models/response/addresses_response.dart';
import 'package:vision_aid/domain/services/services.dart';
import 'package:vision_aid/domain/services/user_services.dart';
import 'package:vision_aid/main.dart';

part 'device_event.dart';
part 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  DeviceBloc() : super(DeviceState()) {
    on<OnGetDeviceLocationEvent>(_onGetDeviceLocation);
    on<OnEditDeviceNetworkEvent>(_onEditDeviceNetwork);
    on<OnAddDeviceEvent>(_onAddDevice);
  }


  Future<void> _onGetDeviceLocation(
      OnGetDeviceLocationEvent event, Emitter<DeviceState> emit) async {
    try {
      emit(LoadingDeviceState());

      // DocumentSnapshot deviceSnapshot = await FirebaseFirestore.instance.collection('devices').doc(event.deviceId).get();
      var deviceSnapshot = event.documentSnapshot;

      if (deviceSnapshot.exists) {
        final location = deviceSnapshot.get('location');

        // final deviceLocation = LatLng(location['latitude'], location['longitude']);

        final deviceLocation = DeviceLocation.fromJson(
            event.documentSnapshot.id,
            deviceSnapshot.data() as Map<String, dynamic>);
        emit(SuccessDeviceState(deviceLocation));
      } else {
        emit(FailureDeviceState('Device not found'));
      }
    } catch (e) {
      emit(FailureDeviceState(e.toString()));
    }
  }

  Future<void> _onEditDeviceNetwork(
      OnEditDeviceNetworkEvent event, Emitter<DeviceState> emit) async {
    try {
      emit(LoadingDeviceState());

      // final resp = await ordersServices.updateOrderStatusOnWay(event.idOrder, event.locationDelivery.latitude.toString(), event.locationDelivery.longitude.toString());

      Response resp = await deviceServices.updateDeviceNetwork(
          event.deviceKey, event.ipAddress, event.name, event.password);

      if (resp.statusCode == 200) {
        emit(SuccessDeviceNetworkState());
      } else {
        Map<String, dynamic> body = jsonDecode(resp.body) as Map<String, dynamic>;
        emit(FailureDeviceState(body['message']));
      }
    } catch (e) {
      emit(FailureDeviceState(e.toString()));
    }
  }

  Future<void> _onAddDevice(OnAddDeviceEvent event, Emitter<DeviceState> emit) async {
    try {
      emit(LoadingDeviceState());

      bool resp = await deviceServices.addDevice(event.deviceKey, event.phone, event.username);

      if (resp) {
        emit(SuccessAddDeviceState());
      } else {
        emit(FailureDeviceState('Error adding device'));
      }
    } catch (e) {
      emit(FailureDeviceState(e.toString()));
    }
  }
}