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
import 'package:vision_aid/domain/services/user_services.dart';
import 'package:vision_aid/presentation/components/components.dart';
import 'package:vision_aid/presentation/helpers/helpers.dart';
import 'package:vision_aid/presentation/screens/client/home_screen.dart';
import 'package:vision_aid/presentation/screens/client/select_addreess_screen.dart';
import 'package:vision_aid/presentation/themes/colors.dart';
import 'dart:math' show cos, sqrt, asin;

class MapScreen extends StatefulWidget {
  final String deviceId;

  final ListAddress sourceLocation;

  bool isUsingDefaultLocation = true;

  LatLng _currentPosition = LatLng(0, 0);

  MapScreen({required this.deviceId, required this.sourceLocation});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  late MylocationmapBloc mylocationmapBloc;
  late MapdeliveryBloc mapDeliveryBloc;

  late GoogleMapController mapController;

  // final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        widget._currentPosition = LatLng(position.latitude, position.longitude);
      });
      // await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

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
    final deviceBloc = BlocProvider.of<DeviceBloc>(context);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final mapDelivery = BlocProvider.of<MapdeliveryBloc>(context);
    final myLocationDeliveryBloc = BlocProvider.of<MylocationmapBloc>(context);

    if (!widget.isUsingDefaultLocation) {
      _getCurrentLocation();
    }

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
        body: StreamBuilder<DeviceLocation>(
            stream: userServices.getDeviceLocation(widget.deviceId, deviceBloc),
            builder: (context, snapshot) {
              // return (snapshot.hasData)
              //     ? _MapDelivery(
              //         sourceLocation: widget.source,
              //         deviceLocation: snapshot.data!)
              //     : const Center(child: CircularProgressIndicator());
              return BlocBuilder<DeviceBloc, DeviceState>(
                  builder: (context, state) {
                if (state.deviceLocation!.latitude == null &&
                    state.deviceLocation!.longitude == 0) {
                  return Center(child: CircularProgressIndicator());
                }

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

                // return _MapDelivery(
                //   sourceLocation: widget.source,
                //   deviceLocation: state.deviceLocation!,
                //   isUsingDefaultLocation: MapScreen.isUsingDefaultLocation,
                // );
                mapDelivery.add(OnMarkertsDeliveryEvent(
                    widget.isUsingDefaultLocation
                        ? LatLng(widget.sourceLocation.latitude,
                            widget.sourceLocation.longitude)
                        : LatLng(widget._currentPosition.latitude,
                            widget._currentPosition.longitude),
                    LatLng(state.deviceLocation!.latitude,
                        state.deviceLocation!.longitude)));
                mapDelivery.add(OnEmitLocationDeliveryEvent(
                    state.deviceLocation!.id,
                    LatLng(state.deviceLocation!.latitude,
                        state.deviceLocation!.longitude)));

                return (state.deviceLocation!.latitude != 0 &&
                        state.deviceLocation!.longitude != 0)
                    ? Stack(
                        children: <Widget>[
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                                target: LatLng(state.deviceLocation!.latitude,
                                    state.deviceLocation!.longitude),
                                zoom: 17.5),
                            zoomControlsEnabled: false,
                            myLocationEnabled: false,
                            myLocationButtonEnabled: false,
                            onMapCreated: (GoogleMapController controller) {
                              mapDelivery.initMapDeliveryFrave;
                              mapController = controller;
                            },
                            markers: mapDelivery.state.markers.values.toSet(),
                            polylines:
                                mapDelivery.state.polyline!.values.toSet(),
                          ),
                          SafeArea(
                            child: Container(
                              margin: EdgeInsets.only(right: 10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Align(
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
                                                    state.deviceLocation!
                                                        .latitude,
                                                    state.deviceLocation!
                                                        .longitude,
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
                                  const SizedBox(height: 10.0),
                                  Align(
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
                                            child: Icon(Icons.my_location),
                                          ),
                                          onTap: () {
                                            mapController.animateCamera(
                                              CameraUpdate.newCameraPosition(
                                                CameraPosition(
                                                  target: widget
                                                          .isUsingDefaultLocation
                                                      ? LatLng(
                                                          widget.sourceLocation
                                                              .latitude,
                                                          widget.sourceLocation
                                                              .longitude)
                                                      : LatLng(
                                                          widget
                                                              ._currentPosition
                                                              .latitude,
                                                          widget
                                                              ._currentPosition
                                                              .longitude),
                                                  zoom: 18.0,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: _BtnGoogleMap(
                                          deviceLocation:
                                              state.deviceLocation!)),
                                ],
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
                          SafeArea(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20.0),
                                    ),
                                  ),
                                  width: width * 0.9,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, bottom: 10.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Tìm kiếm',
                                          style: TextStyle(fontSize: 20.0),
                                        ),
                                        SizedBox(height: 10),
                                        // TextField(
                                        //     'Vị trí của bạn',
                                        //     prefixIcon: Icon(Icons.home),
                                        //     suffixIcon: IconButton(
                                        //       icon: Icon(Icons.my_location),
                                        //       onPressed: () {
                                        //         startAddressController.text = _currentAddress;
                                        //         _startAddress = _currentAddress;
                                        //       },
                                        //     ),
                                        //     controller: startAddressController,
                                        //     focusNode: startAddressFocusNode,
                                        //     width: width,
                                        //     locationCallback: (String value) {
                                        //       setState(() {

                                        //       });
                                        //     }),
                                        Container(
                                          width: width * 0.8,
                                          child: InputDecorator(
                                            decoration: InputDecoration(
                                              prefixIcon: IconButton(
                                                icon: Icon(Icons.home),
                                                onPressed: () {
                                                  _getCurrentLocation();
                                                  setState(() {
                                                    widget.isUsingDefaultLocation =
                                                        !widget
                                                            .isUsingDefaultLocation;
                                                    mapController.animateCamera(
                                                      CameraUpdate
                                                          .newCameraPosition(
                                                        CameraPosition(
                                                          target: widget
                                                                  .isUsingDefaultLocation
                                                              ? LatLng(
                                                                  widget.sourceLocation
                                                                      .latitude,
                                                                  widget
                                                                      .sourceLocation
                                                                      .longitude)
                                                              : LatLng(
                                                                  widget
                                                                      ._currentPosition
                                                                      .latitude,
                                                                  widget
                                                                      ._currentPosition
                                                                      .longitude),
                                                          zoom: 18.0,
                                                        ),
                                                      ),
                                                    );
                                                  });
                                                },
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(Icons.my_location),
                                                onPressed: () {
                                                  // Navigator.pop(context);
                                                  Navigator.push(
                                                      context,
                                                      routeCustom(
                                                          page:
                                                              SelectAddressScreen()));
                                                },
                                              ),
                                              labelText: 'Vị trí của bạn',
                                              filled: true,
                                              fillColor: Colors.white,
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0),
                                                ),
                                                borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                  width: 2,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0),
                                                ),
                                                borderSide: BorderSide(
                                                  color: Colors.blue.shade300,
                                                  width: 2,
                                                ),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.all(15),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 20,
                            child: _InformationBottom(
                                sourceLocation: widget.sourceLocation,
                                deviceLocation: state.deviceLocation!),
                          )
                        ],
                      )
                    : Center(
                        child: const TextCustom(text: 'Locating...'),
                      );
              });
            }));
  }
}

