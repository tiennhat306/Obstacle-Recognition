import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_aid/domain/bloc/blocs.dart';
import 'package:vision_aid/presentation/components/components.dart';
import 'package:vision_aid/presentation/components/manual_market_map.dart';

class MapLocationSelectAddressScreen extends StatefulWidget {
  @override
  _MapLocationSelectAddressScreenState createState() =>
      _MapLocationSelectAddressScreenState();
}

class _MapLocationSelectAddressScreenState extends State<MapLocationSelectAddressScreen> {
  late MylocationmapBloc mylocationmapBloc;

  @override
  void initState() {
    mylocationmapBloc = BlocProvider.of<MylocationmapBloc>(context);
    mylocationmapBloc.initialLocation();
    super.initState();
  }

  @override
  void dispose() {
    mylocationmapBloc.cancelLocation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [_CreateMap(), ManualMarketMap()],
    ));
  }
}

class _CreateMap extends StatefulWidget {
  @override
  State<_CreateMap> createState() => _CreateMapState();
}

class _CreateMapState extends State<_CreateMap> {
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    final mapLocation = BlocProvider.of<MylocationmapBloc>(context);

    return BlocBuilder<MylocationmapBloc, MylocationmapState>(
        builder: (context, state) => (state.existsLocation)
            ? Stack(
              children: <Widget>[
                GoogleMap(
                    initialCameraPosition:
                        CameraPosition(target: state.location!, zoom: 18),
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    onMapCreated: (GoogleMapController controller) {
                      mapLocation.initMapLocation;
                      mapController = controller;
                    },
                    onCameraMove: (position) =>
                        mapLocation.add(OnMoveMapEvent(position.target)),
                    onCameraIdle: () {
                      if (state.locationCentral != null) {
                        mapLocation.add(OnGetAddressLocationEvent(
                            mapLocation.state.locationCentral!));
                      }
                    },
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ClipOval(
                            child: Material(
                              color: Colors.blue.shade100, // button color
                              child: InkWell(
                                splashColor: Colors.blue, // inkwell color
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.add),
                                ),
                                onTap: () {
                                  mapController.animateCamera(
                                    CameraUpdate.zoomIn(),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ClipOval(
                            child: Material(
                              color: Colors.blue.shade100, // button color
                              child: InkWell(
                                splashColor: Colors.blue, // inkwell color
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.remove),
                                ),
                                onTap: () {
                                  mapController.animateCamera(
                                    CameraUpdate.zoomOut(),
                                  );
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
              ],
            )
            : Center(
                child: const TextCustom(text: 'Locating...'),
              ));
  }
}
