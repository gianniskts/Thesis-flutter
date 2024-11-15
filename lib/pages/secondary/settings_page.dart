import 'package:flutter/cupertino.dart';
import 'package:frontend/widgets/menu_item.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  CupertinoPageScaffold(
      navigationBar:   const CupertinoNavigationBar(
        middle: Text('Ρυθμίσεις'),
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            menuItem(CupertinoIcons.person_crop_circle_fill_badge_plus, "Λογαριασμός", context),
            // menuItem(CupertinoIcons.creditcard_fill, "Μέθοδοι πληρωμής", context),
            // menuItem(CupertinoIcons.bell_circle, "Ειδοποιήσεις", context),
            menuItem(CupertinoIcons.leaf_arrow_circlepath, "Αποσύνδεση", context),
          ],
        ),
      ),
    );
  }
}
