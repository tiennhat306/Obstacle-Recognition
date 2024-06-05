import 'dart:convert';
import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:vision_aid/data/env/environment.dart';
import 'package:vision_aid/data/local_secure/secure_storage.dart';
import 'package:vision_aid/domain/bloc/auth/auth_bloc.dart';
import 'package:vision_aid/domain/bloc/device/device_bloc.dart';
import 'package:vision_aid/domain/models/response/addresses_response.dart';
import 'package:vision_aid/domain/models/response/response_default.dart';
import 'package:vision_aid/domain/models/response/response_login.dart';
import 'package:vision_aid/firebase/firebase_helper.dart';
import 'package:vision_aid/main.dart';

class UserServices {
  final FirebaseHelper _firebaseHelper = FirebaseHelper();

  Future<UserToken?> getUserById() async {
    final token = await secureStorage.readToken();

    // final response = await http.get(
    //     Uri.parse('${Environment.endpointApi}/get-user-by-id'),
    //     headers: {'Accept': 'application/json', 'xx-token': token!});

    // return ResponseLogin.fromJson(jsonDecode(response.body)).user;

    DocumentSnapshot documentSnapshot =
        await _firebaseHelper.getData('users/$token');

    if (documentSnapshot.exists) {
      List<dynamic> addresses = documentSnapshot.get('addresses');
      Map<String, dynamic> addressFirst = addresses.firstWhere(
          (address) => address['is_default'] == true,
          orElse: () => {});

      ListAddress? address =
          addressFirst.isNotEmpty ? ListAddress.fromJson(addressFirst) : null;

      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      return UserToken(
        uid: documentSnapshot.id,
        name: data['name'],
        phone: data['phone'],
        email: data['email'],
        image: data['image'],
        address: address
      );
    } else {
      // throw Exception('User not found');
      return null;
    }
  }

  Future<bool> editProfile(String name, String phone, String email) async {
    final token = await secureStorage.readToken();

    DocumentSnapshot documentSnapshot =
        await _firebaseHelper.getData('users/$token');

    if (documentSnapshot.exists) {
      await _firebaseHelper.updateData(
          'users/$token', {'name': name, 'phone': phone, 'email': email});
      return true;
    } else {
      return false;
    }
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    final token = await secureStorage.readToken();

    // final response = await http.put(
    //     Uri.parse('${Environment.endpointApi}/change-password'),
    //     headers: {'Accept': 'application/json', 'xx-token': token!},
    //     body: {'currentPassword': currentPassword, 'newPassword': newPassword});

    // return ResponseDefault.fromJson(jsonDecode(response.body));

    DocumentSnapshot documentSnapshot =
        await _firebaseHelper.getData('users/$token');

    if (documentSnapshot.exists) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      if (data['password'] == currentPassword) {
        await _firebaseHelper.updateData(
            'users/$token', {'password': newPassword});
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<ResponseDefault> changeImageProfile(String image) async {
    final token = await secureStorage.readToken();

    var request = http.MultipartRequest(
        'PUT', Uri.parse('${Environment.endpointApi}/change-image-profile'))
      ..headers['Accept'] = 'application/json'
      ..headers['xx-token'] = token!
      ..files.add(await http.MultipartFile.fromPath('image', image));

    final response = await request.send();
    var data = await http.Response.fromStream(response);

    return ResponseDefault.fromJson(jsonDecode(data.body));
  }

  Future<List<ListAddress>> getAddresses() async {
    final token = await secureStorage.readToken();

    // final response = await http.get(Uri.parse('${Environment.endpointApi}/get-addresses'),
    //   headers: { 'Accept' : 'application/json', 'xx-token' : token! }
    // );

    // return AddressesResponse.fromJson(jsonDecode(response.body)).listAddresses;

    DocumentSnapshot documentSnapshot =
        await _firebaseHelper.getData('users/$token');

    if (documentSnapshot.exists) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      return List<ListAddress>.from(
          data['addresses'].map((address) => ListAddress.fromJson(address)));
    } else {
      return [];
    }
  }

  Future<void> setDefaultAddress(int index) async {
    final token = await secureStorage.readToken();

    DocumentSnapshot documentSnapshot =
        await _firebaseHelper.getData('users/$token');

    if (documentSnapshot.exists) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      List<dynamic> addresses = data['addresses'];

      addresses.forEach((address) {
        address['is_default'] = false;
      });

      addresses[index]['is_default'] = true;

      await _firebaseHelper
          .updateData('users/$token', {'addresses': addresses});
    }
  }

  Stream<DeviceLocation> getDeviceLocation(
      String deviceId, DeviceBloc deviceBloc) async* {
    final token = await secureStorage.readToken();

    print('Getting device location...');

    // DocumentSnapshot documentSnapshot =
    //     await _firebaseHelper.getData('devices/$deviceId');

    // if (documentSnapshot.exists) {
    //   yield DeviceLocation.fromJson(deviceId,
    //       documentSnapshot.data() as Map<String, dynamic>);
    // } else {
    //   throw Exception('Device not found');
    // }

    FirebaseFirestore.instance
        .collection('devices')
        .doc(deviceId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        // deviceBloc.add(OnGetDeviceLocationEvent(deviceId));
        // if have changes, add event to get device location

        deviceBloc.add(OnGetDeviceLocationEvent(doc));
      }
    });

    // yield* deviceBloc.stream.map((state) {
    //   if (state is SuccessDeviceState) {
    //     return state.deviceLocation!;
    //   } else {
    //     throw Exception('Device not found');
    //   }
    // });
  }

  Future<ResponseDefault> deleteStreetAddress(String idAddress) async {
    final token = await secureStorage.readToken();

    final resp = await http.delete(
        Uri.parse(
            '${Environment.endpointApi}/delete-street-address/$idAddress'),
        headers: {'Accept': 'application/json', 'xx-token': token!});

    return ResponseDefault.fromJson(jsonDecode(resp.body));
  }

  Future<bool> addNewAddressLocation(String reference,
      double latitude, double longitude) async {
    final token = await secureStorage.readToken();

    // final resp = await http.post(
    //     Uri.parse('${Environment.endpointApi}/add-new-address'),
    //     headers: {
    //       'Accept': 'application/json',
    //       'xx-token': token!
    //     },
    //     body: {
    //       'street': street,
    //       'reference': reference,
    //       'latitude': latitude,
    //       'longitude': longitude
    //     });

    // return ResponseDefault.fromJson(jsonDecode(resp.body));

    DocumentSnapshot documentSnapshot =
        await _firebaseHelper.getData('users/$token');

    if (documentSnapshot.exists) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      List<dynamic> addresses = data['addresses'];

      addresses.add({
        'reference': reference,
        'latitude': latitude,
        'longitude': longitude,
        'is_default': false
      });

      await _firebaseHelper.updateData('users/$token', {'addresses': addresses});
      return true;
    } else {
      return false;
    }
  }
}

final userServices = UserServices();
