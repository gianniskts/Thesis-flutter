import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/model/user.dart';
import 'package:frontend/model/listing.dart';
import 'package:frontend/widgets/shop_card.dart';

class DiscoverSection extends StatelessWidget {
  final String title;
  final List<Listing> listings;
  final User? currentUser;

  const DiscoverSection(
      {super.key,
      required this.title,
      required this.listings,
      required this.currentUser});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.005),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                CupertinoButton(
                  child: const Text(
                    "Περισσότερα >",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllListingsScreen(
                          listings: listings,
                          currentUser: currentUser,
                          title: title,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                min(
                    5,
                    listings
                        .length), // Limit to 5 or the number of listings, whichever is smaller
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: ShopCard(
                    listing: listings[index],
                    email: currentUser?.email ?? '',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AllListingsScreen extends StatelessWidget {
  final List<Listing> listings;
  final User? currentUser;
  final String title;

  const AllListingsScreen({
    super.key,
    required this.listings,
    required this.currentUser,
    this.title = "All Listings",
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle:
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        border: const Border(bottom: BorderSide.none),
      ),
      child: ListView.builder(
        itemCount: listings.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ShopCard(
              listing: listings[index],
              email: currentUser?.email ?? '',
            ),
          );
        },
      ),
    );
  }
}
