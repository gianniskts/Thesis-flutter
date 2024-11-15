// main.dart

import 'package:flutter/material.dart';

import '../api/user_api.dart';

void main() => runApp(const MyApp());

const baseUrl =
    "http://127.0.0.1:5000"; // TODO: Change this to your backend URL

final userAPI = UserAPI(baseUrl);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter API Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TestAPIPage(),
    );
  }
}

class TestAPIPage extends StatefulWidget {
  const TestAPIPage({super.key});

  @override
  _TestAPIPageState createState() => _TestAPIPageState();
}

class _TestAPIPageState extends State<TestAPIPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("API Test Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                bool success = await userAPI.addToFavourites(
                    "jkosfp7@gmail.com", "6537d35bd2c36de803f847c8");
                if (success) {
                  print("Added to favourites!");
                } else {
                  print("Failed to add!");
                }
              },
              child: const Text("Add to Favourites"),
            ),
            ElevatedButton(
              onPressed: () async {
                bool success = await userAPI.removeFromFavourites(
                    "jkosfp7@gmail.com", "6537d35bd2c36de803f847c8");
                if (success) {
                  print("Removed from favourites!");
                } else {
                  print("Failed to remove!");
                }
              },
              child: const Text("Remove from Favourites"),
            ),
            ElevatedButton(
              onPressed: () async {
                // List<Listing> favourites = await userAPI.getUserFavourites("jkosfp7@gmail.com");
                // print("Favourites: ${favourites[0].store.name}");
              },
              child: const Text("Get Favourites"),
            ),
          ],
        ),
      ),
    );
  }
}
