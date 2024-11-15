import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../helpers/shared_preferences_service.dart';
import '../main.dart';
import '../pages/auth/landing_page.dart';
import '../pages/secondary/account_page.dart';
import '../pages/secondary/add_store_page.dart';
import '../pages/secondary/help_page.dart';
import '../pages/secondary/legal_page.dart';
import '../pages/secondary/settings_page.dart';
import '../pages/secondary/store_login.dart';

Widget menuItem(IconData icon, String title, BuildContext context) {
  return CupertinoButton(
    padding: EdgeInsets.zero,
    onPressed: () async {
      // Handle navigation
      switch (title) {
        case 'Αποσύνδεση':
          // Clear shared preferences
          SharedPreferencesService.clearAllPreferences();
          // Navigate to the Landing Page
          navigatorKey.currentState?.popAndPushNamed(LandingPage.routeName);

          break;
        case 'Ρυθμίσεις':
          Navigator.push(context,
              CupertinoPageRoute(builder: (context) => const SettingsPage()));
          break;

        case 'Λογαριασμός':
          Navigator.push(context,
              CupertinoPageRoute(builder: (context) => const AccountPage()));
          break;
        case 'Σύνδεση Καταστήματος':
          Navigator.push(context,
              CupertinoPageRoute(builder: (context) => const StoreLoginPage()));
          break;
        case 'Εγγραφή καταστήματος':
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const AddStorePage(
                type: 'f',
              ),
            ),
          );
          break;
        case 'Νομικά':
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const LegalPage(),
            ),
          );
          break;
        case 'Όροι Χρήσης':
          const url = 'https://pdfhost.io/v/RA8X5TcVQ_terms_of_service_ecoeats';
          // https://pdfhost.io/edit?doc=94088e39-d5f5-44b0-b309-fae645011f12
          if (await canLaunchUrlString(url)) {
            await launchUrlString(url);
          } else {
            throw 'Could not launch $url';
          }
          break;
        case 'Πολιτική Απορρήτου':
          const url = 'https://pdfhost.io/v/oyXA5tcfn_privacy_policy_ecoeats';
          // https://pdfhost.io/edit?doc=25d2e94d-9da2-415f-96a8-27b90d3e240d
          if (await canLaunchUrlString(url)) {
            await launchUrlString(url);
          } else {
            throw 'Could not launch $url';
          }
          break;
        case 'Βοήθεια':
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => const HelpPage()),
          );

        default:
          break;
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            color: CupertinoColors.black,
          ),
          const SizedBox(width: 8.0),
          Text(title, style: const TextStyle(color: CupertinoColors.black)),
          const Spacer(),
          const Icon(
            CupertinoIcons.right_chevron,
            color: CupertinoColors.black,
          ),
        ],
      ),
    ),
  );
}
