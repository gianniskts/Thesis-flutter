// Utility function to extract LatLng from a Map.
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

LatLng? getLatLngFromMap(Map<String, dynamic>? dataMap) {
  if (dataMap != null && dataMap.containsKey('location') && dataMap['location'].containsKey('coordinates')) {
    List<dynamic> coordinates = dataMap['location']['coordinates'];
    return LatLng(coordinates[1], coordinates[0]);
  }
  return null;
}

class LocationService {
  Future<LocationPermission> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  Future<Position?> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}
