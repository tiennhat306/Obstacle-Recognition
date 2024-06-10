// import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vision_aid/domain/bloc/blocs.dart';
import 'package:vision_aid/domain/models/response/addresses_response.dart';
import 'package:vision_aid/domain/services/device_services.dart';
import 'package:vision_aid/domain/services/user_services.dart';
import 'package:vision_aid/presentation/components/components.dart';
import 'package:vision_aid/presentation/helpers/helpers.dart';
import 'package:vision_aid/presentation/screens/client/home_screen.dart';
import 'package:vision_aid/presentation/screens/client/select_addreess_screen.dart';
import 'package:vision_aid/presentation/themes/colors.dart';
import 'dart:math' show cos, sqrt, asin;

class MapHistoryScreen extends StatefulWidget {
  final String deviceId;

  final String date;

  MapHistoryScreen({required this.deviceId, required this.date});

  @override
  _MapHistoryScreenState createState() => _MapHistoryScreenState();
}

class _MapHistoryScreenState extends State<MapHistoryScreen>
    with WidgetsBindingObserver {
  late MylocationmapBloc mylocationmapBloc;
  late MapdeliveryBloc mapDeliveryBloc;

  late GoogleMapController mapController;

  // final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    mylocationmapBloc = BlocProvider.of<MylocationmapBloc>(context);
    mapDeliveryBloc = BlocProvider.of<MapdeliveryBloc>(context);

    mylocationmapBloc.initialLocation();
    mapDeliveryBloc.initSocketDelivery();
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void dispose() {
    mylocationmapBloc.cancelLocation();
    mapDeliveryBloc.disconectSocket();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (!await Geolocator.isLocationServiceEnabled() ||
          !await Permission.location.isGranted) {
        Navigator.pushReplacement(context, routeCustom(page: HomeScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final mapDelivery = BlocProvider.of<MapdeliveryBloc>(context);
    final myLocationDeliveryBloc = BlocProvider.of<MylocationmapBloc>(context);

    // if (state is LoadingDeviceState) {
    //   modalLoading(context);
    // } else if (state is FailureDeviceState) {
    //   Navigator.pop(context);
    //   errorMessageSnack(context, state.error);
    // } else if (state is SuccessDeviceState) {
    //   print('Success Device State');
    //   // Navigator.pop(context);
    //   // Navigator.pushReplacement(
    //   //     context, routeFrave(page: OrderDeliveredScreen()));
    //   // setState(() {
    //   //   // widget reload screen
    //   //   // deviceLocation = state.deviceLocation!;
    //   //   if (deviceLocation.latitude != state.deviceLocation!.latitude &&
    //   //       deviceLocation.longitude != state.deviceLocation!.longitude) {
    //   //     deviceLocation = state.deviceLocation!;
    //   //   }
    //   // });
    // } else {
    //   print('No state');
    //   // deviceBloc.add(OnGetDeviceLocationEvent(widget.deviceId));
    // }
    return Scaffold(
        body: FutureBuilder<List<Marker>>(
            future: deviceServices.getDeviceHistory(widget.deviceId, widget.date),
            builder: (context, snapshot) {
              // return (snapshot.hasData)
              //     ? _MapDelivery(
              //         sourceLocation: widget.source,
              //         deviceLocation: snapshot.data!)
              //     : const Center(child: CircularProgressIndicator());
  

                // var deviceLocation = snapshot.data!;
                // return BlocBuilder<MylocationmapBloc, MylocationmapState>(
                //   builder: (context, state) {
                //     return _MapDelivery(
                //       sourceLocation: widget.source,
                //       deviceLocation: state,
                //       isUsingDefaultLocation: widget.isUsingDefaultLocation,
                //     );
                //   },
                // );
                return (snapshot.hasData)
                    ? Stack(
                        children: <Widget>[
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                                target: LatLng(snapshot.data!.first.position.latitude,
                                    snapshot.data!.first.position.longitude),
                                zoom: 17.5),
                            zoomControlsEnabled: false,
                            myLocationEnabled: false,
                            myLocationButtonEnabled: false,
                            onMapCreated: (GoogleMapController controller) {
                              mapDelivery.initMapDeliveryFrave;
                              mapController = controller;
                            },
                            markers: snapshot.data!.toSet(),
                          ),
                          SafeArea(
                            child: Container(
                              margin: EdgeInsets.only(right: 10.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: ClipOval(
                                  child: Material(
                                    color: Colors.white, // button color
                                    child: InkWell(
                                      splashColor:
                                          Colors.white, // inkwell color
                                      child: SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: Icon(Icons.people),
                                      ),
                                      onTap: () {
                                        mapController.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                              target: LatLng(
                                                snapshot.data!
                                                    .first.position.latitude,
                                                snapshot.data!
                                                    .first.position.longitude,
                                              ),
                                              zoom: 18.0,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  ClipOval(
                                    child: Material(
                                      color: Colors.blue.shade100,
                                      child: InkWell(
                                        splashColor: Colors.blue,
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
                                      color:
                                          Colors.blue.shade100, // button color
                                      child: InkWell(
                                        splashColor:
                                            Colors.blue, // inkwell color
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
                      );
              }),
            );
  }
}
