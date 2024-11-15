import 'package:flutter/cupertino.dart';
import 'package:frontend/main.dart';
import 'package:geolocator/geolocator.dart';
import '../../api/user_api.dart';
import '../../helpers/shared_preferences_service.dart';
import '../../model/user.dart';

class GetLocationPage extends StatefulWidget {
  final String name, surname, email;
  final bool register;

  const GetLocationPage({
    super.key,
    required this.name,
    required this.surname,
    required this.email,
    required this.register,
  });

  @override
  GetLocationPageState createState() => GetLocationPageState();
}

class GetLocationPageState extends State<GetLocationPage> {
  bool isFetchingLocation = false;
  final UserAPI userAPI = UserAPI('http://127.0.0.1:5000');

  @override
  void initState() {
    super.initState();
    _useMyLocation();
  }

  Future<void> _useMyLocation() async {
    setState(() => isFetchingLocation = true);

    try {
      await _checkLocationServiceAndPermission();
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      Map<String, dynamic> locationData = {
        'latitude': position.latitude,
        'longitude': position.longitude
      };
      String userAdress = await userAPI.getAddressFromLatLng(
          position.latitude, position.longitude);

      SharedPreferencesService.storeUserAddress(userAdress);
      await SharedPreferencesService.login();

      await _handleUserNavigation(locationData);
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => isFetchingLocation = false);
    }
  }

  Future<void> _checkLocationServiceAndPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw 'Location services are not enabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw 'Location permissions are denied.';
      }
    }
  }

  Future<void> _handleUserNavigation(Map<String, dynamic> locationData) async {
    if (widget.register) {
      bool registrationSuccessful = await userAPI.register(
          "${widget.name} ${widget.surname}", widget.email, locationData);
      if (!registrationSuccessful) {
        throw 'Registration failed. Please try again.';
      }
    }

    final List<dynamic> storeIds =
        await userAPI.getUserFavouriteStoreIds(widget.email);
    User user = User(
        email: widget.email,
        name: "${widget.name} ${widget.surname}",
        location: locationData,
        favoriteStoreIds: storeIds);
    await UserService.storeUser(user);

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        HomePage.routeName,
        (Route<dynamic> route) => false,
      );
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 25.0),
          child: isFetchingLocation
              ? const CupertinoActivityIndicator() // Show loading indicator when fetching location
              : const Text(
                  'Select Allow While Using App to see stores nearby',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}
