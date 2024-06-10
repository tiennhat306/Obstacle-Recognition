import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
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
}

final deviceServices = DeviceServices();
