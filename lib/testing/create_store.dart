import 'package:flutter/material.dart';

import '../api/store_api.dart';

// Note: Your StoreAPI and other necessary classes should be imported here

void main() => runApp(const MaterialApp(home: StoreRegistrationScreen()));

class StoreRegistrationScreen extends StatefulWidget {
  const StoreRegistrationScreen({super.key});

  @override
  _StoreRegistrationScreenState createState() =>
      _StoreRegistrationScreenState();
}

class _StoreRegistrationScreenState extends State<StoreRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _ownerFirstNameController =
      TextEditingController();
  final TextEditingController _ownerLastNameController =
      TextEditingController();
  final TextEditingController _ownerEmailController = TextEditingController();
  final TextEditingController _ownerPhoneController = TextEditingController();
  final TextEditingController _ownerAddressController =
      TextEditingController();
  final TextEditingController _ownerCityController = TextEditingController();
  final TextEditingController _ownerCountryController =
      TextEditingController();
  final TextEditingController _ownerPostalCodeController =
      TextEditingController();
  final TextEditingController _ownerIBANController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storeAddressController =
      TextEditingController();
  final TextEditingController _storeCityController = TextEditingController();
  final TextEditingController _storePostalCodeController =
      TextEditingController();
  final TextEditingController _storeTypeController = TextEditingController();
  final TextEditingController _storeAboutController = TextEditingController();
  final TextEditingController _storeEmailController = TextEditingController();
  final TextEditingController _storePhoneController = TextEditingController();
  final TextEditingController _storeVATController = TextEditingController();
  final TextEditingController _storeWebsiteController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Store Registration")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _ownerFirstNameController,
                    decoration: const InputDecoration(labelText: "Owner First Name"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter first name";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _ownerLastNameController,
                    decoration: const InputDecoration(labelText: "Owner Last Name"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter last name";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _ownerEmailController,
                    decoration: const InputDecoration(labelText: "Owner Email"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter email";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _ownerPhoneController,
                    decoration: const InputDecoration(labelText: "Owner Phone"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter phone";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _ownerAddressController,
                    decoration: const InputDecoration(labelText: "Owner Address"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter address";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _ownerCityController,
                    decoration: const InputDecoration(labelText: "Owner City"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter city";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _ownerCountryController,
                    decoration: const InputDecoration(labelText: "Owner Country"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter country";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _ownerPostalCodeController,
                    decoration: const InputDecoration(labelText: "Owner Postal Code"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter postal code";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _ownerIBANController,
                    decoration: const InputDecoration(labelText: "Owner IBAN"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter IBAN";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _storeNameController,
                    decoration: const InputDecoration(labelText: "Store Name"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter name";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _storeAddressController,
                    decoration: const InputDecoration(labelText: "Store Address"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter address";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _storeCityController,
                    decoration: const InputDecoration(labelText: "Store City"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter city";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _storePostalCodeController,
                    decoration: const InputDecoration(labelText: "Store Postal Code"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter postal code";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _storeTypeController,
                    decoration: const InputDecoration(labelText: "Store Type"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter type";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _storeAboutController,
                    decoration: const InputDecoration(labelText: "Store About"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter about";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _storeEmailController,
                    decoration: const InputDecoration(labelText: "Store Email"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter email";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _storePhoneController,
                    decoration: const InputDecoration(labelText: "Store Phone"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter phone";
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _storeVATController,
                    decoration: const InputDecoration(labelText: "Store VAT"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter VAT";
                      return null;
                    },
                  ),
                  
                  // ... Repeat for all other fields ...
                  TextFormField(
                    controller: _storeWebsiteController,
                    decoration: const InputDecoration(labelText: "Store Website"),
                    validator: (value) {
                      if (value!.isEmpty) return "Please enter website";
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text("Register Store"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final storeApi = StoreAPI('http://127.0.0.1:5000');
        final store = await storeApi.createStore(
          ownerFirstName: _ownerFirstNameController.text,
          ownerLastName: _ownerLastNameController.text,
          ownerEmail: _ownerEmailController.text,
          ownerPhone: _ownerPhoneController.text,
          ownerAddress: _ownerAddressController.text,
          ownerCity: _ownerCityController.text,
          ownerCountry: _ownerCountryController.text,
          ownerPostalCode: _ownerPostalCodeController.text,
          ownerIBAN: _ownerIBANController.text,
          storeName: _storeNameController.text,
          storeAddress: _storeAddressController.text,
          storeCity: _storeCityController.text,
          storePostalCode: _storePostalCodeController.text,
          storeType: _storeTypeController.text,
          storeAbout: _storeAboutController.text,
          storeEmail: _storeEmailController.text,
          storePhone: _storePhoneController.text,
          storeVAT: _storeVATController.text,
          storeWebsite: _storeWebsiteController.text,
          imageProfileUrl: "https://cdn.e-food.gr/shop/33569/logo?t=1647428522",
          imageBackgroundUrl: "https://cdn.e-food.gr/shop/33569/logo?t=1647428522"
        );
        print(store.id);
        // On Success: navigate or show a message
        // Navigator.of(context).pop(); // Go back or navigate to a different screen
      } catch (e) {
        // Error handling: show a message to the user
          print("Failed to register store: $e");
        
      }
    }
  }

  @override
  void dispose() {
    _ownerFirstNameController.dispose();
    _ownerLastNameController.dispose();
    _ownerEmailController.dispose();
    _ownerPhoneController.dispose();
    _ownerAddressController.dispose();
    _ownerCityController.dispose();
    _ownerCountryController.dispose();
    _ownerPostalCodeController.dispose();
    _ownerIBANController.dispose();
    _storeNameController.dispose();
    _storeAddressController.dispose();
    _storeCityController.dispose();
    _storePostalCodeController.dispose();
    _storeTypeController.dispose();
    _storeAboutController.dispose();
    _storeEmailController.dispose();
    _storePhoneController.dispose();
    _storeVATController.dispose();
    _storeWebsiteController.dispose();

    // ... Dispose all other controllers ...

    super.dispose();
  }
}
