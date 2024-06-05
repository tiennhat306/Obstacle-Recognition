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
}
