import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:vision_aid/data/env/environment.dart';
import 'package:vision_aid/data/local_secure/secure_storage.dart';
import 'package:vision_aid/domain/models/response/device_all_response.dart';
import 'package:vision_aid/domain/models/response/response_default.dart';
import 'package:vision_aid/firebase/firebase_helper.dart';
import 'package:vision_aid/presentation/helpers/custom_markert.dart';

class DeviceServices {
  final FirebaseHelper _firebaseHelper = FirebaseHelper();

  Future<ResponseDefault> addNewDevice(
      String key, String username, String phone) async {
    final token = await secureStorage.readToken();

    final response = await http.post(
        Uri.parse('${Environment.endpointApi}/add-categories'),
        headers: {'Accept': 'application/json', 'xx-token': token!},
        body: {'category': username, 'description': phone});

    return ResponseDefault.fromJson(jsonDecode(response.body));
  }

  Future<List<Device>> getAllDevices() async {
    final token = await secureStorage.readToken();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('devices')
        .where('userIds', arrayContains: token)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return List<Device>.from(querySnapshot.docs.map((doc) => Device(
          id: doc.id,
          username: doc['username'],)));
    } else {
      return [];
    }
  }

  Future<List<DeviceNetwork>> getAllDevicesNetwork() async {
    final token = await secureStorage.readToken();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('devices')
        .where('userIds', arrayContains: token)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return List<DeviceNetwork>.from(querySnapshot.docs.map((doc) =>
          DeviceNetwork(deviceKey: doc['key'], username: doc['username'])));
    } else {
      return [];
    }
  }

  // update devive network by deviceKey, name, password thong qua uri:     final response = await http.get(Uri.parse('${Environment.endpointApi}/get-user-by-id'),  headers: {'Accept': 'application/json', 'xx-token': token!}); và trả về status code và message
  Future<http.Response> updateDeviceNetwork(
      String deviceKey, String ipAddress, String name, String password) async {
    final token = await secureStorage.readToken();

    final response = await http.put(
        Uri.parse('$ipAddress/change-public-wifi'),
        // headers: {'Content-Type': 'application/json'},
        // add headers content type
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},


        // body: {'deviceKey': deviceKey, 'name': name, 'password': password});
        body: jsonEncode({'deviceKey': deviceKey, 'name': name, 'password': password}));

    // return response;
    // fix FormatException: unexpected end of input (at character 1)
    return response;
  }

  Future<bool> addDevice(
      String deviceKey, String phone, String username) async {
    final token = await secureStorage.readToken();

    // await _firebaseHelper.createData('devices', {
    //   'key': deviceKey,
    //   'phone': phone,
    //   'username': username,
    //   'userIds': [token]
    // });

    print(token);

    DocumentReference docRef =
        await FirebaseFirestore.instance.collection('devices').add({
      'key': deviceKey,
      'phone': phone,
      'username': username,
      'userIds': [token]
    });

    print('added');

    print(docRef.id);

    if (docRef.id.isNotEmpty) {
      // final deviceDocumentId = querySnapshot.docs.first.id;
      //     print("doc id: ${querySnapshot.docs.first.id}");

      _firebaseHelper.updateData('users/$token', {
        'deviceIds': FieldValue.arrayUnion([docRef.id])
      });

      print('yes');

      return true;
    } else {
      return false;
    }
  }

    Future<List<String>> getHistory(String deviceId) async {

    // DocumentSnapshot documentSnapshot =
    //     await _firebaseHelper.getData('devices/$deviceId');

    // // get 'history' from documentSnapshot


    // if (documentSnapshot.exists) {
    //   Map<String, dynamic> data =
    //       documentSnapshot.data() as Map<String, dynamic>;

    //   return List<String>.from(
    //       data['history'].map((address) => ListAddress.fromJson(address)));

    // get history of deviceId of devices, then get distinct date format of datetime of history, because datetime is String type, and many datetime is same date 
    // final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    //     .collection('devices')
    //     .doc(deviceId)
    //     .collection('history')
    //     .get();

    // if (querySnapshot.docs.isNotEmpty) {
    //   // get distinct date format of datetime of history, because datetime is String type, and many datetime is same date 
    //   List<String> distinctDate = querySnapshot.docs.map((doc) => doc['datetime'].toString().substring(0, 10)).toSet().toList();
    //   // SORT DESC
    //   distinctDate.sort((a, b) => b.compareTo(a));
    //   return distinctDate;
    // } else {
    //   return [];
    // }

    DocumentSnapshot documentSnapshot =
        await _firebaseHelper.getData('devices/$deviceId');

    if (documentSnapshot.exists) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      List<String> distinctDate = List<String>.from(
          data['history'].map((doc) => doc['datetime'].toString().substring(0, 10)).toSet().toList());

      distinctDate.sort((a, b) => b.compareTo(a));

      return distinctDate;
    } else {
      return [];
    }
  }


  //   Future<void> _onMarkertDelivery(
  //     OnMarkertsDeliveryEvent event, Emitter<MapdeliveryState> emit) async {
  //   // Polylines

  //   final mapBoxResponse =
  //       await mapBoxServices.getCoordsOriginAndDestinationDelivery(
  //           event.location, event.destination);

  //   final geometry = mapBoxResponse.routes[0].geometry;

  //   final points = Polylinedo.Polyline.Decode(
  //           encodedString: geometry.toString(), precision: 6)
  //       .decodedCoords;

  //   final List<LatLng> routeCoords =
  //       points.map((p) => LatLng(p[0], p[1])).toList();

  //   _routes =
  //       this._routes.copyWith(pointsParam: routeCoords);

  //   final currentPoylines = state.polyline;
  //   currentPoylines!['routes'] =
  //       this._routes;

  //   // ------------------------ Markets

  //   final marketCustom = await getAssetImageMarker('Assets/you-are-here.png');
  //   final iconDestination = await getAssetImageMarker('Assets/device-here.png');

  //   final markerDelivery = Marker(
  //       markerId: MarkerId('markerLocation'),
  //       position: event.location,
  //       icon: marketCustom);

  //   final markerDestination = Marker(
  //       markerId: MarkerId('markerDestination'),
  //       position: event.destination,
  //       icon: iconDestination);

  //   final newMarker = {...state.markers};
  //   newMarker['markerLocation'] = markerDelivery;
  //   newMarker['markerDestination'] = markerDestination;

  //   emit(state.copyWith(polyline: currentPoylines, markers: newMarker));
  // }

  Future<List<Marker>> getDeviceHistory(String deviceId, String date) async {
    // datetime in firebare is String: 2024-04-30T07:01:57.880Z, date is String like: 2024-04-30
    // final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    //     .collection('devices')
    //     .doc(deviceId)
    //     .collection('history')
    //     .get();

    // final List<Marker> markers = [];
    // final dotIcon = await getAssetImageMarker('Assets/blue_dot.png');

    // if (querySnapshot.docs.isNotEmpty) {
    //   querySnapshot.docs.sort((a, b) => b['datetime'].compareTo(a['datetime']));

    //   querySnapshot.docs.forEach((doc) {
    //     final data = doc.data() as Map<String, dynamic>;

    //     if (data['datetime'].toString().startsWith(date)) {
    //       final marker = Marker(
    //           markerId: MarkerId(doc.id),
    //           position: LatLng(data['latitude'], data['longitude']),
    //           icon: dotIcon);

    //       markers.add(marker);
    //     }
    //   });

    // }

    // return markers;

    DocumentSnapshot documentSnapshot =
        await _firebaseHelper.getData('devices/$deviceId');

    if (documentSnapshot.exists) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      final List<Marker> markers = [];
      final dotIcon = await getAssetImageMarker('Assets/blue_dot.png');

      if (data['history'] != null) {
        data['history'].forEach((doc) {
          if (doc['datetime'].toString().startsWith(date)) {
            final marker = Marker(
                markerId: MarkerId(doc['datetime']),
                position: LatLng(doc['latitude'], doc['longitude']),
                icon: dotIcon);

            markers.add(marker);
          }
        });
      }

      return markers;
    } else {
      return [];
    }
  }

  
}

final deviceServices = DeviceServices();
