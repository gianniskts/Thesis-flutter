import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/helpers/shared_preferences_service.dart';
import 'package:frontend/pages/auth/get_email_page.dart';
import 'package:frontend/pages/auth/landing_page.dart';
import 'package:provider/provider.dart';

import 'model/favorites_provider.dart';
import 'model/order_provider.dart';
import 'pages/main/browse_page.dart';
import 'pages/main/discover_page.dart';
import 'pages/main/favorites_page.dart';
import 'pages/main/me_page.dart';

import 'package:flutter_stripe/flutter_stripe.dart';

import 'pages/secondary/order_page.dart';

import 'package:google_fonts/google_fonts.dart';

void main() async {

  await dotenv.load(fileName: "keys.env");
  if (dotenv.env['STRIPE_TEST_KEY'] == null) {
    throw Exception("No Stripe API key found. Please add it to keys.env");
  }
  Stripe.publishableKey = dotenv.env['STRIPE_TEST_KEY']!;
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
        ChangeNotifierProvider(
            create: (context) => OrderStatusProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'EcoEats',
      navigatorKey: navigatorKey,
      theme: CupertinoThemeData(
        primaryColor: const Color(0xFF03605f),
        primaryContrastingColor: CupertinoColors.black,
        scaffoldBackgroundColor: const Color(0xFFfbfaf6),
        applyThemeToAll: true,
        textTheme: CupertinoTextThemeData(
          primaryColor: CupertinoColors.black,
          textStyle: TextStyle(
            fontFamily: GoogleFonts.inter().fontFamily,
            color: CupertinoColors.black,
          ),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('el', 'GR'), // Greek
      ],
      initialRoute: RootScreen.routeName,
      routes: {
        RootScreen.routeName: (context) => const RootScreen(),
        LandingPage.routeName: (context) => const LandingPage(),
        HomePage.routeName: (context) => const HomePage(),
        GetEmailPage.routeName: (context) => const GetEmailPage(),
      },
    );
  }
}

class RootScreen extends StatefulWidget {
  static const routeName = '/';

  const RootScreen({super.key});

  @override
  RootScreenState createState() => RootScreenState();
}

class RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: FutureBuilder<bool>(
        future: SharedPreferencesService.isAuthenticated(),
        builder: (context, snapshot) {
          // If the Future is still running, show a loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SpinKitFadingCube(
              color: Colors.blue,
              size: 50.0,
            );
          }

          // If authenticated, navigate to home, otherwise to registration page.
          if (snapshot.data == true) {
            return const HomePage();
          } else {
            return const LandingPage();
          }
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    Provider.of<OrderStatusProvider>(context, listen: false)
        .checkForLiveOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderStatusProvider>(
        builder: (context, orderStatus, child) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.compass),
              label: 'Ανακάλυψε',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.bag),
              label: 'Εξερεύνησε',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.heart),
              label: 'Αγαπημένα',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person_crop_circle),
              label: 'Εγώ',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          return SafeArea(
            child: Stack(
              children: [
                _buildPageContent(context, index),
                if (orderStatus.isOrderPlaced)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildOrderStatusBanner(context, orderStatus),
                  ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildPageContent(BuildContext context, int index) {
    switch (index) {
      case 0:
        return CupertinoTabView(builder: (context) {
          return const CupertinoPageScaffold(
            child: DiscoverPage(),
          );
        });
      case 1:
        return CupertinoTabView(builder: (context) {
          return const CupertinoPageScaffold(
            child: BrowsePage(),
          );
        });
      case 2:
        return CupertinoTabView(builder: (context) {
          return const CupertinoPageScaffold(
            child: FavoritesPage(),
          );
        });
      case 3:
        return CupertinoTabView(builder: (context) {
          return const CupertinoPageScaffold(
            child: MePage(),
          );
        });
    }
    return const Placeholder();
  }

  Widget _buildOrderStatusBanner(
      BuildContext context, OrderStatusProvider orderStatus) {
    // print(orderStatus.orderDetails?.listing.store.name);

    // Check if orderDetails is null before using it
    if (orderStatus.orderDetails == null) {
      // Return an empty Container or any other placeholder widget
      return Container();
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => OrderPage(
                order: orderStatus.orderDetails!,
                isPurchased: false,
                showForHistory: false,
              ),
            ));
      },
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.08,
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Color(0xFF03605f),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    orderStatus.orderDetails!.listing.store.imageProfileUrl,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Η παραγγελία σου",
                      style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      orderStatus.timeUntilCollection > Duration.zero
                          ? 'Διαθέσιμη σε ${orderStatus.timeUntilCollection.inMinutes} λεπτά'
                          : 'Ώρα να την παραλάβεις!',
                      style: const TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w400),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.white,
            ),
          ],
        ),
      ),
    );
  }
}
