import 'package:flutter/material.dart';

import '../api/store_api.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Store Owner Login Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginStoreScreen(),
    );
  }
}

class LoginStoreScreen extends StatefulWidget {
  const LoginStoreScreen({super.key});

  @override
  _LoginStoreScreenState createState() => _LoginStoreScreenState();
}

class _LoginStoreScreenState extends State<LoginStoreScreen> {
  final TextEditingController _storeCodeController = TextEditingController();
  final TextEditingController _storePasswordController = TextEditingController();

  void _tryLogin() async {
    final storeCode = _storeCodeController.text;
    final storePassword = _storePasswordController.text;

    try {
      final store = await StoreAPI('http://127.0.0.1:5000').loginStore(
        storeCode: storeCode,
        storePassword: storePassword,
      );

      print(store.name);
      print(store.id);

      // Handle successful login here. 
      // For this test, we're just showing a dialog.
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Successful'),
          content: Text('Logged in as: ${store.name}'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {},
            ),
          ],
        ),
      );
    } catch (error) {
      // Handle error. For this test, we're just showing a dialog.
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Login failed.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {},
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store Owner Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _storeCodeController,
              decoration: const InputDecoration(labelText: 'Store Code'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _storePasswordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _tryLogin,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
