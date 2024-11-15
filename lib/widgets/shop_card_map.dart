// shop_card_big.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../model/listing.dart';
import '../pages/secondary/listing_page.dart'; // Adjust the import path as necessary

class ShopCardMap extends StatelessWidget {
  final Listing listing;

  const ShopCardMap({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
              builder: (context) =>
                  ListingPage(store: listing.store, listing: listing)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: CupertinoColors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            // Add this boxShadow property
            BoxShadow(
              color: CupertinoColors.black
                  .withOpacity(0.1), // Shadow color with opacity
              spreadRadius: 0,
              blurRadius: 4.0,
              offset: const Offset(0, 2), // Keeps the shadow only at the bottom
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xfffefdc3),
                      // width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    minRadius: 10,
                    maxRadius: 20,
                    backgroundImage: NetworkImage(
                      listing.store.imageProfileUrl,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -3,
                  right: -3,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xfffefdc3),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(listing.quantityAvailable.toString(),
                          style: const TextStyle(
                              color: Color(0xFF03605f),
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.store.name,
                    style: const TextStyle(
                        color: CupertinoColors.black,
                        fontWeight: FontWeight.w700,
                        overflow: TextOverflow.clip,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.star_fill,
                        color: Color(0xFF03605f),
                        size: 12,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        listing.store.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            color: CupertinoColors.black,
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.clip,
                            fontSize: 12),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Text("I",
                            style: TextStyle(
                              color: CupertinoColors.lightBackgroundGray,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                      Text(
                        "${listing.distance} m",
                        style: const TextStyle(
                            color: CupertinoColors.black,
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.clip,
                            fontSize: 12),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            Text(
              "${listing.discountedPrice.toStringAsFixed(2)} €",
              style: const TextStyle(
                  color: Color(0xFF03605f),
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.clip,
                  fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
