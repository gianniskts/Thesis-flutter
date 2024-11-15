import 'package:flutter/cupertino.dart';

import '../../widgets/menu_item.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Νομικά'),
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            menuItem(CupertinoIcons.book, "Όροι Χρήσης", context),
            menuItem(CupertinoIcons.lock_shield, "Πολιτική Απορρήτου", context),
          ],
        ),
      ),
    );
  }
}
