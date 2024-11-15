import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/helpers/shared_preferences_service.dart';
import 'package:geolocator/geolocator.dart';

import '../api/user_api.dart';
import '../helpers/location_helpers.dart';

class TopBar extends StatefulWidget {
  final bool showFilters;
  final Function(String) onSearch;
  final VoidCallback? onFilterPressed;

  const TopBar(
      {super.key,
      required this.showFilters,
      required this.onSearch,
      this.onFilterPressed});

  @override
  TopBarState createState() => TopBarState();
}

class TopBarState extends State<TopBar> {
  final TextStyle _addressTextStyle =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
  String address = "";
  String realAdress = "";
  LocationService locationService = LocationService();
  final TextEditingController _searchController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String?>>(
      future: Future.wait([
        SharedPreferencesService.getUserAddress(),
        SharedPreferencesService.getRealUserAddress(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoActivityIndicator();
        }

        address = _formatAddress(snapshot.data?[0] ?? "Address not set");
        realAdress = _formatAddress(snapshot.data?[1] ?? "Address not set");

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddressRow(address),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: widget.showFilters
                        ? const EdgeInsets.only(bottom: 8.0)
                        : const EdgeInsets.only(right: 16.0, bottom: 8.0),
                    child: CupertinoSearchTextField(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                            color: CupertinoColors.lightBackgroundGray),
                        color: CupertinoColors.white,
                      ),
                      padding: const EdgeInsets.all(10),
                      prefixInsets: const EdgeInsets.only(left: 20),
                      placeholder: 'Ψάξε για κατάστημα ή προϊόν',
                      controller: _searchController,
                      onSubmitted: widget.onSearch,
                      onSuffixTap: () {
                        _searchController.clear();
                        widget.onSearch("");
                      },
                    ),
                  ),
                ),
                if (widget.showFilters)
                  CupertinoButton(
                      padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                      onPressed: widget.onFilterPressed,
                      child: const Icon(CupertinoIcons.slider_horizontal_3)),
              ],
            ),
          ],
        );
      },
    );
  }

  // Helper methods
  String _formatAddress(String address) {
    List<String> components = address.split(',');
    if (components.length >= 2) {
      return '${components[0].trim()}, ${components[1].trim()}';
    }
    return address;
  }

  void _storeSearchAddress(String address) async {
    await SharedPreferencesService.storeRecentAddress(address);
    await SharedPreferencesService.storeUserAddress(address);

    setState(() {
      this.address = address;
    });
  }

  // Widget builders
  Widget _buildAddressRow(String address) {
    return CupertinoButton(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          const Icon(CupertinoIcons.location_fill, size: 16),
          const SizedBox(width: 10),
          Text(address,
              style: _addressTextStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1),
          const SizedBox(width: 5),
          const Icon(CupertinoIcons.chevron_down, size: 16),
        ],
      ),
      onPressed: () => _showLocationPicker(context),
    );
  }

  // UI Modals & Interaction methods
  void _showLocationPicker(BuildContext context) {
    showCupertinoModalPopup(
        useRootNavigator: false,
        context: context,
        builder: (BuildContext bc) {
          return CupertinoPopupSurface(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Διευθύνσεις",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.xmark,
                            color: CupertinoColors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  CupertinoSearchTextField(
                    padding: const EdgeInsets.all(20),
                    prefixInsets: const EdgeInsets.only(left: 20),
                    borderRadius: BorderRadius.circular(20),
                    placeholder: 'Ψάξε για διεύθυνση',
                    onSubmitted: (value) {
                      _storeSearchAddress(value);
                    },
                  ),

                  const SizedBox(height: 10),
                  const Text("Κοντά σου",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  // CupertinoListTile might be a custom widget. If you face issues, replace it with the standard ListTile or other appropriate widget.
                  CupertinoListTile(
                      leading: const Icon(CupertinoIcons.location_fill),
                      title: Text(realAdress, style: _addressTextStyle),
                      onTap: () async {
                        LocationPermission permission =
                            await locationService.checkAndRequestPermission();
                        if (permission != LocationPermission.whileInUse &&
                            permission != LocationPermission.always) {
                          return;
                        }

                        // Fetch the current position of the user.
                        Position? position =
                            await locationService.getCurrentPosition();
                        if (position == null) {
                          // Handle error, maybe show a message to the user
                          return;
                        }

                        UserAPI userAPI = UserAPI('localhost:5000');
                        String realAdress = await userAPI.getAddressFromLatLng(
                            position.latitude, position.longitude);

                        SharedPreferencesService.storeRealUserAddress(
                            realAdress);
                        SharedPreferencesService.storeUserAddress(realAdress);
                        setState(() {
                          address = realAdress;
                        });
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      }),

                  const Text("Πρόσφατες αναζητήσεις",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  FutureBuilder<List<String>>(
                    future: SharedPreferencesService.getRecentAddresses(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CupertinoActivityIndicator();
                      }
                      List<String> recentAddresses = snapshot.data ?? [];

                      return Column(
                        children: recentAddresses.map((addr) {
                          return addr == ""
                              ? const Text("")
                              : CupertinoListTile(
                                  leading:
                                      const Icon(CupertinoIcons.location_solid),
                                  title: Text(addr),
                                  trailing:
                                      const Icon(CupertinoIcons.chevron_right),
                                  onTap: () {
                                    // Handle tap
                                    SharedPreferencesService.storeUserAddress(
                                        addr);

                                    setState(() {
                                      address = address;
                                    });

                                    Navigator.pop(context);
                                  },
                                );
                        }).toList(),
                      );
                    },
                  ),

                  // ... [Add other address ListTiles here]
                ],
              ),
            ),
          );
        });
  }
}

