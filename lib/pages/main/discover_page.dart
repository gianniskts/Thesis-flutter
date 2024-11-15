// pages/discover_page.dart
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../api/user_api.dart';
import '../../model/listing.dart';
import '../../model/user.dart';
import '../../widgets/discover_section.dart';
import '../../widgets/top_bar.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final UserService userService = UserService();
  final UserAPI userAPI = UserAPI('http://127.0.0.1:5000');
  bool isLoading = true;
  Timer? refreshTimer;

  User? currentUser;
  List<Listing>? listings;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    refreshTimer =
        Timer.periodic(const Duration(minutes: 2), (Timer t) => _loadData());
  }

  _loadData() async {
    setState(() {
      isLoading = true; // Start loading
    });

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

    setState(() {
      isLoading = false; // End loading
    });
  }

  List<Listing> listingsCollectNow(List<Listing> allListings) {
    DateTime now = DateTime.now();

    return allListings.where((listing) {
      // Check if the current time is within the listing's availability window
      return listing.availabilityStartDate.isBefore(now) &&
          listing.availabilityEndDate.isAfter(now);
    }).toList();
  }

  List<Listing> listingsNearby(List<Listing> allListings) {
    // Sort the listings by distance
    allListings.sort((a, b) => a.distance.compareTo(b.distance));
    return allListings;
  }

  List<Listing> listingWithMeals(List<Listing> allListings) {
    return allListings.where((listing) {
      // Check if the listing has the 'Meal' tag
      return listing.tags.contains('Meal');
    }).toList();
  }

  List<Listing> listingWithGroceries(List<Listing> allListings) {
    return allListings.where((listing) {
      // Check if the listing has the 'Groceries' tag
      return listing.tags.contains('Groceries');
    }).toList();
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

  // Add a list of categories
  final List<String> categories = [
    "Γεύμα Έκπληξη",
    "Αρτοποιήματα",
    "Πίτσα",
    "Γλυκά",
    "Σνακ"
  ];

  // Method to filter listings based on category
  List<Listing> listingsByCategory(String category) {
    return listings?.where((listing) {
          return listing.category == category;
        }).toList() ??
        [];
  }

  // Method to handle category selection
  void _onCategorySelected(String category) {
    List<Listing> filteredListings = listingsByCategory(category);
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AllListingsScreen(
          listings: filteredListings,
          currentUser: currentUser,
          title: category,
        ),
      ),
    );
  }

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

    // Define a list of colors for the categories
    final List<Color> categoryColors = [
      const Color(0xFF03605f),
      CupertinoColors.systemRed,
      CupertinoColors.systemYellow,
      CupertinoColors.systemOrange,
      CupertinoColors.systemIndigo,
    ];

    // Check if listings are empty and display a message if true
    bool isListingsEmpty = listings != null && listings!.isEmpty;

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, top: 16.0, bottom: 16.0), // Adjusted padding
          child: Column(
            children: [
              TopBar(showFilters: false, onSearch: _onSearch),
              Expanded(
                child: ListView(
                  children: [
                    if (isListingsEmpty)
                      const Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 100),
                            Icon(
                              CupertinoIcons.rectangle_fill_badge_xmark,
                              size: 100,
                            ),
                            SizedBox(height: 50),
                            Text(
                              'Αυτή την ώρα δεν βρέθηκαν αποτελέσματα κοντά σου.',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    if (!isListingsEmpty) ...[
                      // Category Selection Widgets
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.02),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(categories.length, (index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    color: categoryColors[index %
                                        categoryColors
                                            .length], // Assign color from the list
                                  ),
                                  child: CupertinoButton(
                                    child: Text(
                                      categories[index],
                                      style: const TextStyle(
                                          color: Color(0xFFfbfaf6),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () =>
                                        _onCategorySelected(categories[index]),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      DiscoverSection(
                        title: "Προτεινόμενα",
                        listings: listings ?? [],
                        currentUser: currentUser,
                      ),
                      DiscoverSection(
                        title: "Κοντά σου",
                        listings: listingsNearby(listings ?? []),
                        currentUser: currentUser,
                      ),
                      DiscoverSection(
                        title: "Σύλλεξε τώρα",
                        listings: listingsCollectNow(listings ?? []),
                        currentUser: currentUser,
                      ),
                      DiscoverSection(
                        title: "Γεύματα",
                        listings: listingWithMeals(listings ?? []),
                        currentUser: currentUser,
                      ),
                      DiscoverSection(
                        title: "Τρόφιμα",
                        listings: listingWithGroceries(listings ?? []),
                        currentUser: currentUser,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
