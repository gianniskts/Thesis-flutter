// Flutter imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Custom package imports
import '../api/user_api.dart';
import '../model/favorites_provider.dart';
import '../model/listing.dart';
import '../pages/secondary/listing_page.dart';

class ShopCard extends StatefulWidget {
  final Listing listing;
  final String email;

  const ShopCard({super.key, required this.listing, required this.email});

  @override
  State<ShopCard> createState() => _ShopCardState();
}

class _ShopCardState extends State<ShopCard> {
  final UserAPI userAPI = UserAPI('http://127.0.0.1:5000');

  Future<void> _toggleFavourite() async {
    final provider = Provider.of<FavoritesProvider>(context, listen: false);

    bool isCurrentlyFavorite = provider.isFavorite(widget.listing);
    if (isCurrentlyFavorite) {
      await provider.removeFavorite(
          widget.listing, widget.email, widget.listing.storeId, userAPI);
    } else {
      await provider.addFavorite(
          widget.listing, widget.email, widget.listing.storeId, userAPI);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final provider = Provider.of<FavoritesProvider>(context);
    bool isFavorite = provider.isFavorite(widget.listing);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        var currentTime = DateTime.now();
        if (currentTime.isAfter(widget.listing.availabilityEndDate)) {
          // show error message
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Text('Το γεύμα έχει εξαντληθεί'),
                content: const Text(
                    'Δεν μπορείς να παραγγείλεις αυτό το γεύμα γιατί έχει εξαντληθεί'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );

          return;
        }
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext bc) {
            return ListingPage(
                store: widget.listing.store,
                listing: widget
                    .listing); // assuming you want to display StoreInfoPage in the modal
          },
        );
      },
      child: _cupertinoCard(
        screenSize,
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildImageStack(context, screenSize, isFavorite),
            _buildDetailsSection(),
          ],
        ),
      ),
    );
  }

  /// Builds a stack containing the image, indicator, and name/avatar of the listing
  Stack _buildImageStack(
      BuildContext context, Size screenSize, bool isFavourite) {
    return Stack(
      children: [
        _buildBackgroundImage(screenSize),
        _buildLeftTopIndicator(),
        _buildBottomNameAndAvatar(screenSize),
        Align(
          alignment: Alignment.topRight,
          child: CupertinoButton(
            onPressed: _toggleFavourite,
            child: Icon(
              isFavourite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              color: isFavourite ? Colors.red : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the background image for the listing
  Container _buildBackgroundImage(Size screenSize) {
    return Container(
      alignment: Alignment.topCenter,
      height: screenSize.height * 0.1375,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        image: DecorationImage(
          image: NetworkImage(widget.listing.store.imageBackgroundUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6), BlendMode.dstATop),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
    );
  }

  /// Builds the top left indicator on the image
  Positioned _buildLeftTopIndicator() {
    return Positioned(
        left: 8,
        top: 8,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xfffefdc3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${widget.listing.quantityAvailable} διαθέσιμα',
            style: const TextStyle(
                color: Color(0xFF03605f),
                fontWeight: FontWeight.bold,
                fontSize: 12),
          ),
        ));
  }

  /// Builds the bottom section with name and avatar on the image
  Positioned _buildBottomNameAndAvatar(Size screenSize) {
    return Positioned(
      bottom: 5,
      left: 8,
      child: SizedBox(
        width: screenSize.width * 0.7,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF03605f), width: 0.5),
              ),
              child: CircleAvatar(
                minRadius: 10.0,
                maxRadius: 20.0,
                backgroundImage:
                    NetworkImage(widget.listing.store.imageProfileUrl),
                backgroundColor: const Color(0xFFfbfaf6),
                foregroundColor: const Color(0xFFfbfaf6), // NetworkImage
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.listing.store.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 1.5,
                      color: Colors.black,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats the display date
  String _formatDateForDisplay(DateTime startDateTime, DateTime endDateTime) {
    DateTime now = DateTime.now();
    String day;
    if (startDateTime.day == now.day) {
      day = 'σήμερα';
    } else if (startDateTime.day == now.add(const Duration(days: 1)).day) {
      day = 'αύριο';
    } else {
      day = '${startDateTime.day}-${startDateTime.month}-${startDateTime.year}';
    }

    String startTime =
        '${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}';
    String endTime =
        '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';

    return '$day $startTime - $endTime';
  }

  /// Builds the details section below the image
  Padding _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.listing.category,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2.5),
          Text(
              "Διαθέσιμο ${_formatDateForDisplay(widget.listing.availabilityStartDate, widget.listing.availabilityEndDate)}",
              style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 2.5),
          _buildRatingAndDistanceRow(),
        ],
      ),
    );
  }

  Row _buildRatingAndDistanceRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(CupertinoIcons.star_fill,
            color: Color(0xFF03605f), size: 14),
        const SizedBox(width: 5),
        Text(
          widget.listing.store.rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
          height: 14, // Adjust the height as needed
          width: 0.75,
          color: CupertinoColors.inactiveGray,
        ),
        Text('${widget.listing.distance} m',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const Spacer(),
        Text(
          '${widget.listing.discountedPrice.toStringAsFixed(2)} €',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF03605f),
            fontSize: 22,
          ),
        ),
      ],
    );
  }
}

/// Creates a styled Cupertino card
Widget _cupertinoCard(Size screenSize, Widget child) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20.0),
    child: Container(
      width: screenSize.width * 0.85,
      // height: screenSize.height * 0.25,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        boxShadow: [
          BoxShadow(
              color: CupertinoColors.black.withOpacity(0.2),
              offset: const Offset(0, 2),
              blurRadius: 8.0,
              spreadRadius: 1.0,
              blurStyle: BlurStyle.solid),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        child: child,
      ),
    ),
  );
}