class FilterPage extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterPage({
    super.key,
    required this.initialFilters,
    required this.onApplyFilters,
  });

  @override
  FilterPageState createState() => FilterPageState();
}

class FilterPageState extends State<FilterPage> {
  late Map<String, dynamic> selectedFilters;

  @override
  void initState() {
    super.initState();
    selectedFilters = Map.from(widget.initialFilters);
  }

  void _toggleFilter(String key) {
    setState(() {
      selectedFilters[key] = !selectedFilters[key];
    });
  }

  Widget _buildFilterButton(String text, String filterKey) {
    return CupertinoButton(
      color: selectedFilters[filterKey]
          ? const Color(0xFF03605f)
          : CupertinoColors.white,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0)),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selectedFilters[filterKey]
                ? CupertinoColors.white
                : const Color(0xFF03605f), // Conditional text color
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onPressed: () => _toggleFilter(filterKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          child: ListView(
            children: [
              _buildHeader(),
              const SizedBox(height: 16.0),
              _buildFilterSection("Collection day", ["Today", "Tomorrow"]),
              _buildFilterSection("Collection time", ["Now", "Later"]),
              _buildFilterSection(
                  "Food types", ["Meals", "Groceries", "Bread", "Other"]),
              _buildFilterSection("Diet", ["Vegan"]),
              const SizedBox(height: 32.0),
              _buildApplyButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        const Center(
          child: Text('Filters',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
        ),
        Positioned.directional(
          textDirection: Directionality.of(context),
          end: 0,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.xmark,
                color: CupertinoColors.black, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CupertinoButton(
          padding: const EdgeInsets.symmetric(
              horizontal: 4.0), // Reduced padding for the 'Clear all' button
          child: const Text("Clear all"),
          onPressed: () {
            selectedFilters.updateAll((key, value) => false);
            widget.onApplyFilters(selectedFilters);
            setState(() {});
          },
        ),
        CupertinoButton(
          padding: EdgeInsets
              .zero, // Remove padding to allow the button to fill the space
          child: Container(
            padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 64.0), // Adjust padding inside the button
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: const Color(0xFF03605f),
              boxShadow: [
                // Optional: Add shadow for a more elevated look
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'Apply',
              style: TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onPressed: () {
            widget.onApplyFilters(selectedFilters);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          childAspectRatio: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: options
              .map((option) => _buildFilterButton(option, option.toLowerCase()))
              .toList(),
        ),
      ],
    );
  }
}
