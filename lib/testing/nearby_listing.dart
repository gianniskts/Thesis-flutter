import 'package:flutter/material.dart';
import '../api/user_api.dart';
import '../model/listing.dart';
import '../model/user.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nearby Listings',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<User?>(
        future: UserService.getUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return NearbyListingsPage(user: snapshot.data!);
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

class NearbyListingsPage extends StatefulWidget {
  final User user;

  const NearbyListingsPage({super.key, required this.user});

  @override
  _NearbyListingsPageState createState() => _NearbyListingsPageState();
}

class _NearbyListingsPageState extends State<NearbyListingsPage> {
  late Future<List<Listing>> listings;
  final UserAPI userAPI = UserAPI('http://127.0.0.1:5000');

  @override
  void initState() {
    super.initState();
    double latitude = widget.user.location['latitude'];
    double longitude = widget.user.location['longitude'];
    print(latitude);
    print(longitude);
    listings = userAPI.getListingsNearby(
      longitude: longitude,
      latitude: latitude,
      maxDistance: 5000000,
      limit: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Listings')),
      body: FutureBuilder<List<Listing>>(
        future: listings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching listings'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No listings found'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final listing = snapshot.data![index];
                return ListTile(
                  title: Text(listing.store.website),
                  subtitle: Text(
                       '${listing.distance}m away'
                     ),
                  trailing: Text('\$${listing.discountedPrice}'),
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
