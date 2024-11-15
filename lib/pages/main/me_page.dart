import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/model/order.dart';
import 'package:frontend/model/user.dart';

import '../../api/user_api.dart';
import '../../widgets/menu_item.dart';
import '../secondary/order_page.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  Map<String, dynamic>? userImpact;
  bool isLoading = true;
  User? user;

  @override
  void initState() {
    super.initState();
    _fetchUserImpact();
  }

  Future<void> _fetchUserImpact() async {
    setState(() {
      isLoading = true;
    });

    user = await UserService.getUser();

    UserAPI userAPI =
        UserAPI('http://127.0.0.1:5000'); // Your API base URL
    userImpact = await userAPI.getUserImpact(user!.email);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: isLoading ? _buildLoadingIndicator() : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CupertinoActivityIndicator(radius: 15.0), // iOS style loader
      // For Android style, use CircularProgressIndicator()
    );
  }

  Widget _buildContent() {
    return ListView(
      children: <Widget>[
        _buildImpactCards(),
        _buildMenuOptions(),
      ],
    );
  }

  Widget _buildImpactCards() {
    int moneySaved = userImpact!['money_saved'].toInt();
    int totalPurchases = userImpact!['total_purchases'];
    int co2eAvoided = userImpact!['co2e_avoided'].toInt();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'ΑΠΟΤΥΠΩΜΑ',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFF03605f),
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildImpactCard(CupertinoIcons.money_euro_circle,
                  '$moneySaved €', 'Money Saved', userImpact),
              const SizedBox(width: 8.0),
              _buildImpactCard(CupertinoIcons.bag, '$totalPurchases', 'Orders'),
              const SizedBox(width: 8.0),
              _buildImpactCard(
                  CupertinoIcons.cloud, '$co2eAvoided kg', 'CO2', userImpact),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCard(IconData icon, String value, String type,
      [Map<String, dynamic>? userImpact]) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: GestureDetector(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFe0fce2),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                // Add this boxShadow property
                BoxShadow(
                  color: CupertinoColors.black
                      .withOpacity(0.1), // Shadow color with opacity
                  spreadRadius: 0,
                  blurRadius: 4.0,
                  offset:
                      const Offset(0, 2), // Keeps the shadow only at the bottom
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 24.0, color: const Color(0xFF03605f)),
                const SizedBox(height: 10.0),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF03605f),
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            // Handle navigation
            switch (type) {
              case 'Money Saved':
                _showMoneySavedPopup(context, userImpact);
                break;
              case 'Orders':
                _showOrdersPopup(context, user!.email);
                break;
              case 'CO2':
                _showCO2eSavedPopup(context, userImpact);
                break;
              default:
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildMenuOptions() {
    return Column(
      children: <Widget>[
        menuItem(CupertinoIcons.settings, 'Ρυθμίσεις', context),
        // menuItem(CupertinoIcons.question, 'Σύνδεση Καταστήματος', context),
        menuItem(CupertinoIcons.info, 'Βοήθεια', context),
        // menuItem(CupertinoIcons.tags, 'Εξαργύρωση', context),
        menuItem(CupertinoIcons.book, 'Νομικά', context),
      ],
    );
  }
}

Future<void> _showOrdersPopup(BuildContext context, String email) async {
  List<OrderDetails> orders = await fetchUserOrders(email);
  if (context.mounted) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('Παραγγελίες'),
            border: Border(bottom: BorderSide.none),
          ),
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (BuildContext context, int index) {
              return _orderWidget(orders[index], context);
            },
          ),
        );
      },
    );
  }
}

