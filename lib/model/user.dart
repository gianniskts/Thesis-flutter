// retrieve location as
// double latitude = user.location['coordinates'][1];
// double longitude = user.location['coordinates'][0];

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String? id;
  final String name;
  final String email;
  final Map<String, dynamic> location;
  List<dynamic> favoriteStoreIds;
  String customerId;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.location,
    this.favoriteStoreIds = const [],
    this.customerId = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      location: json['location'] ?? {},
      favoriteStoreIds: json['favorites'] ?? [],
      customerId: json['customerId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'location': location,
      'favorites': favoriteStoreIds,
      'customerId': customerId,
    };
  }
}

class UserService {
  static final Future<SharedPreferences> _prefsInstance =
      SharedPreferences.getInstance();

  static Future<void> storeUser(User user) async {
    final SharedPreferences prefs = await _prefsInstance;
    String userString = json.encode(user.toJson());
    prefs.setString('user', userString);
  }

  static Future<User?> getUser() async {
    final SharedPreferences prefs = await _prefsInstance;
    String? userString = prefs.getString('user');
    if (userString != null) {
      Map<String, dynamic> userMap = json.decode(userString);
      return User.fromJson(userMap);
    }
    return null;
  }

  // Update specific user fields
  static Future<void> updateUserField(String field, dynamic value) async {
    final SharedPreferences prefs = await _prefsInstance;
    String? userString = prefs.getString('user');
    if (userString != null) {
      Map<String, dynamic> userMap = json.decode(userString);
      userMap[field] = value;
      prefs.setString('user', json.encode(userMap));
    }
  }

  static Future<void> deleteUser() async {
    final SharedPreferences prefs = await _prefsInstance;
    prefs.remove('user');
  }
}