class _InformationBottom extends StatefulWidget {
  final ListAddress sourceLocation;
  final DeviceLocation deviceLocation;

  const _InformationBottom(
      {required this.sourceLocation, required this.deviceLocation});

  @override
  State<_InformationBottom> createState() => _InformationBottomState();
}

class _InformationBottomState extends State<_InformationBottom>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    // final orderBloc = BlocProvider.of<OrdersBloc>(context);
    final mapDelivery = BlocProvider.of<MapdeliveryBloc>(context);

    return Container(
      padding: EdgeInsets.all(15.0),
      // height: 250,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(.5),
                blurRadius: 7,
                spreadRadius: 5)
          ]),
      child: Column(
        children: [
          // Row(
          //   children: [
          //     const Icon(Icons.location_on_outlined,
          //         size: 28, color: Colors.black87),
          //     const SizedBox(width: 15.0),
          //     Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         const TextCustom(
          //             text: 'Địa chỉ người thân',
          //             fontSize: 15,
          //             color: Colors.grey),
          //         TextCustom(
          //             text: widget.deviceLocation.street ?? 'Địa chỉ không xác định',
          //             fontSize: 16,
          //             maxLine: 2),
          //       ],
          //     )
          //   ],
          // ),
          // const Divider(),
          Row(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: NetworkImage(
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRyIM6brqOLPZGLT6RXr0Sxlg0p7BtrocUKsSBMmp9cQA&s"))),
              ),
              const SizedBox(width: 10.0),
              TextCustom(text: widget.deviceLocation.username),
              const Spacer(),
              InkWell(
                onTap: () async => await urlLauncherFrave
                    .makePhoneCall('tel:${widget.deviceLocation.phone}'),
                child: Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[200]),
                  child:
                      const Icon(Icons.phone, color: ColorsEnum.primaryColor),
                ),
              )
            ],
          ),
          const SizedBox(height: 10.0),
          BlocBuilder<MylocationmapBloc, MylocationmapState>(
            builder: (context, state) => TextCustom(
                text:
                    'Khoảng cách: ${_calculateDistance(mapDelivery.state.polyline!['routes']!.points)}',
                fontSize: 16,
                color: ColorsEnum.primaryColor,
                fontWeight: FontWeight.w500,
                maxLine: 2),
            // Text(
            //   'Khoảng cách: ${_calculateDistance(mapDelivery.state.polyline!['routes']!.points)}',
            //   style: const TextStyle(
            //       fontWeight: FontWeight.w500, color: ColorsEnum.primaryColor, ),
            // ),
          )
        ],
      ),
    );
  }

  // // hàm tính khoảng cách giữa 2 điểm
  // double calculateDistance(LatLng start, LatLng end) {
  //   return Geolocator.distanceBetween(
  //       start.latitude, start.longitude, end.latitude, end.longitude);
  // }

  String _calculateDistance(List<LatLng> polylineCoordinates) {
    try {
      double totalDistance = 0.0;
      if (polylineCoordinates.isEmpty) return 'Không xác định được khoảng cách';
      // print('Khoảng cách: ${polylineCoordinates.length}');

      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
      }

      // setState(() {
      //   _placeDistance = totalDistance.toStringAsFixed(2);
      //   print('Khoảng cách: $_placeDistance km');
      // });

      if (totalDistance < 1) {
        // print('Khoảng cách: ${(totalDistance * 1000).toStringAsFixed(2)} m');
        return '${(totalDistance * 1000).toStringAsFixed(2)} m';
      } else {
        // print('Khoảng cách: ${totalDistance.toStringAsFixed(2)} km');
        return '${totalDistance.toStringAsFixed(2)} km';
      }
    } catch (e) {
      print(e);
    }
    return 'Không xác định được khoảng cách';
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}

