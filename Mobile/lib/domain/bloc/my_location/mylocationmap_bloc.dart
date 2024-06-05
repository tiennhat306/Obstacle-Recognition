import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

import 'package:bloc/bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:meta/meta.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vision_aid/presentation/themes/theme_maps.dart';

part 'mylocationmap_event.dart';
part 'mylocationmap_state.dart';

class MylocationmapBloc extends Bloc<MylocationmapEvent, MylocationmapState> {
  MylocationmapBloc() : super(MylocationmapState()) {
    on<OnChangeLocationEvent>(_onChangeLocation);
    on<OnMapReadyMyLocationEvent>(_onMapReady);
    on<OnMoveMapEvent>(_onMoveMap);
    on<OnGetAddressLocationEvent>(_onGetAddressLocation);
  }

  late GoogleMapController _mapController;
  late StreamSubscription<Position> _positionSubscription;

  void initialLocation() async {
    _positionSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      add(OnChangeLocationEvent(LatLng(position.latitude, position.longitude)));
    });
  }

  void cancelLocation() {
    _positionSubscription.cancel();
  }

  void initMapLocation(GoogleMapController controller) {
    if (!state.mapReady) {
      this._mapController = controller;
      // Change Style from Map
      _mapController.setMapStyle(jsonEncode(themeMapsFrave));

      add(OnMapReadyMyLocationEvent());

      add(OnGetAddressLocationEvent(state.location!));
    }
  }

  Future<void> _onChangeLocation(
      OnChangeLocationEvent event, Emitter<MylocationmapState> emit) async {
    emit(state.copyWith(existsLocation: true, location: event.location));
  }

  Future<void> _onMapReady(
      OnMapReadyMyLocationEvent event, Emitter<MylocationmapState> emit) async {
    emit(state.copyWith(mapReady: true));
  }

  Future<void> _onMoveMap(
      OnMoveMapEvent event, Emitter<MylocationmapState> emit) async {
    emit(state.copyWith(locationCentral: event.location));
  }

  Future<void> _onGetAddressLocation(
      OnGetAddressLocationEvent event, Emitter<MylocationmapState> emit) async {
    // print('Get Address Location hehe 123');
    // final appDir =  await getApplicationDocumentsDirectory();
    // final secrets = await File('D:\\Workspace\\PBL\\PBL5\\ObstacleRecognition\\Mobile\\secrets.json').readAsString();
    // final secretsJson = jsonDecode(secrets);

    // final apiKey = secretsJson['GOOGLE_MAPS_API_KEY'];
    // print('API Key: $apiKey');

    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${event.location.latitude},${event.location.longitude}&key=AIzaSyCkhj2ULflBLvbTY8UNE-TcBlgx1ysA8XM'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final result = data['results'][0];
      final formattedAddress = result['formatted_address'];

      final streetNumber = result['address_components'].firstWhere(
        (element) => element['types'].contains('street_number') as bool,
        orElse: () => null,
      );
      final street_name = result['address_components'].firstWhere(
          (element) => element['types'].contains('route') as bool,
          orElse: () => null);
      final areaLevel2 = result['address_components'].firstWhere(
          (element) => element['types'].contains('administrative_area_level_2') as bool,
          orElse: () => null);

      String street = "";
      if (streetNumber.isNotEmpty && streetNumber['long_name'].isNotEmpty) {
        street += streetNumber['long_name'] + ' ';
      }
      if (street_name.isNotEmpty && street_name['long_name'].isNotEmpty) {
        street += street_name['long_name'] + ', ';
      }
      if (areaLevel2.isNotEmpty && areaLevel2['long_name'].isNotEmpty) {
        street += areaLevel2['long_name'];
      }

      emit(state.copyWith(
        street: street,
        reference: formattedAddress,
      ));
    } else {
      throw Exception('Failed to load address');
    }

    // List<Placemark> address = await placemarkFromCoordinates( event.location.latitude , event.location.longitude );

    // String direction = address[0].thoroughfare!;
    // String street = address[0].subThoroughfare!;
    // String city = address[0].locality!;

    // emit( state.copyWith(
    //   addressName: '$direction, #$street, $city',
    // ));

    // List<Location> locations = await locationFromAddress('${event.location.latitude}, ${event.location.longitude}');

    // if (locations.isNotEmpty) {
    //   final location = locations.first;
    //   final placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);

    //   if (placemarks.isNotEmpty) {
    //     final placemark = placemarks.first;
    //     final streetNumber = placemark.subThoroughfare;
    //     final streetName = placemark.thoroughfare;
    //     final subLocality = placemark.subLocality;
    //     final city = placemark.locality;
    //     final state1 = placemark.administrativeArea;
    //     final postalCode = placemark.postalCode;
    //     final country = placemark.country;

    //     String fullname = "";
    //     if (streetNumber != null) {
    //       fullname += '$streetNumber ';
    //     }
    //     if (streetName != null) {
    //       fullname += streetName + ', ';
    //     }
    //     if (subLocality != null) {
    //       fullname += subLocality + ', ';
    //     }
    //     if (city != null) {
    //       fullname += city + ', ';
    //     }
    //     if (state1 != null) {
    //       fullname += state1 + ' ';
    //     }
    //     if (postalCode != null) {
    //       fullname += postalCode + ', ';
    //     }
    //     if (country != null) {
    //       fullname += country;
    //     }
    //     emit(state.copyWith(
    //       addressName: fullname,
    //       // street: street,
    //       // reference: route,
    //     ));
    //   }
    // }
  }
}
