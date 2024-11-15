import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../model/favorites_provider.dart';
import '../../widgets/shop_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  FavoritesPageState createState() => FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, child) {
        // Check if the user is logged in and favorites are loaded
        if (provider.currentUser == null || provider.favoriteListings == null) {
          return const Center(child: CupertinoActivityIndicator());
        }

        // Check if the favoriteListings list is empty
        if (provider.favoriteListings!.isEmpty) {
          return _buildNoFavoritesView(context);
        }

        // Existing code to display favorites
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text(
                  'Αγαπημένα',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.favoriteListings!.length,
                    itemBuilder: (context, index) {
                      return ShopCard(
                        listing: provider.favoriteListings![index],
                        email: provider.currentUser!.email,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoFavoritesView(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Δεν έχεις αγαπημένα γεύματα ακόμα',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Icon(
              CupertinoIcons.heart_fill,
              size: 100,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemRed, context),
            ),
            const SizedBox(height: 20),
            const Text(
              'Πρόσθεσε γεύματα στα αγαπημένα σου για να τα βρίσκεις εύκολα εδώ',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 40),
            CupertinoButton(
              color: const Color(0xFF03605f),
              borderRadius: BorderRadius.circular(30.0),
              onPressed: () {
                navigatorKey.currentState
                    ?.pushReplacementNamed(HomePage.routeName);
              },
              child: const Text('Ανακάλυψε γεύματα',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