// class _MapDelivery extends StatefulWidget {
//   ListAddress sourceLocation;
//   DeviceLocation deviceLocation;

//   bool isUsingDefaultLocation;

//   LatLng _currentPosition = LatLng(0, 0);

//   _MapDelivery(
//       {required this.sourceLocation,
//       required this.deviceLocation, required this.isUsingDefaultLocation});

//   @override
//   State<_MapDelivery> createState() => _MapDeliveryState();
// }

// class _MapDeliveryState extends State<_MapDelivery> with WidgetsBindingObserver {
//   late GoogleMapController mapController;

//   // final _scaffoldKey = GlobalKey<ScaffoldState>();

//   // Method for retrieving the current location
//   _getCurrentLocation() async {
//     await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
//         .then((Position position) async {
//       setState(() {
//         widget._currentPosition = LatLng(position.latitude, position.longitude);
//       });
//       // await _getAddress();
//     }).catchError((e) {
//       print(e);
//     });
//   }

//   // // Method for retrieving the address
//   // _getAddress() async {
//   //   try {
//   //     List<Placemark> p = await placemarkFromCoordinates(
//   //         _currentPosition.latitude, _currentPosition.longitude);

//   //     Placemark place = p[0];

//   //     setState(() {
//   //       _currentAddress =
//   //           "${place.name}, ${place.locality}, ${place.country}";
//   //       startAddressController.text = _currentAddress;
//   //       _startAddress = _currentAddress;
//   //     });
//   //   } catch (e) {
//   //     print(e);
//   //   }
//   // }

//   // Create the polylines for showing the route between two places
//   // _createPolylines(
//   //   double startLatitude,
//   //   double startLongitude,
//   //   double destinationLatitude,
//   //   double destinationLongitude,
//   // ) async {
//   //   polylinePoints = PolylinePoints();
//   //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//   //     'AIzaSyCkhj2ULflBLvbTY8UNE-TcBlgx1ysA8XM', // Google Maps API Key
//   //     PointLatLng(startLatitude, startLongitude),
//   //     PointLatLng(destinationLatitude, destinationLongitude),
//   //     travelMode: TravelMode.transit,
//   //   );

//   //   if (result.points.isNotEmpty) {
//   //     result.points.forEach((PointLatLng point) {
//   //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//   //     });
//   //   }
//   //   PolylineId id = PolylineId('poly');
//   //   Polyline polyline = Polyline(
//   //     polylineId: id,
//   //     color: Colors.red,
//   //     points: polylineCoordinates,
//   //     width: 3,
//   //   );
//   //   polylines[id] = polyline;
//   // }

