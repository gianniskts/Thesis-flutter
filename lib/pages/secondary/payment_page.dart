// Dart built-in imports
import 'dart:convert';

// Package imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Local imports
import '../../api/user_api.dart';
import '../../model/listing.dart';
import '../../model/order.dart';
import '../../model/store.dart';
import '../../model/user.dart';
import 'order_page.dart';

// Constants
const BASE_API_URL = 'http://127.0.0.1:5000';
const STRIPE_API_URL = 'https://api.stripe.com/v1/payment_intents';
const STRIPE_TEST_KEY =
    'Bearer sk_test_51Oa14lJtIJIPBcXhimtm2mv18jyMxlE36vmXKRd5NCmwem2iwBhonTzPYj9ECtc5RJHzbeZNQvzVRHGVT24KZl3n003vnAidYz';

class PaymentPage extends StatefulWidget {
  final Store store;
  final Listing listing;

  const PaymentPage({super.key, required this.store, required this.listing});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Map<String, dynamic>? paymentIntent;
  OrderDetails? orderDetails;
  final UserAPI userAPI = UserAPI(BASE_API_URL);
  int _quantity = 1; // State for managing quantity
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: SpinKitPulsingGrid(
          color: Color(0xFF03605f),
          size: 50,
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      // color: CupertinoColors.white,
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: _headerSection(context),
              ),
              Align(
                alignment: Alignment.topRight,
                child: CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: const Icon(CupertinoIcons.xmark, size: 24),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _quantitySection(),
          const SizedBox(height: 10),
          _priceSection(),
          const SizedBox(height: 10),
          _actionSection(context),
        ],
      ),
    );
  }

  Widget _headerSection(BuildContext context) {
    // Format the date and time
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final formattedStartTime =
        timeFormat.format(widget.listing.availabilityStartDate);
    final formattedEndTime =
        timeFormat.format(widget.listing.availabilityEndDate);

    String collectText;
    if (dateFormat.format(widget.listing.availabilityStartDate) ==
        dateFormat.format(now)) {
      collectText = 'Διαθέσιμο σήμερα $formattedStartTime - $formattedEndTime';
    } else if (dateFormat.format(widget.listing.availabilityStartDate) ==
        dateFormat.format(tomorrow)) {
      collectText = 'Διαθέσιμο αύριο $formattedStartTime - $formattedEndTime';
    } else {
      collectText =
          'Διαθέσιμο: ${dateFormat.format(widget.listing.availabilityStartDate)} $formattedStartTime - $formattedEndTime';
    }
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.1),
          child: Column(
            children: [
              Text(
                widget.listing.store.name,
                style: const TextStyle(
                    fontSize: 18,
                    overflow: TextOverflow.clip,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.clock, size: 12),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(collectText,
                        style: const TextStyle(
                            fontSize: 14, overflow: TextOverflow.clip),
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(
          thickness: 0.5,
          color: CupertinoColors.systemGrey,
        ),
      ],
    );
  }

  Widget _quantitySection() {
    return Column(
      children: [
        const Text(
          'Ποσότητα',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _customButton(
              icon: CupertinoIcons.minus,
              onPressed: _quantity > 1
                  ? () {
                      setState(() {
                        _quantity--;
                      });
                    }
                  : null,
            ),
            const SizedBox(width: 20),
            Text(
              '$_quantity',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 20),
            _customButton(
              icon: CupertinoIcons.plus,
              onPressed: _quantity < widget.listing.quantityAvailable
                  ? () {
                      setState(() {
                        _quantity++;
                      });
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _customButton(
      {required IconData icon, required VoidCallback? onPressed}) {
    return CupertinoButton(
      padding: const EdgeInsets.all(10),
      color: const Color(0xFF03605f),
      borderRadius: BorderRadius.circular(30),
      onPressed: onPressed,
      child: Icon(icon, color: CupertinoColors.white),
    );
  }

  Widget _priceSection() {
    return Column(
      children: [
        const Divider(
          thickness: 0.5,
          color: CupertinoColors.systemGrey,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Σύνολο',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "${(widget.listing.discountedPrice * _quantity).toStringAsFixed(2)} €", // Formatting to two decimal places
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF03605f),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(
          thickness: 0.5,
          color: CupertinoColors.systemGrey,
        ),
      ],
    );
  }

  Widget _actionSection(BuildContext context) {
    return CupertinoButton(
        onPressed: makePayment,
        color: const Color(0xFF03605f),
        borderRadius: BorderRadius.circular(30),
        child: const Text(
          "Πληρωμή",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ));
  }

  Future<void> makePayment() async {
    User? currentUser = await UserService.getUser();
    if (currentUser?.customerId == '') {
      // Create a new Stripe Customer object on the server
      UserAPI userAPI = UserAPI(BASE_API_URL);
      final customerId = await userAPI.createStripeCustomer(currentUser!.email);
      currentUser.customerId = customerId;
      await UserService.storeUser(currentUser);
    }

    try {
      //STEP 1: Create Payment Intent
      paymentIntent = await createPaymentIntent(
          widget.listing.discountedPrice.toString(),
          'EUR',
          currentUser!.customerId);
      print("Client Secret: ${paymentIntent!['client_secret']}");
      print("Payment Intent: $paymentIntent");

      //STEP 2: Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // applePay: const PaymentSheetApplePay(merchantCountryCode: 'GR'),
          // googlePay: const PaymentSheetGooglePay(merchantCountryCode: 'GR'),
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF03605f),
            ),
          ),
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          // customerEphemeralKeySecret: ,
          style: ThemeMode.system,
          merchantDisplayName: 'EcoEats',
          primaryButtonLabel: "Πληρωμή",
        ),
      );

      //STEP 3: Display Payment Sheet
      await displayPaymentSheet();
    } catch (err) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Text('An error occurred: $err'),
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency, String customerId) async {
    final body = {
      'amount': calculateAmount(amount).toString(),
      'currency': currency,
      'customer': customerId,
    };

    final headers = {
      'Authorization': STRIPE_TEST_KEY,
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final response = await http.post(
      Uri.parse(STRIPE_API_URL),
      headers: headers,
      body: body,
    );

    return json.decode(response.body);
  }

  int calculateAmount(String amount) {
    return (double.parse(amount) * 100).toInt();
  }

  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        verifyPaymentOnServer(paymentIntent?['id']);
        // Clear paymentIntent variable after successful payment
        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (e) {
      print('Stripe Error: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    Text("Payment Failed"),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      print('General Error: $e');
    }
  }

  Future<void> verifyPaymentOnServer(String paymentIntentId) async {
    setState(() {
      isLoading = true;
    });
    User? currentUser = await UserService.getUser();

    orderDetails = OrderDetails(
      user: currentUser!,
      listing: widget.listing,
      quantity: _quantity,
    );

    if (orderDetails == null) {
      // Handle the error: order details not set
      return;
    }

    final orderData = orderDetails!.toJson();
    orderData['payment_intent_id'] = paymentIntentId;

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/verify_payment'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(orderData),
    );

    final responseData = json.decode(response.body);

    setState(() {
      isLoading = false;
    });
    if (responseData['status'] == 'success') {
      // Handle success
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (context) => OrderPage(
              order: orderDetails!,
              isPurchased: false,
              showForHistory: false,
            ),
          ),
          (Route<dynamic> route) => route.isFirst,
          // This will keep only the first route (which should be the HomePage) and put the OrderPage on top of it.
        );
      }
    } else {
      // Handle verification failure or error
    }
  }
}