Future<void> _showMoneySavedPopup(
    BuildContext context, Map<String, dynamic>? userImpact) async {
  int moneySaved = userImpact!['money_saved'].toInt();
  int originalValue = userImpact['original_value'].toInt();
  int paidValue = userImpact['paid_value'].toInt();
  int totalPurchases = userImpact['total_purchases'];

  showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('Χρήματα που εξοικονόμησες'),
            border: Border(bottom: BorderSide.none),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        // Add this boxShadow property
                        BoxShadow(
                          color: CupertinoColors.black
                              .withOpacity(0.1), // Shadow color with opacity
                          spreadRadius: 0,
                          blurRadius: 4.0,
                          offset: const Offset(
                              0, 2), // Keeps the shadow only at the bottom
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFe0fce2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(CupertinoIcons.bag)),
                            const SizedBox(width: 10),
                            const Text('Γεύματα που έσωσες:'),
                            const Spacer(),
                            Text('$totalPurchases',
                                style: const TextStyle(
                                    color: Color(0xFF03605f),
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFe0fce2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    CupertinoIcons.money_euro_circle_fill)),
                            const SizedBox(width: 10),
                            const Text('Αρχική τιμή:'),
                            const Spacer(),
                            Text('$originalValue €',
                                style: const TextStyle(
                                    color: Color(0xFF03605f),
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFe0fce2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    CupertinoIcons.money_euro_circle)),
                            const SizedBox(width: 10),
                            const Text('Πλήρωσες:'),
                            const Spacer(),
                            Text('$paidValue €',
                                style: const TextStyle(
                                    color: Color(0xFF03605f),
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(
                          thickness: 2,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Text('Εξοικονόμησες:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Text('$moneySaved €',
                                style: const TextStyle(
                                    color: CupertinoColors.systemRed,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(30.0),
                    color: const Color(0xFF03605f),
                    child: const Text(
                      'Εξοικονόμησε περισσότερα χρήματα',
                      style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}

Future<void> _showCO2eSavedPopup(
    BuildContext context, Map<String, dynamic>? userImpact) async {
  int electricitySaved = userImpact!['electricity_saved_kwh'].toInt();
  int smartphoneCharges = userImpact['smartphone_charges'].toInt();
  int cupsOfCoffee = userImpact['cups_of_coffee'].toInt();
  int minutesOfShower = userImpact['minutes_of_shower'].toInt();
  int co2eAvoided = userImpact['co2e_avoided'].toInt();

  showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('Το ενεργειακό σου αποτύπωμα'),
            border: Border(bottom: BorderSide.none),
          ),
          child: Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Το CO2e που έσωσες είναι:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color:
                                CupertinoColors.inactiveGray.withOpacity(0.4),
                            // width: 2,
                          ),
                          color: CupertinoColors.white,
                        ),
                        child: Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFe0fce2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(CupertinoIcons.bolt)),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$electricitySaved kWh',
                                    style: const TextStyle(
                                        color: Color(0xFF03605f),
                                        fontWeight: FontWeight.bold)),
                                const Text('Ρεύμα που έσωσες',
                                    style: TextStyle(
                                        color: CupertinoColors.inactiveGray,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color:
                                CupertinoColors.inactiveGray.withOpacity(0.4),
                            // width: 2,
                          ),
                          color: CupertinoColors.white,
                        ),
                        child: Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 252, 235, 224),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    CupertinoIcons.device_phone_portrait)),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$smartphoneCharges',
                                    style: const TextStyle(
                                        color: Color(0xFF03605f),
                                        fontWeight: FontWeight.bold)),
                                const Text('Φορτίσεις smartphone',
                                    style: TextStyle(
                                        color: CupertinoColors.inactiveGray)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color:
                                CupertinoColors.inactiveGray.withOpacity(0.4),
                            // width: 2,
                          ),
                          color: CupertinoColors.white,
                        ),
                        child: Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 255, 253, 230),
                                  shape: BoxShape.circle,
                                ),
                                child:
                                    const Icon(CupertinoIcons.circle_grid_hex)),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$cupsOfCoffee',
                                    style: const TextStyle(
                                        color: Color(0xFF03605f),
                                        fontWeight: FontWeight.bold)),
                                const Text('Κούπες ζεστού καφέ',
                                    style: TextStyle(
                                        color: CupertinoColors.inactiveGray)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color:
                                CupertinoColors.inactiveGray.withOpacity(0.4),
                            // width: 2,
                          ),
                          color: CupertinoColors.white,
                        ),
                        child: Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 230, 237, 255),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(CupertinoIcons.drop_fill)),
                            const SizedBox(width: 20),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$minutesOfShower λεπτά',
                                      style: const TextStyle(
                                          color: Color(0xFF03605f),
                                          fontWeight: FontWeight.bold)),
                                  const Text(
                                    'Λεπτά ζεστού ντους',
                                    style: TextStyle(
                                        color: CupertinoColors.inactiveGray),
                                    overflow: TextOverflow.clip,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Container(
                  color: CupertinoColors.white,
                  padding: const EdgeInsets.only(
                      left: 25.0, right: 25.0, top: 20.0, bottom: 40.0),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.cloud,
                      ),
                      const SizedBox(width: 20),
                      const Text('CO2e που έσωσες:',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('$co2eAvoided kg',
                          style: const TextStyle(
                              color: Color(0xFF03605f),
                              fontWeight: FontWeight.bold)),
                    ],
                  )),
            ],
          ),
        );
      });
}

Widget _orderWidget(OrderDetails order, BuildContext context) {
  return CupertinoButton(
    onPressed: () {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => OrderPage(
            order: order,
            isPurchased: true,
            showForHistory: true,
          ),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          // Add this boxShadow property
          BoxShadow(
            color: CupertinoColors.black
                .withOpacity(0.1), // Shadow color with opacity
            spreadRadius: 0,
            blurRadius: 4.0,
            offset: const Offset(0, 2), // Keeps the shadow only at the bottom
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF03605f),
                    // width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    order.listing.store.imageProfileUrl,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFe0fce2),
                  ),
                  child: const Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    color: Color(0xFF03605f),
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.listing.store.name,
                  style: const TextStyle(
                      color: CupertinoColors.black,
                      fontWeight: FontWeight.w700,
                      overflow: TextOverflow.clip,
                      fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  "${order.quantity}x ${order.listing.category}",
                  style: const TextStyle(
                      color: CupertinoColors.black,
                      fontWeight: FontWeight.w400,
                      overflow: TextOverflow.clip,
                      fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            color: CupertinoColors.inactiveGray,
          ),
        ],
      ),
    ),
  );
}

final UserAPI userApi =
    UserAPI('http://127.0.0.1:5000'); // Replace with your actual API URL

Future<List<OrderDetails>> fetchUserOrders(String email) async {
  try {
    List<OrderDetails> orders = await userApi.getUserPurchasedOrders(email);

    return orders;
  } catch (e) {
    print(e);
    return [];
  }
}
