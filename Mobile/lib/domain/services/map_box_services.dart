import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:vision_aid/domain/models/map_box/driving_response.dart';

class MapBoxServices {

  final _url = 'https://api.mapbox.com/directions/v5';
  final _apikey = 'pk.eyJ1IjoidGllbm5oYXQzMDYiLCJhIjoiY2x1dWw4aWF3MDA5NzJqdDF1b2dzYjE1biJ9.aVfg8lEXBHxt5AznvLh0xA';


  Future<DrivingResponse> getCoordsOriginAndDestinationDelivery(LatLng origin, LatLng destination) async {

    final coordString = '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';

    final url = '$_url/mapbox/driving/$coordString';

    final resp = await http.get(Uri.parse('$url?alternatives=true&geometries=polyline6&steps=false&access_token=$_apikey&language=es'));

    return DrivingResponse.fromJson(jsonDecode(resp.body));
  }

}

final mapBoxServices = MapBoxServices();