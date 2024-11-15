import 'package:flutter/material.dart';

import '../api/listing_api.dart';
import '../api/store_api.dart';
import '../model/store.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Store Listing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StoreLogin(),
    );
  }
}

class StoreLogin extends StatefulWidget {
  const StoreLogin({super.key});

  @override
  StoreLoginState createState() => StoreLoginState();
}

class StoreLoginState extends State<StoreLogin> {
  final _storeCodeController = TextEditingController();
  final _storePasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login to Store")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _storeCodeController,
              decoration: const InputDecoration(labelText: 'Store Code'),
            ),
            TextField(
              controller: _storePasswordController,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            TextButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    // Call the API to login
    try {
      final store = await StoreAPI('http://127.0.0.1:5000').loginStore(
        storeCode: _storeCodeController.text,
        storePassword: _storePasswordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CreateListingScreen(store: store),
        ),
      );
    } catch (e) {
      // Handle error (show a dialog or a toast)
      print(e);
    }
  }
}

class CreateListingScreen extends StatefulWidget {
  final Store store;

  const CreateListingScreen({super.key, required this.store});

  @override
  CreateListingScreenState createState() => CreateListingScreenState();
}

class CreateListingScreenState extends State<CreateListingScreen> {
  // Define TextEditingController for each input field...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Create Food Listing for ${widget.store.name}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Create TextField widgets for each input...
            TextButton(
              onPressed: _createListing,
              child: const Text('Create Listing'),
            ),
          ],
        ),
      ),
    );
  }

  void _createListing() async {
    // Call the API to create listing
    // Use controllers to get data
    try {
      final listing =
          await ListingApi('http://127.0.0.1:5000').createListing(
        // your parameters here...
        storeId: widget.store.id,
        category: 'Surprise Bag3',
        description: 'A surprise bag of food',
        firstPrice: 10.0,
        discountedPrice: 5.0,
        location: widget.store.location,
        quantityAvailable: 10,
        availabilityStartDate: DateTime.now(),
        availabilityEndDate: DateTime.now().add(const Duration(days: 1)),
        tags: ['Meal', 'Veg'],
      );
      // Handle success (show a dialog or navigate to another screen)
      print(listing.id);
      print(listing.category);
      print(listing);
    } catch (e) {
      // Handle error (show a dialog or a toast)
      print(e);
    }
  }
}

// Add the Store and Listing model definitions here...
