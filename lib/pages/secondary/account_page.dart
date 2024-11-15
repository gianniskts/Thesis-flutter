import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../api/user_api.dart';
import '../../helpers/shared_preferences_service.dart';
import '../../main.dart';
import '../../model/user.dart';
import '../auth/landing_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  bool isLoading = false;
  User? user;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    setState(() => isLoading = true);
    user = await UserService.getUser();
    setState(() => isLoading = false);
  }

  // void _changeName() async {
  //   if (_nameController.text.isEmpty) {
  //     _showDialog('Error', 'Name cannot be empty.');
  //     return;
  //   }

  //   setState(() => isLoading = true);
  //   UserAPI userAPI = UserAPI('http://127.0.0.1:5000');
  //   bool success = await userAPI.changeUserName(user!.email, _nameController.text);
  //   if (success) {
  //     await UserService.updateUserField('name', _nameController.text);
  //     // setState(() => user!.name = _nameController.text);
  //     _showDialog('Success', 'Name updated successfully.');
  //   } else {
  //     _showDialog('Error', 'Failed to update name.');
  //   }
  //   setState(() => isLoading = false);
  // }

  void _deleteAccount() async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Είσαι σίγουρος/η ότι θέλεις να διαγράψεις το λογαριασμό σου'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Ακύρωση'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.of(context).pop();
                await _performDeleteAccount();
              },
              child: const Text('Διαγραφή'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDeleteAccount() async {
    setState(() => isLoading = true);
    UserAPI userAPI = UserAPI('http://127.0.0.1:5000');
    bool success = await userAPI.deleteUserAccount(user!.email);
    if (success) {
      await SharedPreferencesService.clearAllPreferences();
      navigatorKey.currentState?.popAndPushNamed(LandingPage.routeName);
    } else {
      _showDialog('Error', 'Failed to delete account.');
      setState(() => isLoading = false);
    }
  }

  void _showDialog(String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Πληροφορίες Λογαριασμού'),
        border: null,
      ),
      child: SafeArea(
        child: isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(user!.name,
                            style: const TextStyle(
                                fontSize: 24.0, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8.0),
                        Text(user!.email,
                            style: const TextStyle(
                                fontSize: 18.0, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _deleteAccountButton(),
                ],
              ),
      ),
    );
  }

  Widget _deleteAccountButton() {
    return CupertinoButton(
      color: CupertinoColors.destructiveRed,
      borderRadius: BorderRadius.circular(16.0),
      onPressed: _deleteAccount,
      child: const Text('Διαγραφή Λογαριασμού',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
