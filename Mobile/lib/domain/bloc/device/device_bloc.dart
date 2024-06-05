import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:vision_aid/domain/models/product_cart.dart';
import 'package:vision_aid/domain/models/response/addresses_response.dart';
import 'package:vision_aid/domain/services/orders_services.dart';
import 'package:vision_aid/domain/services/services.dart';
import 'package:vision_aid/domain/services/user_services.dart';
import 'package:vision_aid/main.dart';

part 'device_event.dart';
part 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  DeviceBloc() : super(DeviceState()) {
    // on<OnAddNewDeviceEvent>( _onAddNewDevice );
    // on<OnUpdateStatusOrderToDispatchedEvent>( _onUpdateStatusOrderToDispatched );
    // on<OnUpdateStatusOrderOnWayEvent>( _onUpdateStatusOrderOnWay );
    on<OnGetDeviceLocationEvent>(_onGetDeviceLocation);
    on<OnEditDeviceNetworkEvent>(_onEditDeviceNetwork);
    on<OnAddDeviceEvent>(_onAddDevice);
  }

  // Future<void> _onAddNewDevice(OnAddNewDeviceEvent event, Emitter<DeviceState> emit) async {

  //   try {

  //     // emit( LoadingOrderState() );

  //     // await Future.delayed(Duration(milliseconds: 1500));

  //     // // final resp = await ordersServices.addNewDevice(event.uidAddress, event.total, event.typePayment, event.products);

  //     // if( resp.resp ) {

  //     //   final listTokens = await userServices.getAdminsNotificationToken();

  //     //   Map<String, dynamic> data = { 'click_action' : 'FLUTTER_NOTIFICATION_CLICK' };

  //     //   await pushNotification.sendNotificationMultiple(
  //     //     listTokens,
  //     //     data,
  //     //     'Successful purchase',
  //     //     'You have a new order'
  //     //   );

  //     // //  emit( SuccessDeviceState() );

  //     // } else {
  //     //   emit( FailureDeviceState( resp.msg ) );
  //     // }

  //   } catch (e) {
  //     emit( FailureDeviceState( e.toString() ) );
  //   }

  // }

  // Future<void> _onUpdateStatusOrderToDispatched(OnUpdateStatusOrderToDispatchedEvent event, Emitter<DeviceState> emit) async {

  //   try {

  //     // emit( LoadingOrderState() );

  //     final resp = await ordersServices.updateStatusOrderToDispatched(event.idOrder, event.idDelivery);

  //     await Future.delayed(Duration(seconds: 1));

  //     if( resp.resp ){

  //       Map<String, dynamic> data = { 'click_action' : 'FLUTTER_NOTIFICATION_CLICK' };

  //       await pushNotification.sendNotification(
  //         event.notificationTokenDelivery,
  //         data,
  //         'Assigned order',
  //         'New order assigned'
  //       );

  //       // emit( SuccessDeviceState() );

  //     } else {
  //       emit( FailureDeviceState(resp.msg) );
  //     }

  //   } catch (e) {
  //     emit( FailureDeviceState(e.toString()) );
  //   }

  // }

  // Future<void> _onUpdateStatusOrderOnWay( OnUpdateStatusOrderOnWayEvent event, Emitter<DeviceState> emit ) async {

  //   try {

  //     // emit(  LoadingOrderState() );

  //     // final resp = await ordersServices.updateOrderStatusOnWay(event.idOrder, event.locationDelivery.latitude.toString(), event.locationDelivery.longitude.toString());

  //     // await Future.delayed(Duration(seconds: 1));

  //     // if( resp.resp ) emit( SuccessDeviceState() );
  //     // else emit( FailureDeviceState(resp.msg) );

  //   } catch (e) {
  //     emit( FailureDeviceState(e.toString()) );
  //   }

  // }

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
          event.deviceKey, event.name, event.password);

      Map<String, dynamic> body = jsonDecode(resp.body) as Map<String, dynamic>;

      if (resp.statusCode == 200) {
        emit(SuccessDeviceNetworkState());
      } else {
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