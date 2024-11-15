import 'package:flutter/cupertino.dart';

import '../../api/user_api.dart';
import 'verification_page.dart';

class GetEmailPage extends StatefulWidget {
  const GetEmailPage({super.key});
  static const routeName = '/landing/get_email';

  @override
  GetEmailPageState createState() => GetEmailPageState();
}

class GetEmailPageState extends State<GetEmailPage> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isValidEmail = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);

    // Give a frame for the widget tree to be built, then request focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    setState(() {
      _isValidEmail = _isValid(_emailController.text);
    });
  }

  bool _isValid(String email) {
    // Simple email validation logic
    return email.contains('@') && email.contains('.');
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Ας ξεκινήσουμε'),
        backgroundColor: CupertinoColors.white,
        border: Border.all(
          color: CupertinoColors.white,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Email'),
                const SizedBox(height: 16),
                CupertinoTextField(
                  keyboardType: TextInputType.emailAddress,
                  placeholder: "Ποιό είναι το email σου;",
                  placeholderStyle: const TextStyle(
                    color: CupertinoColors.systemGrey,
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 15.0),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  style: const TextStyle(
                    color: CupertinoColors.black,
                    fontSize: 16.0,
                  ),
                  controller: _emailController,
                  focusNode: _focusNode,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  disabledColor: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(45.0),
                  color: _isValidEmail
                      ? const Color(0xFF03605f)
                      : CupertinoColors.systemGrey5,
                  onPressed: _isValidEmail
                      ? () async {
                          final email = _emailController.text;

                          // Create an instance of UserAPI
                          final userAPI = UserAPI('http://127.0.0.1:5000');
                          userAPI.sendCode(email);

                          // Navigate to auth_code_page.dart
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => VerificationPage(email: email),
                            ),
                          );
                        }
                      : null,
                  child: Text(
                    'Συνέχεια',
                    style: TextStyle(
                      color: _isValidEmail
                          ? CupertinoColors.white
                          : CupertinoColors.systemGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}