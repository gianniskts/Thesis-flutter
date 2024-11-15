import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static final Future<SharedPreferences> _prefsInstance =
      SharedPreferences.getInstance();

  static Future<String> getUserAddress() async {
    final SharedPreferences prefs = await _prefsInstance;
    return prefs.getString('userAddress') ?? '';
  }

  static Future<void> storeUserAddress(String address) async {
    final SharedPreferences prefs = await _prefsInstance;
    prefs.setString('userAddress', address);
  }

  static Future<String> getRealUserAddress() async {
    final SharedPreferences prefs = await _prefsInstance;
    return prefs.getString('realUserAddress') ?? '';
  }

  static Future<void> storeRealUserAddress(String address) async {
    final SharedPreferences prefs = await _prefsInstance;
    prefs.setString('realUserAddress', address);
  }

  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    // Assuming you store a boolean to indicate if a user is logged in.
    return prefs.getBool('loggedIn') ?? false;
  }

  // Additional methods for login, logout, etc. can be added here.
  // login
  static Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('loggedIn', true);
  }

  // logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('loggedIn', false);
  }

  // Store recent addresses (Limit of 5 for simplicity)
  static Future<void> storeRecentAddress(String address) async {
    final SharedPreferences prefs = await _prefsInstance;
    String recentAddresses = prefs.getString('recentAddresses') ?? '';
    List<String> addressList = recentAddresses.split(',').toList();
    if (!addressList.contains(address)) {
      addressList.insert(0, address);
    }
    while (addressList.length > 5) {
      addressList.removeLast();
    }
    prefs.setString('recentAddresses', addressList.join(','));
  }

  static Future<List<String>> getRecentAddresses() async {
    final SharedPreferences prefs = await _prefsInstance;
    String recentAddresses = prefs.getString('recentAddresses') ?? '';
    return recentAddresses.split(',');
  }

  static Future<bool>? clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    return true;
  }
}
