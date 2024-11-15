import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/widgets/shop_card_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../api/user_api.dart';
import '../../model/listing.dart';
import '../../model/user.dart';
import '../../widgets/shop_card.dart';
import '../../widgets/top_bar.dart';

enum ViewOption { list, map }

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  BrowsePageState createState() => BrowsePageState();
}

class BrowsePageState extends State<BrowsePage> {
  final UserAPI userAPI = UserAPI('http://127.0.0.1:5000');
  bool isLoading = true;

  User? currentUser;
  List<Listing>? listings;
  ViewOption selectedView = ViewOption.list;

  Map<String, dynamic> filters = {
    // initialize with default values
    'today': false,
    'tomorrow': false,
    'now': false,
    'later': false,
    'meals': false,
    'groceries': false,
    'bread': false,
    'other': false,
    'vegan': false,
  };

  void onApplyFilters(Map<String, dynamic> newFilters) {
    setState(() {
      filters = newFilters;
      applyFilters(); // Apply the new filters
    });
  }

  void applyFilters() {
    if (filters.values.every((value) => value == false)) {
      // If all filters are false, show all listings
      _loadData();
      return;
    }

    // Ensure listings is not null
    List<Listing> currentListings = listings ?? [];

    // Filter listings based on multiple fields
    List<Listing> filteredListings = currentListings.where((listing) {
      // Check if the current time is within the listing's availability window
      DateTime now = DateTime.now();
      bool isAvailable = listing.availabilityStartDate.isBefore(now) &&
          listing.availabilityEndDate.isAfter(now);

      // Check if the listing is within the user's preferred categories
      bool isWithinCategory = false;
      if (filters['meals'] && listing.category == 'Meals') {
        isWithinCategory = true;
      } else if (filters['groceries'] && listing.category == 'Groceries') {
        isWithinCategory = true;
      } else if (filters['bread'] && listing.category == 'Bread') {
        isWithinCategory = true;
      } else if (filters['other'] && listing.category == 'Other') {
        isWithinCategory = true;
      }

      // Check if the listing is within the user's preferred tags
      bool isWithinTags = false;
      if (filters['vegan'] && listing.tags.contains('Vegan')) {
        isWithinTags = true;
      }

      // Check if the listing is within the user's preferred time
      bool isWithinTime = false;
      if (filters['today'] && listing.availabilityStartDate.day == now.day) {
        isWithinTime = true;
      } else if (filters['tomorrow'] &&
          listing.availabilityStartDate.day == now.day + 1) {
        isWithinTime = true;
      } else if (filters['now'] &&
          listing.availabilityStartDate.isBefore(now) &&
          listing.availabilityEndDate.isAfter(now)) {
        isWithinTime = true;
      } else if (filters['later'] &&
          listing.availabilityStartDate.isAfter(now)) {
        isWithinTime = true;
      }

      return isAvailable && isWithinCategory && isWithinTags && isWithinTime;
    }).toList();

    // Update the state to show filtered listings or a message if no results
    setState(() {
      listings = filteredListings.isEmpty ? [] : filteredListings;
    });
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      _loadData(); // Reloads the original listings when search text is cleared
      return;
    }
    // Convert query to lower case for case-insensitive search
    String lowerCaseQuery = query.toLowerCase();

    // Ensure listings is not null
    List<Listing> currentListings = listings ?? [];

    // Filter listings based on multiple fields
    List<Listing> filteredListings = currentListings.where((listing) {
      return listing.store.name.toLowerCase().contains(lowerCaseQuery) ||
          listing.description.toLowerCase().contains(lowerCaseQuery) ||
          listing.category.toLowerCase().contains(lowerCaseQuery) ||
          listing.tags.any((tag) => tag.toLowerCase().contains(lowerCaseQuery));
    }).toList();

    // Update the state to show filtered listings or a message if no results
    setState(() {
      listings = filteredListings.isEmpty ? [] : filteredListings;
    });
  }

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadData().catchError((error) {
      _showErrorDialog();
    });
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('Failed to load map data. Please try again later.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true); // Start loading
    try {
      currentUser = await UserService.getUser();
      if (currentUser != null) {
        double latitude = currentUser!.location['latitude'];
        double longitude = currentUser!.location['longitude'];
        listings = await userAPI.getListingsNearby(
          longitude: longitude,
          latitude: latitude,
          maxDistance: 5000000,
          limit: 50,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load data. Please try again later.')),
      );
      }
    } finally {
      setState(() => isLoading = false); // End loading
    }
  }

  void _setMarkersFromListings() {
    if (listings == null) return;

    for (Listing listing in listings!) {
      LatLng coordinates = LatLng(listing.location['coordinates'][1],
          listing.location['coordinates'][0]);
      _markers.add(Marker(
        markerId: MarkerId(listing.id.toString()),
        position: coordinates,
        infoWindow:
            InfoWindow(title: listing.category, snippet: listing.description),
      ));
    }
  }

  Widget _buildGoogleMap() {
    setState(() {
      isLoading = true;
    });
    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    _setMarkersFromListings();

    LatLng userLocation = LatLng(
        currentUser!.location['latitude'], currentUser!.location['longitude']);

    setState(() {
      isLoading = false;
    });
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(target: userLocation, zoom: 15.0),
      markers: _markers,
      onMapCreated: (GoogleMapController controller) {
        // _controller.complete(controller);
      },
    );
  }

  Widget _buildMinimalListing() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: listings?.length ?? 0,
      itemBuilder: (context, index) {
        final listing = listings![index];
        return ShopCardMap(listing: listing);
      },
    );
  }

  void onFilterPressed() async {
    // Replace 'FilterPage' with the actual page or modal for filters
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) =>
            FilterPage(initialFilters: filters, onApplyFilters: onApplyFilters),
      ),
    );

    if (result != null) {
      onApplyFilters(result);
    } else {
      applyFilters(); // Apply the new filters
    }
  }

  bool showListingsOverlay = false;

  @override
  Widget build(BuildContext context) {
    if (isLoading || (currentUser == null)) {
      return const Center(
        child: SpinKitPulsingGrid(
          color: Color(0xFF03605f),
          size: 50.0,
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
            ),
            child: TopBar(
              showFilters: true,
              onSearch: _onSearch,
              onFilterPressed: onFilterPressed,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CupertinoSlidingSegmentedControl<ViewOption>(
                thumbColor: const Color(0xFF03605f),
                children: {
                  ViewOption.list: Text(
                    'Λίστα',
                    style: TextStyle(
                      color: selectedView == ViewOption.list
                          ? Colors.white
                          : const Color(0xFF03605f),
                    ),
                  ),
                  ViewOption.map: Text(
                    'Χάρτης',
                    style: TextStyle(
                      color: selectedView == ViewOption.map
                          ? Colors.white
                          : const Color(0xFF03605f),
                    ),
                  ),
                },
                onValueChanged: (value) {
                  setState(() {
                    selectedView = value!;
                  });
                },
                groupValue: selectedView,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: selectedView == ViewOption.list
                ? RefreshIndicator.adaptive(
                    color: const Color(0xFF03605f),
                    onRefresh: () async {
                      HapticFeedback.vibrate();
                      await _loadData();
                      // Optional: Show a completion message or animation
                    },
                    // Custom animation or progress indicator can be implemented here

                    child: ListView.builder(
                      itemCount: listings?.length ?? 0,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ShopCard(
                              listing: listings![index],
                              email: currentUser!.email),
                        );
                      },
                    ),
                  )
                : Stack(
                    children: [
                      _buildGoogleMap(),
                      _buildMinimalListing() // Minimal listings displayed below the map
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
