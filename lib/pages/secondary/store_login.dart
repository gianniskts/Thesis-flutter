import 'package:flutter/cupertino.dart';
import 'package:frontend/widgets/menu_item.dart';

class StoreLoginPage extends StatelessWidget {
  const StoreLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Σύνδεση Καταστήματος'),
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            menuItem(CupertinoIcons.archivebox, "Εγγραφή καταστήματος", context),
            menuItem(CupertinoIcons.add_circled, "Πρότεινε ένα κατάστημα", context),
          ],
        ),
      ),
    );
  }
}
