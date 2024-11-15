import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

void main() {
  Stripe.publishableKey = 'pk_test_51O7qG6L45NX52ERnKl0hU7XW0pnPOzuJ9Kz1vFQOKy8ETi3eDyWOKPC2WW5Ua80Ty0lgKN8L51peuOAFz2fhzJhp00MCviUKCC';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stripe Payment Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PaymentScreen(),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stripe Payment")),
      body: Center(
        child: ElevatedButton(
          onPressed: makePayment,
          child: const Text('Make a Payment'),
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      //STEP 1: Create Payment Intent
      paymentIntent = await createPaymentIntent('100', 'USD');
      print("Client Secret: ${paymentIntent!['client_secret']}");
      print("Payment Intent: $paymentIntent");

      //STEP 2: Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          
          style: ThemeMode.light,
          merchantDisplayName: 'MyStore',
        ),
      );

      //STEP 3: Display Payment Sheet
      await displayPaymentSheet();

    } catch (err) {
      print("Error: $err");
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
    final body = {
      'amount': calculateAmount(amount).toString(),
      'currency': currency,
    };

    final headers = {
      'Authorization': 'Bearer sk_test_51O7qG6L45NX52ERnWY8uK7FBrwU3NADVNqVUtTDFpQ46ITybXZKEhbQV6YicdpNShTfOr9prWGzG7dtKkyU4j9SX00k8nI7T6s',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
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
          showDialog(
            context: context,
            builder: (_) => const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 100.0,
                  ),
                  SizedBox(height: 10.0),
                  Text("Payment Successful!"),
                ],
              ),
            ),
          );
        
        verifyPaymentOnServer(paymentIntent?['id']);
        // Clear paymentIntent variable after successful payment
        paymentIntent = null;

      }).onError((error, stackTrace) {
        throw Exception(error);
      });
      
    } on StripeException catch (e) {
      print('Stripe Error: $e');
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
    } catch (e) {
      print('General Error: $e');
    }
  }
}

Future<void> verifyPaymentOnServer(String paymentIntentId) async {
  final response = await http.post(
    Uri.parse('http://127.0.0.1:5000/verify_payment'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'payment_intent_id': paymentIntentId,
    }),
  );

  final responseData = json.decode(response.body);
  if (responseData['status'] == 'success') {
    // Handle success
  } else {
    // Handle verification failure or error
  }
}
