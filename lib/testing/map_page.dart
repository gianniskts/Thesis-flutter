import 'dart:async';

// Flutter imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Local imports
import '../api/store_api.dart';
import '../api/user_api.dart';
import '../helpers/location_helpers.dart';
import '../model/store.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  _MapSampleState createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final String _userEmail = "jkosfp7@gmail.com";
  final UserAPI _userAPI = UserAPI("http://127.0.0.1:5000");
  final StoreAPI _storeAPI = StoreAPI("http://127.0.0.1:5000");
  LatLng? _userLocation;
  List<Store>? _nearbyStores;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  double _selectedDistance = 15.0; // default distance is 5km

  @override
  void initState() {
    super.initState();
    _fetchDataAndSetupMarkers();
  }

  Future<void> _fetchDataAndSetupMarkers() async {
    await _fetchUserLocation();
    if (_userLocation != null) {
      await _fetchAndSetNearbyStores();
    }
    setState(() {});
  }

  Future<void> _fetchUserLocation() async {
    Map<String, dynamic>? userLoc = await _userAPI.getUserLocation(_userEmail);
    _userLocation = getLatLngFromMap(userLoc);
  }

  Future<void> _fetchAndSetNearbyStores() async {
    _nearbyStores = await _storeAPI.getNearestStores(
        _userLocation!.latitude, _userLocation!.longitude, 15000);

    for (Store store in _nearbyStores!) {
      Map<String, dynamic>? storeLoc =
          await _storeAPI.getStoreLocation(store.id);
      LatLng? storeCoordinates = getLatLngFromMap(storeLoc);
      if (storeCoordinates != null) {
        _circles.add(Circle(
          circleId: CircleId(store.id),
          center: storeCoordinates,
          radius: 50.0, // Adjust this value to your needs
          fillColor: CupertinoColors.activeGreen,
          strokeColor: CupertinoColors.activeGreen,
        ));
      }
    }
    _addUserMarker();
  }

  void _addUserMarker() {
    _markers.add(Marker(
      markerId: const MarkerId("user"),
      position: _userLocation!,
      infoWindow: const InfoWindow(title: "Your Location"),
      icon:
          BitmapDescriptor.defaultMarker, // Replace with custom icon if needed
    ));
  }

  Future<void> _updateMapZoom() async {
    double zoomLevel = 15 - ( _selectedDistance);
    if (_controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _userLocation!, zoom: zoomLevel),
      ));
    }
  }

  Future<void> _useCurrentLocation() async {
    // Logic to fetch and set the user's current location and update the map
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Choose a location to see what's available"),
      ),
      child: Stack(
        children: [
          _userLocation != null
              ? GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: _userLocation!,
                    zoom: 15.0,
                  ),
                  markers: _markers,
                  circles: _circles,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                )
              : const Center(child: CircularProgressIndicator()),

          // This Positioned contains both the distance selector and the button
          Align(
            alignment: Alignment.bottomCenter,
            // bottom: 30.0,
            // left: 20.0,
            // right: 20.0,
            // width: MediaQuery.of(context).size.width ,
            child: Container(
              // padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.2),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      "Select a distance: ${_selectedDistance.toStringAsFixed(1)} km"),
                  CupertinoSlider(
                    value: _selectedDistance,
                    onChanged: (double value) {
                      setState(() {
                        _selectedDistance = value;
                        _updateMapZoom();
                      });
                    },
                    min: 1.0,
                    max: 20.0,
                  ),
                  const SizedBox(height: 10.0),
                  CupertinoButton.filled(
                    onPressed: () {
                      _useCurrentLocation();
                    },
                    child: const Text("Use my current location"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