//   @override
//   Widget build(BuildContext context) {
//     var height = MediaQuery.of(context).size.height;
//     var width = MediaQuery.of(context).size.width;
//     final mapDelivery = BlocProvider.of<MapdeliveryBloc>(context);
//     final myLocationDeliveryBloc = BlocProvider.of<MylocationmapBloc>(context);

//     if (!widget.isUsingDefaultLocation) {
//       _getCurrentLocation();
//     }

//     return BlocBuilder<MylocationmapBloc, MylocationmapState>(
//         builder: (_, state) {
//       mapDelivery.add(OnMarkertsDeliveryEvent(
//           MapScreen.isUsingDefaultLocation
//               ? LatLng(widget.sourceLocation.latitude,
//                   widget.sourceLocation.longitude)
//               : LatLng(widget._currentPosition.latitude,
//                   widget._currentPosition.longitude),
//           LatLng(state.deviceLocation!.latitude,
//               state.deviceLocation!.longitude)));
//       mapDelivery.add(OnEmitLocationDeliveryEvent(
//           state.deviceLocation!.id,
//           LatLng(state.deviceLocation!.latitude,
//               state.deviceLocation!.longitude)));

//       return (state.deviceLocation!.latitude != 0 &&
//               state.deviceLocation!.longitude != 0)
//           ? Stack(
//               children: <Widget>[
//                 GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                       target: LatLng(state.deviceLocation!.latitude,
//                           state.deviceLocation!.longitude),
//                       zoom: 17.5),
//                   zoomControlsEnabled: false,
//                   myLocationEnabled: false,
//                   myLocationButtonEnabled: false,
//                   onMapCreated: (GoogleMapController controller) {
//                     mapDelivery.initMapDeliveryFrave;
//                     mapController = controller;
//                   },
//                   markers: mapDelivery.state.markers.values.toSet(),
//                   polylines: mapDelivery.state.polyline!.values.toSet(),
//                 ),
//                 SafeArea(
//                   child: Container(
//                     margin: EdgeInsets.only(right: 10.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: ClipOval(
//                             child: Material(
//                               color: Colors.white, // button color
//                               child: InkWell(
//                                 splashColor: Colors.white, // inkwell color
//                                 child: SizedBox(
//                                   width: 50,
//                                   height: 50,
//                                   child: Icon(Icons.people),
//                                 ),
//                                 onTap: () {
//                                   mapController.animateCamera(
//                                     CameraUpdate.newCameraPosition(
//                                       CameraPosition(
//                                         target: LatLng(
//                                           state.deviceLocation!.latitude,
//                                           state.deviceLocation!.longitude,
//                                         ),
//                                         zoom: 18.0,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10.0),
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: ClipOval(
//                             child: Material(
//                               color: Colors.white, // button color
//                               child: InkWell(
//                                 splashColor: Colors.white, // inkwell color
//                                 child: SizedBox(
//                                   width: 50,
//                                   height: 50,
//                                   child: Icon(Icons.my_location),
//                                 ),
//                                 onTap: () {
//                                   mapController.animateCamera(
//                                     CameraUpdate.newCameraPosition(
//                                       CameraPosition(
//                                         target: MapScreen.isUsingDefaultLocation
//                                             ? LatLng(
//                                                 widget.sourceLocation.latitude,
//                                                 widget.sourceLocation.longitude)
//                                             : LatLng(
//                                                 widget
//                                                     ._currentPosition.latitude,
//                                                 widget._currentPosition
//                                                     .longitude),
//                                         zoom: 18.0,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10.0),
//                         Align(
//                             alignment: Alignment.centerRight,
//                             child: _BtnGoogleMap(
//                                 deviceLocation: state.deviceLocation!)),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 10.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         ClipOval(
//                           child: Material(
//                             color: Colors.blue.shade100,
//                             child: InkWell(
//                               splashColor: Colors.blue,
//                               child: SizedBox(
//                                 width: 50,
//                                 height: 50,
//                                 child: Icon(Icons.add),
//                               ),
//                               onTap: () {
//                                 mapController.animateCamera(
//                                   CameraUpdate.zoomIn(),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                         ClipOval(
//                           child: Material(
//                             color: Colors.blue.shade100, // button color
//                             child: InkWell(
//                               splashColor: Colors.blue, // inkwell color
//                               child: SizedBox(
//                                 width: 50,
//                                 height: 50,
//                                 child: Icon(Icons.remove),
//                               ),
//                               onTap: () {
//                                 mapController.animateCamera(
//                                   CameraUpdate.zoomOut(),
//                                 );
//                               },
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//                 SafeArea(
//                   child: Align(
//                     alignment: Alignment.topCenter,
//                     child: Padding(
//                       padding: const EdgeInsets.only(top: 10.0),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white70,
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(20.0),
//                           ),
//                         ),
//                         width: width * 0.9,
//                         child: Padding(
//                           padding:
//                               const EdgeInsets.only(top: 10.0, bottom: 10.0),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: <Widget>[
//                               Text(
//                                 'Tìm kiếm',
//                                 style: TextStyle(fontSize: 20.0),
//                               ),
//                               SizedBox(height: 10),
//                               // TextField(
//                               //     'Vị trí của bạn',
//                               //     prefixIcon: Icon(Icons.home),
//                               //     suffixIcon: IconButton(
//                               //       icon: Icon(Icons.my_location),
//                               //       onPressed: () {
//                               //         startAddressController.text = _currentAddress;
//                               //         _startAddress = _currentAddress;
//                               //       },
//                               //     ),
//                               //     controller: startAddressController,
//                               //     focusNode: startAddressFocusNode,
//                               //     width: width,
//                               //     locationCallback: (String value) {
//                               //       setState(() {

//                               //       });
//                               //     }),
//                               Container(
//                                 width: width * 0.8,
//                                 child: InputDecorator(
//                                   decoration: InputDecoration(
//                                     prefixIcon: IconButton(
//                                       icon: Icon(Icons.home),
//                                       onPressed: () {
//                                         _getCurrentLocation();
//                                         setState(() {
//                                           // MapScreen.isUsingDefaultLocation = !MapScreen.isUsingDefaultLocation;
//                                           MapScreen.setIsUsingDefaultLocation =
//                                               !MapScreen.isUsingDefaultLocation;
//                                           widget.isUsingDefaultLocation = !widget.isUsingDefaultLocation;
//                                           mapController.animateCamera(
//                                             CameraUpdate.newCameraPosition(
//                                               CameraPosition(
//                                                 target: widget.isUsingDefaultLocation
//                                                     ? LatLng(widget.sourceLocation.latitude,
//                                                         widget.sourceLocation.longitude)
//                                                     : LatLng(widget._currentPosition.latitude, widget._currentPosition.longitude),
//                                                 zoom: 18.0,
//                                               ),
//                                             ),
//                                           );
//                                         });
//                                       },
//                                     ),
//                                     suffixIcon: IconButton(
//                                       icon: Icon(Icons.my_location),
//                                       onPressed: () {
//                                         // Navigator.pop(context);
//                                         Navigator.push(
//                                             context,
//                                             routeFrave(
//                                                 page: SelectAddressScreen()));
//                                       },
//                                     ),
//                                     labelText: 'Vị trí của bạn',
//                                     filled: true,
//                                     fillColor: Colors.white,
//                                     enabledBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.all(
//                                         Radius.circular(10.0),
//                                       ),
//                                       borderSide: BorderSide(
//                                         color: Colors.grey.shade400,
//                                         width: 2,
//                                       ),
//                                     ),
//                                     focusedBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.all(
//                                         Radius.circular(10.0),
//                                       ),
//                                       borderSide: BorderSide(
//                                         color: Colors.blue.shade300,
//                                         width: 2,
//                                       ),
//                                     ),
//                                     contentPadding: EdgeInsets.all(15),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   left: 20,
//                   right: 20,
//                   bottom: 20,
//                   child: _InformationBottom(
//                       sourceLocation: widget.sourceLocation,
//                       deviceLocation: state.deviceLocation!),
//                 )
//               ],
//             )
//           : Center(
//               child: const TextCustom(text: 'Locating...'),
//             );
//     });

//   }
// }

class _BtnGoogleMap extends StatelessWidget {
  final DeviceLocation deviceLocation;

  const _BtnGoogleMap({required this.deviceLocation});

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.only(right: 10.0),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(color: Colors.grey[300]!, blurRadius: 10, spreadRadius: -5)
      ]),
      child: CircleAvatar(
          backgroundColor: Colors.white,
          maxRadius: 25,
          child: InkWell(
              onTap: () async => await urlLauncherFrave.openMapLaunch(
                  deviceLocation.latitude.toString(),
                  deviceLocation.longitude.toString()),
              child: Image.asset('Assets/google-map.png', height: 30))),
    );
  }
}
