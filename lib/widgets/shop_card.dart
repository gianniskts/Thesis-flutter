import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
          // Show error message
          showUnavailableDialog(context);
          return;
        }
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext bc) {
            return ListingPage(
                store: widget.listing.store, listing: widget.listing);
          },
        );
      },
      child: _cupertinoCard(
        screenSize,
        Column(
          children: [
            _buildImageSection(screenSize, isFavorite),
            _buildInfoSection(),
            _buildBottomSection(screenSize),
          ],
        ),
      ),
    );
  }

  void showUnavailableDialog(BuildContext context) {
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
  }

  Widget _buildImageSection(Size screenSize, bool isFavorite) {
    return Container(
      height: screenSize.height * 0.1375,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        image: DecorationImage(
          image: NetworkImage(widget.listing.store.imageBackgroundUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: CupertinoButton(
          onPressed: _toggleFavourite,
          child: Icon(
            isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            color: isFavorite ? Colors.red : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.star_fill,
                  color: Color(0xFF03605f), size: 14),
              const SizedBox(width: 5),
              Text(
                widget.listing.store.rating.toStringAsFixed(1),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 16,
                child: VerticalDivider(
                  thickness: 1,
                  // width: 20,
                  color: Colors.grey,
                ),
              ),
              Text('${widget.listing.distance} m',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                '${widget.listing.discountedPrice.toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF03605f),
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.zero,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(Size screenSize) {
    return SizedBox(
      height: screenSize.height * 0.1375,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical:
                      10), // Adjust this value to control the size of the image
              child: AspectRatio(
                aspectRatio: 1, // Maintains the widget as a circle
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(screenSize.height * 0.1375 / 2),
                    border:
                        Border.all(color: const Color(0xFF03605f), width: 0.5),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(screenSize.height * 0.1375 / 2),
                    child: Image.network(
                      widget.listing.store.imageProfileUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    widget.listing.store.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    "Διαθέσιμο ${_formatDateForDisplay(widget.listing.availabilityStartDate, widget.listing.availabilityEndDate)}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF03605f),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.listing.quantityAvailable} διαθέσιμα',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}

Widget _cupertinoCard(Size screenSize, Widget child) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20.0),
    child: Container(
      width: screenSize.width * 0.85,
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
