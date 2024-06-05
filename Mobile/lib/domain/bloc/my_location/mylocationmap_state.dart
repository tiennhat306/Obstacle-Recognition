part of 'mylocationmap_bloc.dart';

@immutable
class MylocationmapState {

  final bool existsLocation;
  final LatLng? location;
  final bool mapReady;
  final LatLng? locationCentral;
  final String street;
  final String reference;

  MylocationmapState({
    this.existsLocation = false, 
    this.location,
    this.mapReady = false,
    this.locationCentral,
    this.street = '',
    this.reference = ''
  });

  MylocationmapState copyWith({ bool? existsLocation, LatLng? location, bool? mapReady, LatLng? locationCentral, String? street, String? reference })
    => MylocationmapState(
      existsLocation: existsLocation ?? this.existsLocation,
      location: location ?? this.location,
      mapReady: mapReady ?? this.mapReady,
      locationCentral: locationCentral ?? this.locationCentral,
      street: street ?? this.street,
      reference: reference ?? this.reference
    );


}


class LoadingMyLocationState extends MylocationmapState {}

class SuccessMyLocationState extends MylocationmapState {}

class FailureMyLocationState extends MylocationmapState {
  final String error;

  FailureMyLocationState(this.error);
}
