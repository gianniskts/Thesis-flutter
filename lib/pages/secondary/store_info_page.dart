import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../model/store.dart';

class StoreInfoPage extends StatefulWidget {
  final Store store;
  final int distance;

  const StoreInfoPage({super.key, required this.store, this.distance = -1});

  @override
  StoreInfoPageState createState() => StoreInfoPageState();
}

class StoreInfoPageState extends State<StoreInfoPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late LatLng _storeLocation;
  final Set<Marker> _markers = {};

  static const double _defaultPadding = 16.0;
  static const double _defaultSizedBoxHeight = 20.0;

  @override
  void initState() {
    super.initState();
    _setupStoreLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setupStoreLocation() {
    _storeLocation = LatLng(
      widget.store.location['coordinates'][1],
      widget.store.location['coordinates'][0],
    );
    _markers.add(
      Marker(
        markerId: MarkerId(widget.store.id),
        position: _storeLocation,
        infoWindow: InfoWindow(title: widget.store.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: const Color(0xFFfbfaf6),
        borderRadius: BorderRadius.circular(30.0), // rounded edges
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            delegate: _MapHeaderDelegate(
              minHeight: MediaQuery.of(context).size.height / 3,
              maxHeight: MediaQuery.of(context).size.height / 3,
              child: _buildGoogleMap(context),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: _defaultSizedBoxHeight),
                _buildStoreProfile(),
                const Divider(height: _defaultSizedBoxHeight, thickness: 1.0),
                _buildAddressRow(),
                const Divider(height: _defaultSizedBoxHeight, thickness: 1.0),
                _buildAboutSection(),
                const Divider(height: _defaultSizedBoxHeight, thickness: 1.0),
                _buildContactSection(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context) => Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0)),
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: GoogleMap(
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                compassEnabled: false,
                zoomControlsEnabled: true,
                onTap: (argument) {
                  _openLocation();
                },
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                initialCameraPosition:
                    CameraPosition(target: _storeLocation, zoom: 14),
                markers: _markers,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: const Icon(CupertinoIcons.xmark,
                        color: CupertinoColors.white)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      );

  Widget _buildStoreProfile() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: _defaultPadding),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF03605f),
                borderRadius: BorderRadius.circular(50.0),
                border: Border.all(color: const Color(0xFF03605f), width: 0.5),
              ),
              child: CircleAvatar(
                minRadius: 10,
                maxRadius: 40,
                backgroundImage: NetworkImage(widget.store.imageProfileUrl),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.store.name,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (widget.distance != -1)
                    Text('${widget.distance} m',
                        style: const TextStyle(
                            color: CupertinoColors.inactiveGray,
                            fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildAddressRow() => CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: _defaultPadding),
        onPressed: _openLocation,
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.location,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(width: 12.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.store.address,
                    style: const TextStyle(
                        color: Color(0xFF03605f), fontSize: 16)),
                const Text(
                  "Πάτησε εδώ για να δεις την διαδρομή",
                  style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontWeight: FontWeight.w300,
                      fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildAboutSection() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: _defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Σχετικά',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text(widget.store.about),
          ],
        ),
      );

  Widget _buildContactSection() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: _defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Πληροφορίες",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _contactRow(CupertinoIcons.info, 'VAT no:', widget.store.vat),
            _contactRow(CupertinoIcons.envelope, '', widget.store.email),
            _contactRow(CupertinoIcons.phone, '', widget.store.phone),
            _websiteRow(widget.store.website),
          ],
        ),
      );

  void _openLocation() async {
    Uri url = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: 'maps/search/',
      queryParameters: {
        'api': '1',
        'query': '${_storeLocation.latitude},${_storeLocation.longitude}',
      },
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text('Error'),
              content: const Text('Unable to open the URL.'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
      }
    }
  }

  Widget _contactRow(IconData icon, String? label, String? value) {
    if (value?.isEmpty ?? true) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF03605f)),
          const SizedBox(width: 8.0),
          Text('$label $value'),
        ],
      ),
    );
  }

  Widget _websiteRow(String? website) {
    if (website?.isEmpty ?? true) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () async {
        if (await canLaunchUrlString(website)) {
          await launchUrlString(website);
        } else {
          if (mounted) {
            showCupertinoDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: const Text('Error'),
                  content: const Text('Unable to open the URL.'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              },
            );
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          children: [
            const Icon(CupertinoIcons.link, color: Color(0xFF03605f)),
            const SizedBox(width: 8.0),
            Text(website!, style: const TextStyle(color: Color(0xFF03605f))),
          ],
        ),
      ),
    );
  }
}

class _MapHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _MapHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_MapHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
