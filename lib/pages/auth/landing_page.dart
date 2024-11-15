import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'get_email_page.dart';
import 'get_location_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});
  static const routeName = '/landing';

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _scaleAnimation = Tween(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation after a one-second delay
    Future.delayed(const Duration(seconds: 1), () {
      _controller!.forward();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User cancelled the login
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final response = await http.post(
        Uri.parse(
            'http://127.0.0.1:5000/auth/google'), // Replace with your Flask endpoint
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'token': googleAuth.idToken!,
        }),
      );

      if (mounted) {
        // Handle the response from the backend
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          String name = responseData['name'];
          final nameParts = name.split(' ');
          final firstName = nameParts[0];
          final surname = nameParts.length > 1 ? nameParts[1] : '';

          if (responseData['isRegistered']) {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => GetLocationPage(
                          email: responseData['email'],
                          name: firstName,
                          surname: surname,
                          register: false,
                        )));
          } else {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => GetLocationPage(
                          email: responseData['email'],
                          name: firstName,
                          surname: surname,
                          register: true,
                        )));
          }
        } else {
          // Handle error response
          print(response.body);
        }
      }
    } catch (error) {
      // Handle error
      print(error);
    }
  }

  Widget _buildSignInButton({
    required String text,
    required Color color,
    required String icon,
    required VoidCallback onPressed,
  }) {
    return CupertinoButton(
      color: color,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      borderRadius: BorderRadius.circular(32.0), // Moved borderRadius here
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center, // Aligns icon and text in center
        children: [
          if (icon != 'null')
            Image.asset(
              'assets/$icon.png', // Renamed parameter for clarity
              height: 20.0,
              width: 20.0, // Added width for consistent sizing
            ),
          const SizedBox(width: 10.0),
          Expanded(
            // Wrapping Text with Expanded to handle long text
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis, // Prevents text overflow
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Καλωσήρθες στο EcoEats!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF03605f),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ScaleTransition(
                    scale: _scaleAnimation!,
                    child: Image.asset(
                      'assets/EcoEats-4.png',
                    ),
                  ),
                ),
                const Text(
                  'Η πορεία σου ξεκινάει εδώ!',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (Platform.isIOS) // Added if statement
                  _buildSignInButton(
                    text: 'Σύνδεση με Apple',
                    color: Colors.black, // Apple's branding color
                    icon: 'apple', // Replace with Apple icon
                    onPressed: () {
                      // Integrate Apple Sign-In
                    },
                  ),
                const SizedBox(height: 10),
                _buildSignInButton(
                  text: 'Σύνδεση με Google',
                  color: Colors.red, // Google's branding color
                  icon: 'google', // Replace with Google icon
                  onPressed: () => signInWithGoogle(context),
                ),
                const SizedBox(height: 10),
                _buildSignInButton(
                  text: 'Σύνδεση με Facebook',
                  color: const Color(0xFF4267B2), // Facebook's branding color
                  icon: 'facebook', // Replace with Facebook icon
                  onPressed: () {
                    // Integrate Facebook Sign-In
                  },
                ),
                const SizedBox(height: 10),
                _buildSignInButton(
                  text: 'Σύνδεση με Email',
                  color: const Color(0xFF03605f),
                  icon: 'null',
                  onPressed: () {
                    Navigator.pushNamed(context, GetEmailPage.routeName);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
