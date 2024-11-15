import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/model/order.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../api/user_api.dart';
import '../../model/order_provider.dart';
import 'help_page.dart';
import 'rating_page.dart';
import 'store_info_page.dart';

class OrderPage extends StatefulWidget {
  final OrderDetails order;
  final bool isPurchased;
  final bool showForHistory;

  const OrderPage(
      {super.key,
      required this.order,
      required this.isPurchased,
      required this.showForHistory});

  @override
  OrderPageState createState() => OrderPageState();
}

class OrderPageState extends State<OrderPage> {
  Timer? _timer;
  Duration _timeUntilCollection = const Duration();
  bool _isCollected = false; // New variable to track collection status

  // New method to handle collection confirmation
  Future<void> _handleCollectionConfirmed() async {
    setState(() {
      _isCollected = true;
    });
    // await ListingApi('http://127.0.0.1:5000').updateListingAsSold(widget.order.listing.id);
    await UserAPI('http://127.0.0.1:5000')
        .removeUserLiveOrder(widget.order.user.email, widget.order.listing.id);
    if (mounted) {
      Provider.of<OrderStatusProvider>(context, listen: false).orderCollected();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isPurchased) {
      _isCollected = true;
    }
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final collectionStart = widget.order.listing.availabilityStartDate;
      final difference = collectionStart.difference(now);

      if (mounted) {
        setState(() {
          _timeUntilCollection = difference;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String getButtonLabel() {
    if (_timeUntilCollection.inSeconds <= 0) {
      return "Διαθέσιμο";
    } else {
      return 'Διαθέσιμο σε ${_timeUntilCollection.inHours}:${_timeUntilCollection.inMinutes.remainder(60)}:${_timeUntilCollection.inSeconds.remainder(60)}';
    }
  }

  void _showCollectionPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Use a custom widget or a predefined style for the title
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                      alignment: Alignment.center,
                      child: _buildTitle('Το γεύμα σου είναι έτοιμο!')),
                  Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        child: const Icon(CupertinoIcons.clear_circled),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ))
                ],
              ),
              const SizedBox(height: 20),
              _buildInformationCard(
                quantity: '${widget.order.quantity}x',
                category: widget.order.listing.category,
                storeName: widget.order.listing.store.name,
                code: widget.order.listing.id,
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              _buildSwipeInstruction(
                'Κάνε swipe right και δείξε την παραγγελία στο προσωπικό. Βεβαιώσου ότι έχεις κάνει swipe μόνο όταν βρίσκεσε στο κατάστημα και είσαι έτοιμος/η να παραλάβεις το γεύμα σου.',
              ),
              const SizedBox(height: 30),
              SwipeButton(
                listingId: widget.order.listing.id,
                onSwipeComplete:
                    _handleCollectionConfirmed, // Pass the callback
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInformationCard({
    required String quantity,
    required String category,
    required String storeName,
    required String code,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF03605f),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                quantity,
                style: const TextStyle(
                    color: CupertinoColors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            category,
            style: const TextStyle(
              // fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            storeName,
            style: const TextStyle(
                // fontSize: 20,
                // fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF03605f),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                code.substring(code.length - 4).toUpperCase(),
                style: const TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeInstruction(String instruction) {
    return Text(
      instruction,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w200,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isCollectionTimeCloseOrStarted = _timeUntilCollection.inMinutes <= 30;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isCollected && isCollectionTimeCloseOrStarted) {
        print('Placing order');
        Provider.of<OrderStatusProvider>(context, listen: false)
            .placeOrder(widget.order);
      }
    });

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(onPressed: () {
          if (_isCollected && !widget.showForHistory) {
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) => RatingPage(order: widget.order),
                ));
          } else {
            Navigator.pop(context);
          }
        }),
        middle: const Text('H Παραγγελία σου'),
        border: const Border(bottom: BorderSide.none),
      ),
      child: orderWidget(
          context, isCollectionTimeCloseOrStarted, _isCollected, _timer),
    );
  }

  Widget orderWidget(BuildContext context, bool isCollectionTimeCloseOrStarted,
      bool isCollected, Timer? timer) {
    if (isCollected) {
      return SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: <Widget>[
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.45,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(
                    0xFF03605f), // Green container for collected orders
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.check_mark_circled_solid,
                          color: CupertinoColors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text('Ολοκληρώθηκε',
                            style: TextStyle(
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: CupertinoColors
                            .white, // White container inside green
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  foregroundImage: NetworkImage(widget
                                      .order.listing.store.imageProfileUrl),
                                  radius: 30,
                                  backgroundColor: CupertinoColors.systemGrey,
                                ),
                                const SizedBox(width: 20),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.order.listing.store.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.clip,
                                      ),
                                      Text(widget.order.listing.store.address),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('ΠΑΡΑΛΗΦΘΗΚΕ',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey)),
                                      Text('ΚΩΔΙΚΟΣ',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          '${widget.order.listing.availabilityStartDate.day}/${widget.order.listing.availabilityStartDate.month}/${widget.order.listing.availabilityStartDate.year}'),
                                      Text(widget.order.listing.id.substring(
                                          widget.order.listing.id.length - 6)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Column(
                                children: [
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('ΓΕΥΜΑ',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey)),
                                      Text('ΣΥΝΟΛΟ',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors
                                                  .grey)), // Retrieve and format from backend
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          '${widget.order.quantity}x ${widget.order.listing.category}'),
                                      Text(
                                          '${(widget.order.listing.discountedPrice * widget.order.quantity).toStringAsFixed(2)} €'),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ΜΕΘΟΔΟΣ ΠΛΗΡΩΜΗΣ',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey)),
                                    Text("Κάρτα")
                                  ]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: const Column(
                children: [
                  Icon(CupertinoIcons.question_circle),
                  Text('Χρειάζεσαι βοήθεια;'),
                ],
              ),
              onPressed: () {
                // Link to help page or customer support
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => const HelpPage()),
                );
              },
            ),
          ],
        ),
      );
    }

    // If order is not collected, show the original order page
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CupertinoColors
                  .white, // Consider replacing with a custom color
              borderRadius:
                  BorderRadius.circular(12), // Slightly more rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 2,
                  offset: const Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                // Link to store page
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext bc) {
                    return StoreInfoPage(
                      store: widget.order.listing.store,
                    );
                  },
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // add stores image here
                  CircleAvatar(
                    foregroundImage: NetworkImage(
                        widget.order.listing.store.imageProfileUrl),
                    radius: 30,
                    backgroundColor: CupertinoColors.systemGrey,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.order.listing.store.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(widget.order.listing.store.address),
                  const SizedBox(height: 10),
                  CupertinoButton(
                    padding: const EdgeInsets.all(10),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Βρες το κατάστημα'),
                        SizedBox(width: 5),
                        Icon(CupertinoIcons.location, size: 16),
                      ],
                    ),
                    onPressed: () async {
                      final url = widget.order.listing.store.website;
                      if (await canLaunchUrlString(url)) {
                        await launchUrlString(url);
                      } else {
                        if (mounted) {
                          showCupertinoDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CupertinoAlertDialog(
                                title: const Text('Error'),
                                content: const Text('Unable to open the URL.'),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            },
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CupertinoColors
                  .white, // Consider replacing with a custom color
              borderRadius:
                  BorderRadius.circular(12), // Slightly more rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 2,
                  offset: const Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ΗΜΕΡΟΜΗΝΙΑ',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey)),
                        Text('ΔΙΑΘΕΣΙΜΟΤΗΤΑ',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${widget.order.listing.availabilityStartDate.day}/${widget.order.listing.availabilityStartDate.month}/${widget.order.listing.availabilityStartDate.year}'),
                        Text(
                            '${widget.order.listing.availabilityStartDate.hour.toString().padLeft(2, '0')}:${widget.order.listing.availabilityStartDate.minute.toString().padLeft(2, '0')} - ${widget.order.listing.availabilityEndDate.hour.toString().padLeft(2, '0')}:${widget.order.listing.availabilityEndDate.minute.toString().padLeft(2, '0')}'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ΓΕΥΜΑ',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey)),
                        Text('ΣΥΝΟΛΟ',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors
                                    .grey)), // Retrieve and format from backend
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${widget.order.quantity}x ${widget.order.listing.category}'),
                        Text(
                            '${(widget.order.listing.discountedPrice * widget.order.quantity).toStringAsFixed(2)} €')
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PACKAGING',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey)),
                    Text(
                        "Το κατάστημα θα χρησιμοποιήσει την καλύτερη διαθέσιμη συσκευασία για το γεύμα σου.")
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                Center(
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(20),
                    color: isCollectionTimeCloseOrStarted
                        ? const Color(0xFF03605f)
                        : CupertinoColors.inactiveGray,
                    borderRadius: BorderRadius.circular(30),
                    onPressed: isCollectionTimeCloseOrStarted
                        ? () => _showCollectionPopup(context)
                        : null,
                    child: Text(getButtonLabel(),
                        style: const TextStyle(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton(
                padding: const EdgeInsets.only(right: 30),
                child: const Column(
                  children: [
                    Icon(CupertinoIcons.question_circle),
                    Text(
                      'Χρειάζεσαι βοήθεια;',
                      style: TextStyle(color: CupertinoColors.black),
                    ),
                  ],
                ),
                onPressed: () {
                  // Link to help page or customer support
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const HelpPage()),
                  );
                },
              ),
              isCollectionTimeCloseOrStarted
                  ? Container()
                  : CupertinoButton(
                      padding: const EdgeInsets.only(left: 30),
                      child: const Column(
                        children: [
                          Icon(CupertinoIcons.xmark_circle,
                              color: CupertinoColors.destructiveRed),
                          Text('Ακύρωση',
                              style: TextStyle(
                                  color: CupertinoColors.destructiveRed)),
                        ],
                      ),
                      onPressed: () async {
                        // Handle order cancellation logic
                        bool success = await UserAPI(
                                'http://127.0.0.1:5000')
                            .cancelOrder(
                                widget.order.listing.id,
                                widget.order.user
                                    .email); // currentUser should be the logged-in user's email

                        if (success) {
                          // Show success message and update the UI accordingly
                          CupertinoActionSheet(
                            title: const Text('Η παραγγελία ακυρώθηκε'),
                            message: const Text(
                                'Η παραγγελία σου ακυρώθηκε επιτυχώς.'),
                            cancelButton: CupertinoActionSheetAction(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          );
                        } else {
                          // Show failure message
                          CupertinoActionSheet(
                            title: const Text('Αποτυχία ακύρωσης'),
                            message: const Text(
                                'Επικοινώνησε μαζί μας στο contact@ecoeats.gr για να λύσουμε το πρόβλημα. Ευχαριστούμε!'),
                            cancelButton: CupertinoActionSheetAction(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          );
                        }
                      },
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

class SwipeButton extends StatefulWidget {
  const SwipeButton(
      {super.key, required this.listingId, required this.onSwipeComplete});
  final String listingId;
  final Function onSwipeComplete; // Callback for swipe completion

  @override
  SwipeButtonState createState() => SwipeButtonState();
}

class SwipeButtonState extends State<SwipeButton> {
  double _dragPercentage = 0.0;
  static const double swipeThreshold = 0.8;
  bool _collectionConfirmed = false;

  void _updateDragPosition(DragUpdateDetails details) {
    final screenSize = MediaQuery.of(context).size;
    double newDragPosition = details.globalPosition.dx / screenSize.width;
    newDragPosition = newDragPosition.clamp(0.0, 1.0);

    setState(() {
      _dragPercentage = newDragPosition;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragPercentage > swipeThreshold) {
      print("Swipe Completed!");
      _performAction();
    } else {
      _resetDragPosition();
    }
  }

  Future<void> _performAction() async {
    setState(() {
      _collectionConfirmed = true;
    });
    widget.onSwipeComplete(); // Call the callback after action is performed

    // Add additional actions on swipe completion if needed
  }

  void _resetDragPosition() {
    setState(() {
      _dragPercentage = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_collectionConfirmed) {
      return _buildConfirmationColumn();
    } else {
      return _buildSwipeButton();
    }
  }

  Widget _buildSwipeButton() {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onHorizontalDragUpdate: _updateDragPosition,
      onHorizontalDragEnd: _onDragEnd,
      child: Container(
        width: screenSize.width * 0.8,
        height: 60.0,
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF03605f), width: 2),
        ),
        child: Stack(
          children: <Widget>[
            _buildSwipeText(),
            _buildDraggableIcon(screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeText() {
    return Align(
      alignment: Alignment.center,
      child: Opacity(
        opacity: (1 - _dragPercentage).clamp(0.0, 1.0),
        child: const Text('Swipe για Παραλαβή',
            style: TextStyle(
                color: Color(0xFF03605f), fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDraggableIcon(Size screenSize) {
    double leftPosition = (screenSize.width * 0.8 * _dragPercentage)
        .clamp(0.0, screenSize.width * 0.8 - 100);

    return Positioned(
      left: leftPosition - 20,
      child: Container(
        width: 100,
        height: 60,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF03605f),
        ),
        child: const Icon(
          size: 30,
          CupertinoIcons.arrow_right_circle_fill,
          color: CupertinoColors.white,
        ),
      ),
    );
  }

  Widget _buildConfirmationColumn() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(CupertinoIcons.check_mark_circled_solid,
            color: Color(0xFF03605f), size: 50),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'Η παραγγελία σου επιβεβαιώθηκε',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Δείξε τον κωδικό στο προσωπικό και παράλαβε το γεύμα σου!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
